node "sql_backup" {
  category = category.sql_backup

  sql = <<-EOQ
    select
      id,
      title,
      jsonb_build_object(
        'Backup Instance Name', instance_name,
        'Status', status,
        'Start Time', enqueued_time,
        'End Time', end_time,
        'Project', project,
        'Location', location
      ) as properties
    from
      gcp_sql_backup
    where
      id = any($1);
  EOQ

  param "sql_backup_ids" {}
}

node "sql_database" {
  category = category.sql_database

  sql = <<-EOQ
    select
      d.self_link as id,
      d.title,
      jsonb_build_object(
        'Project', d.project,
        'Location', d.location
      ) as properties
    from
      gcp_sql_database d
      join unnest($1::text[]) as a on d.self_link = a and d.project = split_part(a, '/', 7);
  EOQ

  param "sql_database_self_links" {}
}

node "sql_database_instance" {
  category = category.sql_database_instance

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Name', name,
        'State', state,
        'DatabaseVersion', database_version,
        'MachineType', machine_type,
        'DataDiskSizeGB', data_disk_size_gb,
        'BackupEnabled', backup_enabled,
        'Project', project,
        'Self Link', self_link
      ) as properties
    from
      gcp_sql_database_instance
      join unnest($1::text[]) as a on self_link = a and project = split_part(a, '/', 7);
  EOQ

  param "database_instance_self_links" {}
}
