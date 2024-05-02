edge "sql_backup_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      b.id::text as from_id,
      k.self_link as to_id
    from
      gcp_kms_key k,
      gcp_sql_backup b
    where
      k.self_link like '%' || (b.disk_encryption_configuration ->> 'kmsKeyName')
      and b.id = any($1);
  EOQ

  param "sql_backup_ids" {}
}

edge "sql_database_instance_to_compute_network" {
  title = "network"

  sql = <<-EOQ
    select
      i.self_link as from_id,
      n.id::text as to_id
    from
      gcp_sql_database_instance as i
      join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 7),
      gcp_compute_network as n
    where
      split_part(i.ip_configuration->>'privateNetwork','networks/',2) = n.name;
  EOQ

  param "database_instance_self_links" {}
}

edge "sql_database_instance_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.self_link as from_id,
      k.self_link as to_id
    from
      gcp_sql_database_instance as i
      join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 7),
      gcp_kms_key as k
    where
      i.kms_key_name = concat('projects', split_part(k.self_link,'projects',2));
  EOQ

  param "database_instance_self_links" {}
}

edge "sql_database_instance_to_sql_backup" {
  title = "backup"

  sql = <<-EOQ
    select
      sl as from_id,
      id::text as to_id
    from
      gcp_sql_backup,
      jsonb_array_elements_text($1) sl
    where
      self_link like sl || '/%'
      and project = split_part(sl, '/', 7)
  EOQ

  param "database_instance_self_links" {}
}

edge "sql_database_instance_to_sql_database" {
  title = "database"

  sql = <<-EOQ
    select
      sl as from_id,
      d.self_link as to_id
    from
      gcp_sql_database d,
      jsonb_array_elements_text($1) sl
    where
      self_link like sl || '/%'
      and project = split_part(sl, '/', 7)
  EOQ

  param "database_instance_self_links" {}
}

edge "sql_database_instance_to_sql_database_instance" {
  title = "replica"

  sql = <<-EOQ
    select
      replace(self_link, name, split_part(master_instance_name, ':', 2)) as from_id,
      self_link as to_id
    from
      gcp_sql_database_instance
      join unnest($1::text[]) as a on self_link = a and project = split_part(a, '/', 7)
    where
      replace(self_link, name, split_part(master_instance_name, ':', 2)) = any($1);
  EOQ

  param "database_instance_self_links" {}
}