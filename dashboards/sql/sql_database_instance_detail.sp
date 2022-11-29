dashboard "gcp_sql_database_instance_detail" {

  title         = "GCP SQL Database Instance"
  documentation = file("./dashboards/sql/docs/gcp_sql_database_instance_detail.md")

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
      args = {
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
        node.gcp_sql_database_instance_nodes,
        node.gcp_sql_database_instance_to_kms_key_node,
        node.gcp_sql_database_instance_to_sql_database_node,
        node.gcp_sql_database_instance_to_compute_network_node,
        node.gcp_sql_database_instance_to_sql_backup_node,
        node.gcp_sql_database_instance_to_database_instance_replica_node,
        node.gcp_sql_database_instance_from_primary_database_instance_node
      ]

      edges = [
        edge.gcp_sql_database_instance_to_kms_key_edge,
        edge.gcp_sql_database_instance_to_sql_database_edge,
        edge.gcp_sql_database_instance_to_compute_network_edge,
        edge.gcp_sql_database_instance_to_database_instance_replica_edge,
        edge.gcp_sql_database_instance_to_sql_backup_edge,
        edge.gcp_sql_database_instance_from_primary_database_instance_edge
      ]

      args = {
        name                    = self.input.database_instance_name.value
        database_instance_names = [self.input.database_instance_name.value]
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
        args = {
          name = self.input.database_instance_name.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_sql_database_instance_tags
        args = {
          name = self.input.database_instance_name.value
        }
      }
    }

    container {
      width = 6

      table {
        title = "Replication Details"
        query = query.gcp_sql_database_instance_replication_status
        args = {
          name = self.input.database_instance_name.value
        }
      }

      table {
        title = "Encryption Details"
        query = query.gcp_sql_database_instance_encryption_detail
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
      query = query.gcp_sql_database_instance_cpu_utilization
      args = {
        name = self.input.database_instance_name.value
      }
    }

    chart {
      title = "Instance Connection - Last 7 Days"
      type  = "line"
      width = 6
      query = query.gcp_sql_database_instance_connection
      args = {
        name = self.input.database_instance_name.value
      }
    }

  }
}

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
      'State' as label,
      state as  value
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
      gcp_sql_database_instance
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_sql_database_instance_overview" {
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

query "gcp_sql_database_instance_encryption_detail" {
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

node "gcp_sql_database_instance_nodes" {
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
        'BackupEnabled', backup_enabled
      ) as properties
    from
      gcp_sql_database_instance
    where
      name = any($1);
  EOQ

  param "database_instance_names" {}
}

node "gcp_sql_database_instance_to_kms_key_node" {
  category = category.gcp_kms_key

  sql = <<-EOQ
    select
      k.name as id,
      k.title,
      jsonb_build_object(
        'Name', k.name,
        'Created Time', k.create_time,
        'Key Ring Name', key_ring_name,
        'Location', k.location
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
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.name as from_id,
      k.name as to_id
    from
      gcp_sql_database_instance as i,
      gcp_kms_key as k
    where
      i.name = $1 and i.kms_key_name = CONCAT('projects', SPLIT_PART(k.self_link,'projects',2));
  EOQ

  param "name" {}
}

node "gcp_sql_database_instance_to_sql_database_node" {
  category = category.gcp_sql_database

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

  param "name" {}
}

edge "gcp_sql_database_instance_to_sql_database_edge" {
  title = "database"

  sql = <<-EOQ
    select
      i.name as from_id,
      d.name as to_id
    from
      gcp_sql_database_instance as i,
      gcp_sql_database d
    where
      d.instance_name = $1;
  EOQ

  param "name" {}
}

node "gcp_sql_database_instance_to_compute_network_node" {
  category = category.gcp_compute_network

  sql = <<-EOQ
    select
      n.name as id,
      n.title,
      jsonb_build_object(
        'ID', n.id,
        'Name', n.name,
        'Created Time', n.creation_timestamp
      ) as properties
    from
      gcp_sql_database_instance as i,
      gcp_compute_network as n
    where
      SPLIT_PART(i.ip_configuration->>'privateNetwork','networks/',2) = n.name
      and i.name = $1;
  EOQ

  param "name" {}
}

edge "gcp_sql_database_instance_to_compute_network_edge" {
  title = "network"

  sql = <<-EOQ
    select
      n.name as to_id,
      i.name as from_id
    from
      gcp_sql_database_instance as i,
      gcp_compute_network as n
    where
      SPLIT_PART(i.ip_configuration->>'privateNetwork','networks/',2) = n.name
      and i.name = $1;
  EOQ

  param "name" {}
}

node "gcp_sql_database_instance_to_sql_backup_node" {
  category = category.gcp_sql_backup

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
      instance_name = $1;
  EOQ

  param "name" {}
}

edge "gcp_sql_database_instance_to_sql_backup_edge" {
  title = "backup"

  sql = <<-EOQ
    select
      id as to_id,
      instance_name as from_id
    from
      gcp_sql_backup
    where
      instance_name = $1;
  EOQ

  param "name" {}
}
node "gcp_sql_database_instance_to_database_instance_replica_node" {
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
      SPLIT_PART(master_instance_name, ':', 2) = $1;
  EOQ

  param "name" {}
}

edge "gcp_sql_database_instance_to_database_instance_replica_edge" {
  title = "replica"

  sql = <<-EOQ
    select
      name as to_id,
      SPLIT_PART(master_instance_name, ':', 2) as from_id
    from
      gcp_sql_database_instance
    where
      SPLIT_PART(master_instance_name, ':', 2) = $1;
  EOQ

  param "name" {}
}

node "gcp_sql_database_instance_from_primary_database_instance_node" {
  category = category.gcp_sql_database_instance

  sql = <<-EOQ
  with master_instance as (
    select 
      split_part(master_instance_name, ':', 2) as name 
    from  
      gcp_sql_database_instance 
    where 
      name = $1
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

  param "name" {}
}

edge "gcp_sql_database_instance_from_primary_database_instance_edge" {
  title = "replicated from"

  sql = <<-EOQ
    with master_instance as (
      select 
        split_part(master_instance_name, ':', 2) as mname,
        name
      from  
        gcp_sql_database_instance 
      where 
        name = $1
    )
    select
      i.name as from_id,
      m.name as to_id
    from
      gcp_sql_database_instance as i,
      master_instance as m
    where
      i.name = m.mname;
  EOQ

  param "name" {}
}
