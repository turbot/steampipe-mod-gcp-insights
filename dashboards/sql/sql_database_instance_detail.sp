dashboard "sql_database_instance_detail" {

  title         = "GCP SQL Database Instance"
  documentation = file("./dashboards/sql/docs/gcp_sql_database_instance_detail.md")

  tags = merge(local.sql_common_tags, {
    type = "Detail"
  })

  input "database_instance_name" {
    title = "Select a Database Instance Name:"
    sql   = query.sql_database_instance_input.sql
    width = 4
  }

  container {
    card {
      width = 2

      query = query.sql_database_instance_database_version
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.sql_database_instance_data_disk_size
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2
      query = query.sql_database_instance_backup_enabled
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.sql_database_instance_encryption
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.sql_database_instance_is_public
      args = {
        name = self.input.database_instance_name.value
      }
    }

    card {
      width = 2

      query = query.sql_database_instance_ssl_enabled
      args = {
        name = self.input.database_instance_name.value
      }
    }
  }

  // container {

  //   graph {
  //     title = "Relationships"
  //     type  = "graph"

  //     with "compute_networks" {
  //       sql = <<-EOQ
  //         select
  //           n.name as network_name
  //         from
  //           gcp_sql_database_instance as i,
  //           gcp_compute_network as n
  //         where
  //           SPLIT_PART(i.ip_configuration->>'privateNetwork','networks/',2) = n.name
  //           and i.name = $1;
  //       EOQ

  //       args = [self.input.database_instance_name.value]
  //     }

  //     with "kms_keys" {
  //       sql = <<-EOQ
  //         select
  //           k.name as key_name
  //         from
  //           gcp_sql_database_instance as i,
  //           gcp_kms_key as k
  //         where
  //           i.name = $1 and i.kms_key_name = CONCAT('projects', SPLIT_PART(k.self_link,'projects',2));
  //       EOQ

  //       args = [self.input.database_instance_name.value]
  //     }

  //     with "sql_backups" {
  //       sql = <<-EOQ
  //         select
  //           id as backup_id
  //         from
  //           gcp_sql_backup
  //         where
  //           instance_name = any($1);
  //       EOQ

  //       args = [self.input.database_instance_name.value]
  //     }

  //     nodes = [
  //       node.compute_network,
  //       node.kms_key,
  //       node.sql_backup,
  //       node.sql_database,
  //       node.sql_database_instance,
  //       node.sql_database_instance_from_primary_database_instance,
  //       node.sql_database_instance_to_database_instance_replica
  //     ]

  //     edges = [
  //       edge.sql_database_instance_from_primary_database_instance,
  //       edge.sql_database_instance_to_compute_network,
  //       edge.sql_database_instance_to_database_instance_replica,
  //       edge.sql_database_instance_to_kms_key,
  //       edge.sql_database_instance_to_sql_backup,
  //       edge.sql_database_instance_to_sql_database
  //     ]

  //     args = {
  //       compute_network_names       = with.compute_networks.rows[*].network_name
  //       kms_key_names               = with.kms_keys.rows[*].key_name
  //       sql_backup_ids              = with.sql_backups.rows[*].backup_id
  //       sql_database_instance_names = [self.input.database_instance_name.value]
  //     }
  //   }
  // }

  container {

    container {

      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.sql_database_instance_overview
        args = {
          name = self.input.database_instance_name.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.sql_database_instance_tags
        args = {
          name = self.input.database_instance_name.value
        }
      }
    }

    container {
      width = 6

      table {
        title = "Replication Details"
        query = query.sql_database_instance_replication_status
        args = {
          name = self.input.database_instance_name.value
        }
      }

      table {
        title = "Encryption Details"
        query = query.sql_database_instance_encryption_detail
        args = {
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
      query = query.sql_database_instance_cpu_utilization
      args = {
        name = self.input.database_instance_name.value
      }
    }

    chart {
      title = "Instance Connection - Last 7 Days"
      type  = "line"
      width = 6
      query = query.sql_database_instance_connection
      args = {
        name = self.input.database_instance_name.value
      }
    }

  }
}

query "sql_database_instance_input" {
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

query "sql_database_instance_database_version" {
  sql = <<-EOQ
    select
      'State' as label,
      state as  value
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "sql_database_instance_encryption" {
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

query "sql_database_instance_data_disk_size" {
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

query "sql_database_instance_backup_enabled" {
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

query "sql_database_instance_is_public" {
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

query "sql_database_instance_ssl_enabled" {
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
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "sql_database_instance_overview" {
  sql = <<-EOQ
    select
      database_version as "Database Version",
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

query "sql_database_instance_tags" {
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

query "sql_database_instance_replication_status" {
  sql = <<-EOQ
    select
      master_instance_name as "Master Instance Name",
      replication_type as "Replication Type",
      database_replication_enabled as "Database Replication Enabled",
      crash_safe_replication_enabled as "Crash Safe Replication Enabled"
    from
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "sql_database_instance_encryption_detail" {
  sql = <<-EOQ
    select
      k.name as "Key Name",
      k.key_ring_name as "Key Ring Name",
      k.primary ->> 'state' as "Key State",
      k.primary ->> 'algorithm' as "Key Algorithm"
    from
      gcp_sql_database_instance as d,
      gcp_kms_key as k
    where
      d.kms_key_name = CONCAT('projects', SPLIT_PART(k.self_link,'projects',2))
      and d.name = $1;
  EOQ

  param "name" {}
}

query "sql_database_instance_cpu_utilization" {
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

query "sql_database_instance_connection" {
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
