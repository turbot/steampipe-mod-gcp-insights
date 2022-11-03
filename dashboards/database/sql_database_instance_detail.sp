dashboard "gcp_sql_database_instance" {

  title = "GCP SQL Database Instance"
  documentation = file("./dashboards/database/docs/gcp_sql_database_instance.md")

  tags = merge(local.sql_common_tags, {
    type = "Detail"
  })

  input "database_instance_name" {
    title = "Select a Database Instance Name:"
    sql   = query.gcp_sql_database_instance_input.sql
    width = 4
  }

  container {
    card {
      width = 2

      query = query.gcp_sql_database_instance_database_version
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.gcp_sql_database_instance_data_disk_size
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_sql_database_instance_backup_enabled
      args  = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.gcp_sql_database_instance_encryption
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.gcp_sql_database_instance_is_public
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.gcp_sql_database_instance_ssl_enabled
      args = {
        name = self.input.database_instance_name.value
      }
    }
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      nodes = [
        node.gcp_sql_database_instance_node,
        node.gcp_sql_database_instance_to_machine_type_node,
        node.gcp_sql_database_instance_to_data_disk_node,
        node.gcp_sql_database_instance_to_kms_key_node
      ]

      edges = [
        edge.gcp_sql_database_instance_to_machine_type_edge,
        edge.gcp_sql_database_instance_to_data_disk_edge,
        edge.gcp_sql_database_instance_to_kms_key_edge
      ]

      args = {
        name = self.input.database_instance_name.value
      }
    }
  }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.gcp_sql_database_instance_overview
        args  = {
          name = self.input.database_instance_name.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_sql_database_instance_tags
        args  = {
          name = self.input.database_instance_name.value
        }
      }
    }

    container {
      width = 6

      table {
      title = "Replication Details"
      query = query.gcp_sql_database_instance_replication_status
      args  = {
          name = self.input.database_instance_name.value
        }
      }

      table {
        title = "Encryption Details"
        query = query.gcp_sql_database_instance_encryption_status
        args  = {
          name = self.input.database_instance_name.value
        }
      }
    }
  }

  container {

    width = 12

    chart {
      title = "CPU Utilization - Last 7 Days"
      type  = "line"
      width = 6
      query = query.gcp_sql_database_instance_cpu_utilization
      args  = {
        name = self.input.database_instance_name.value
      }
    }

    chart {
      title = "Instance Connection - Last 7 Days"
      type  = "line"
      width = 6
      query = query.gcp_sql_database_instance_connection
      args  = {
        name = self.input.database_instance_name.value
      }
    }

  }
}

# Card Queries
query "gcp_sql_database_instance_input" {
  sql = <<-EOQ
    select
      title as label,
      name as value,
      json_build_object(
        'location', location,
        'project', project
      ) as tags
    from
      gcp_sql_database_instance
    order by
      title;
  EOQ
}


query "gcp_sql_database_instance_database_version" {
  sql = <<-EOQ
    select
      'Database Version' as label,
      database_version as  value
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_encryption" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when kms_key_name is null then 'Disabled' else 'Enabled' end as value,
      case when kms_key_name is null then 'alert' else 'ok' end as type
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_data_disk_size" {
  sql = <<-EOQ
    select
      'Data Disk Size (GB)' as label,
      data_disk_size_gb as value
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_backup_enabled" {
  sql = <<-EOQ
    select
      'Backup' as label,
      case
        when backup_enabled then 'Enabled'
        else 'Disabled'
      end as value,
      case
        when backup_enabled then 'ok'
        else 'alert'
      end as "type"
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_is_public" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case when ip_configuration -> 'authorizedNetworks' @> '[{"name": "internet", "value": "0.0.0.0/0"}]' then 'Enabled' else 'Disabled' end as value,
      case when ip_configuration -> 'authorizedNetworks' @> '[{"name": "internet", "value": "0.0.0.0/0"}]' then 'alert' else 'ok' end as type
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_ssl_enabled" {
  sql = <<-EOQ
    select
      'SSL' as label,
      case
        when ip_configuration -> 'requireSsl' is null then 'Disabled'
        else 'Enabled'
      end as value,
      case
        when ip_configuration -> 'requireSsl' is null
          then 'alert'
        else 'ok'
      end as type
    from
      gcp_sql_database_instance;
  EOQ
}



query "gcp_sql_database_instance_overview" {
  sql = <<-EOQ
    select
      state as "State",
      instance_type as "Instance Type",
      pricing_plan as "Pricing Plan",
      case
        when storage_auto_resize then 'Enabled'
        else 'Disabled'
      end as "Auto Resize",
      machine_type as "Machine Type",
      title as "Title",
      location as "Location",
      project as "Project ID"
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_sql_database_instance
      where
        name = $1
    )
    select
      key as "Key",
      value as "Value"
    from
      jsondata,
      json_each_text(tags)
    order by
      key;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_replication_status" {
  sql = <<-EOQ
    select
      backup_replication_log_archiving_enabled as "Backup Replication Log Archiving Enabled",
      crash_safe_replication_enabled as "Crash Safe Replication Enabled",
      database_replication_enabled as "Database Replication Enabled",
      replication_type as "Replication Type",
      replication_configuration as "Replication Configuration"
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_encryption_status" {
  sql = <<-EOQ
    select
      k.primary ->> 'state' as "Key State",
      k.primary ->> 'algorithm' as "Key Algorithm"
    from
      gcp_sql_database_instance as d,
      gcp_kms_key as k
    where
      d.kms_key_name = CONCAT('projects', SPLIT_PART(k.self_link,'projects',2))
  EOQ
}

query "gcp_sql_database_instance_cpu_utilization" {
  sql = <<-EOQ
    select
      timestamp,
      (sum / 300) as cpu_utilization
    from
      gcp_sql_database_instance_metric_cpu_utilization
    where
      timestamp >= current_date - interval '7 day'
      and SPLIT_PART(instance_id, ':', 2) in (select name from gcp_sql_database_instance where name = $1)
    order by
      timestamp;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_connection" {
  sql = <<-EOQ
    select
      timestamp,
      (sum / 300) as instance_connection
    from
      gcp_sql_database_instance_metric_connections
    where
      timestamp >= current_date - interval '7 day'
      and SPLIT_PART(instance_id, ':', 2) in (select name from gcp_sql_database_instance where name = $1)
    order by
      timestamp;
  EOQ

  param "name" {}
}

node "gcp_sql_database_instance_node" {
  category = category.gcp_sql_database_instance

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
      name = $1;
  EOQ

  param "name" {}
}

node "gcp_sql_database_instance_to_machine_type_node" {
  category = category.gcp_sql_database_instance_machine_type

  sql = <<-EOQ
    select
      machine_type as id,
      machine_type as title,
      jsonb_build_object(
        'Name', name,
        'State', state,
        'DatabaseVersion', database_version,
        'MachineType', machine_type
      ) as properties
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

edge "gcp_sql_database_instance_to_machine_type_edge" {
  title = "machine type"

  sql = <<-EOQ
    select
      name as from_id,
      machine_type as to_id,
      jsonb_build_object(
        'Name', name,
        'State', state,
        'DatabaseVersion', database_version,
        'MachineType', machine_type
      ) as properties
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

node "gcp_sql_database_instance_to_data_disk_node" {
  category = category.gcp_sql_database_instance_data_disk

  sql = <<-EOQ
    select
      data_disk_type as id,
      data_disk_type as title,
      jsonb_build_object(
        'Disk Type', data_disk_type,
        'Disk Size (GB)', data_disk_size_gb,
        'MaxDiskSize (Bytes)', max_disk_size,
        'CurrentDiskSize (Bytes)', current_disk_size
      ) as properties
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

edge "gcp_sql_database_instance_to_data_disk_edge" {
  title = "data disk"

  sql = <<-EOQ
    select
      name as from_id,
      data_disk_type as to_id,
      jsonb_build_object(
        'Disk Type', data_disk_type,
        'Disk Size (GB)', data_disk_size_gb,
        'MaxDiskSize (Bytes)', max_disk_size,
        'CurrentDiskSize (Bytes)', current_disk_size
      ) as properties
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

node "gcp_sql_database_instance_to_kms_key_node" {
  category = category.gcp_sql_database_instance_kms_key

  sql = <<-EOQ
    select
      i.kms_key_name as id,
      k.name as title,
      jsonb_build_object(
        'KMS Key Name', i.kms_key_name,
        'KMS Key Version Name', i.kms_key_version_name,
        'Primary', k.primary,
        'Version Template', version_template
      ) as properties
    from
      gcp_sql_database_instance as i,
      gcp_kms_key as k
    where
      i.name = $1 and i.kms_key_name = CONCAT('projects', SPLIT_PART(k.self_link,'projects',2));
  EOQ

  param "name" {}
}

edge "gcp_sql_database_instance_to_kms_key_edge" {
  title = "kms key"

  sql = <<-EOQ
    select
      i.name as from_id,
      i.kms_key_name as to_id,
      jsonb_build_object(
        'KMS Key Name', i.kms_key_name,
        'KMS Key Version Name', i.kms_key_version_name,
        'Primary', k.primary,
        'Version Template', version_template
      ) as properties
    from
      gcp_sql_database_instance as i,
      gcp_kms_key as k
    where
      i.name = $1 and i.kms_key_name = CONCAT('projects', SPLIT_PART(k.self_link,'projects',2));
  EOQ

  param "name" {}
}