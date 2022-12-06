node "sql_backup" {
  category = category.sql_backup

  sql = <<-EOQ
    select
      id as id,
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
      d.name as id,
      d.title,
      jsonb_build_object(
        'Project', d.project,
        'Location', d.location
      ) as properties
    from
      gcp_sql_database_instance as i,
      gcp_sql_database d
    where
      d.instance_name = $1;
  EOQ

  param "sql_database_instance_names" {}
}

node "sql_database_instance" {
  category = category.sql_database_instance

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Name', name,
        'State', state,
        'DatabaseVersion', database_version,
        'MachineType', machine_type,
        'DataDiskSizeGB', data_disk_size_gb,
        'BackupEnabled', backup_enabled
      ) as properties
    from
      gcp_sql_database_instance
    where
      name = any($1);
  EOQ

  param "sql_database_instance_names" {}
}

node "sql_database_instance_to_database_instance_replica" {
  category = category.sql_database_instance

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Name', name,
        'State', state,
        'DatabaseVersion', database_version,
        'MachineType', machine_type,
        'DataDiskSizeGB', data_disk_size_gb,
        'BackupEnabled', backup_enabled,
        'Project', project,
        'Location', location
      ) as properties
    from
      gcp_sql_database_instance
    where
      SPLIT_PART(master_instance_name, ':', 2) = $1;
  EOQ

  param "sql_database_instance_names" {}
}

node "sql_database_instance_from_primary_database_instance" {
  category = category.sql_database_instance

  sql = <<-EOQ
  with master_instance as (
    select 
      split_part(master_instance_name, ':', 2) as name 
    from  
      gcp_sql_database_instance 
    where 
      name = any($1)
  )
  select
    i.name as id,
    title,
    jsonb_build_object(
      'Name', i.name,
      'State', state,
      'DatabaseVersion', database_version,
      'MachineType', machine_type,
      'DataDiskSizeGB', data_disk_size_gb,
      'BackupEnabled', backup_enabled,
      'Project', project,
      'Location', location
    ) as properties
  from
      gcp_sql_database_instance as i,
      master_instance as m
  where
      i.name = m.name;
  EOQ

  param "sql_database_instance_names" {}
}