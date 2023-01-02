edge "sql_backup_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      b.id::text as from_id,
      k.name as to_id
    from
      gcp_kms_key k,
      gcp_sql_backup b
    where
      split_part(b.disk_encryption_configuration ->> 'kmsKeyName','cryptoKeys/',2) = k.name
      and b.id = any($1);
  EOQ

  param "sql_backup_ids" {}
}

edge "sql_database_instance_to_compute_network" {
  title = "network"

  sql = <<-EOQ
    select
      n.id::text as to_id,
      i.name as from_id
    from
      gcp_sql_database_instance as i,
      gcp_compute_network as n,
      jsonb_array_elements_text($1) as full_name
    where
      i.self_link like '%' || full_name
      and SPLIT_PART(i.ip_configuration->>'privateNetwork','networks/',2) = n.name
  EOQ

  param "sql_database_instance_names" {}
}

edge "sql_database_instance_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.name as from_id,
      k.name as to_id
    from
      gcp_sql_database_instance as i,
      gcp_kms_key as k,
      jsonb_array_elements_text($1) as full_name
    where
      i.self_link like '%' || full_name
      and i.kms_key_name = CONCAT('projects', SPLIT_PART(k.self_link,'projects',2));
  EOQ

  param "sql_database_instance_names" {}
}

edge "sql_database_instance_to_sql_backup" {
  title = "backup"

  sql = <<-EOQ
    select
      id::text as to_id,
      instance_name as from_id
    from
      gcp_sql_backup,
      jsonb_array_elements_text($1) as full_name
    where
      self_link like '%' || full_name || '/%';
  EOQ

  param "sql_database_instance_names" {}
}

edge "sql_database_instance_to_sql_database" {
  title = "database"

  sql = <<-EOQ
    select
      d.instance_name as from_id,
      d.name as to_id
    from
      gcp_sql_database d
      jsonb_array_elements_text($1) as full_name
    where
      self_link like '%' || full_name || '/%';
  EOQ

  param "sql_database_instance_names" {}
}

edge "sql_database_instance_to_sql_database_instance" {
  title = "replica"

  sql = <<-EOQ
    select
      name as to_id,
      SPLIT_PART(master_instance_name, ':', 2) as from_id
    from
      gcp_sql_database_instance
    where
      ('projects/' || project || '/instances/' || split_part(master_instance_name, ':', 2)) = any($1);
  EOQ

  param "sql_database_instance_names" {}
}