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

      query = query.gcp_sql_database_instance_machine_type
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.gcp_sql_database_instance_data_disk_type
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

      query = query.gcp_sql_database_instance_used_disk_size
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


query "gcp_sql_database_instance_machine_type" {
  sql = <<-EOQ
    select
      'Machine Type' as label,
      machine_type as  value
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

query "gcp_sql_database_instance_data_disk_type" {
  sql = <<-EOQ
    select
      'Data Disk Type' as label,
      data_disk_type as value
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

query "gcp_sql_database_instance_used_disk_size" {
  sql = <<-EOQ
    select
      'Used Disk Size' as label,
      "current_disk_size" || ' ' || 'Bytes' as value
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

query "gcp_sql_database_instance_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      state as "State",
      instance_type as "Instance Type",
      kind as "Kind",
      backup_location as "Backup Location",
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
      backup_replication_log_archiving_enabled::TEXT as "Backup Replication Log Archiving Enabled",
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
      d.kms_key_name as "Kms key Name",
      d.kms_key_version_name as "Kms Key Version Name",
      k.primary ->> 'algorithm' as "Key Algorithm",
      k.primary ->> 'state' as "Key State"
    from
      gcp_sql_database_instance as d,
      gcp_kms_key as k
    where
      d.kms_key_name = k.name
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