dashboard "sql_database_instance_detail" {

  title         = "GCP SQL Database Instance Detail"
  documentation = file("./dashboards/sql/docs/gcp_sql_database_instance_detail.md")

  tags = merge(local.sql_common_tags, {
    type = "Detail"
  })

  input "database_instance_self_link" {
    title = "Select a Database Instance Name:"
    query = query.sql_database_instance_input
    width = 4
  }

  container {
    card {
      width = 2
      query = query.sql_database_instance_database_version
      args  = [self.input.database_instance_self_link.value]
    }

    card {
      width = 2
      query = query.sql_database_instance_data_disk_size
      args  = [self.input.database_instance_self_link.value]
    }

    card {
      width = 2
      query = query.sql_database_instance_backup_enabled
      args  = [self.input.database_instance_self_link.value]
    }

    card {
      width = 2
      query = query.sql_database_instance_encryption
      args  = [self.input.database_instance_self_link.value]
    }

    card {
      width = 2
      query = query.sql_database_instance_is_public
      args  = [self.input.database_instance_self_link.value]
    }

    card {
      width = 2
      query = query.sql_database_instance_ssl_enabled
      args  = [self.input.database_instance_self_link.value]
    }
  }

  with "primary_sql_database_instances_for_sql_database_instance" {
    query = query.primary_sql_database_instances_for_sql_database_instance
    args  = [self.input.database_instance_self_link.value]
  }

  with "compute_networks_for_sql_database_instance" {
    query = query.compute_networks_for_sql_database_instance
    args  = [self.input.database_instance_self_link.value]
  }

  with "kms_keys_for_sql_database_instance" {
    query = query.kms_keys_for_sql_database_instance
    args  = [self.input.database_instance_self_link.value]
  }

  with "sql_backups_for_sql_database_instance" {
    query = query.sql_backups_for_sql_database_instance
    args  = [self.input.database_instance_self_link.value]
  }

  with "sql_databases_for_sql_database_instance" {
    query = query.sql_databases_for_sql_database_instance
    args  = [self.input.database_instance_self_link.value]
  }

  with "replica_sql_database_instances_for_sql_database_instance" {
    query = query.replica_sql_database_instances_for_sql_database_instance
    args  = [self.input.database_instance_self_link.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.compute_network
        args = {
          compute_network_ids = with.compute_networks_for_sql_database_instance.rows[*].network_id
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = with.kms_keys_for_sql_database_instance.rows[*].self_link
        }
      }

      node {
        base = node.sql_backup
        args = {
          sql_backup_ids = with.sql_backups_for_sql_database_instance.rows[*].backup_id
        }
      }

      node {
        base = node.sql_database
        args = {
          sql_database_self_links = with.sql_databases_for_sql_database_instance.rows[*].self_link
        }
      }

      node {
        base = node.sql_database_instance
        args = {
          database_instance_self_links = [self.input.database_instance_self_link.value]
        }
      }

      node {
        base = node.sql_database_instance
        args = {
          database_instance_self_links = with.primary_sql_database_instances_for_sql_database_instance.rows[*].self_link
        }
      }

      node {
        base = node.sql_database_instance
        args = {
          database_instance_self_links = with.replica_sql_database_instances_for_sql_database_instance.rows[*].self_link
        }
      }

      edge {
        base = edge.sql_database_instance_to_compute_network
        args = {
          database_instance_self_links = [self.input.database_instance_self_link.value]
        }
      }

      edge {
        base = edge.sql_database_instance_to_kms_key
        args = {
          database_instance_self_links = [self.input.database_instance_self_link.value]
        }
      }

      edge {
        base = edge.sql_database_instance_to_sql_backup
        args = {
          database_instance_self_links = [self.input.database_instance_self_link.value]
        }
      }

      edge {
        base = edge.sql_database_instance_to_sql_database
        args = {
          database_instance_self_links = [self.input.database_instance_self_link.value]
        }
      }

      edge {
        base = edge.sql_database_instance_to_sql_database_instance
        args = {
          database_instance_self_links = [self.input.database_instance_self_link.value]
        }
      }

      edge {
        base = edge.sql_database_instance_to_sql_database_instance
        args = {
          database_instance_self_links = with.primary_sql_database_instances_for_sql_database_instance.rows[*].self_link
        }
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
        query = query.sql_database_instance_overview
        args  = [self.input.database_instance_self_link.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.sql_database_instance_tags
        args  = [self.input.database_instance_self_link.value]
      }
    }

    container {
      width = 6

      table {
        title = "Replication Details"
        query = query.sql_database_instance_replication_status
        args  = [self.input.database_instance_self_link.value]
      }

      table {
        title = "Encryption Details"
        query = query.sql_database_instance_encryption_detail
        args  = [self.input.database_instance_self_link.value]
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
      args  = [self.input.database_instance_self_link.value]
    }

    chart {
      title = "Instance Connection - Last 7 Days"
      type  = "line"
      width = 6
      query = query.sql_database_instance_connection
      args  = [self.input.database_instance_self_link.value]
    }

  }
}

# Input queries

query "sql_database_instance_input" {
  sql = <<-EOQ
    select
      title as label,
      self_link as value,
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

# Card queries

query "sql_database_instance_database_version" {
  sql = <<-EOQ
    select
      'State' as label,
      initcap(state) as  value
    from
      gcp_sql_database_instance
    where
      self_link = $1;
  EOQ
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
      self_link = $1;
  EOQ
}

query "sql_database_instance_data_disk_size" {
  sql = <<-EOQ
    select
      'Data Disk Size (GB)' as label,
      data_disk_size_gb as value
    from
      gcp_sql_database_instance
    where
      self_link = $1;
  EOQ
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
      self_link = $1;
  EOQ
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
      self_link = $1;
  EOQ
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
      self_link = $1;
  EOQ
}

# With queries

query "primary_sql_database_instances_for_sql_database_instance" {
  sql = <<-EOQ
    select
      replace(self_link, name, split_part(master_instance_name, ':', 2)) as self_link
    from
      gcp_sql_database_instance
    where
      master_instance_name is not null
      and self_link = $1
      and project = split_part($1, '/', 7)
  EOQ
}

query "compute_networks_for_sql_database_instance" {
  sql = <<-EOQ
    with sql_database_instance as (
      select
        self_link,
        ip_configuration
      from
        gcp_sql_database_instance
      where
        project = split_part($1, '/', 7)
        and self_link = $1
    ), compute_network as (
      select
        id,
        name
      from
        gcp_compute_network
      where
        project = split_part($1, '/', 7)
    ) select
      n.id::text as network_id
    from
      sql_database_instance as i,
      compute_network as n
    where
      split_part(i.ip_configuration->>'privateNetwork','networks/', 2) = n.name
  EOQ
}

query "kms_keys_for_sql_database_instance" {
  sql = <<-EOQ
    with sql_database_instance as (
      select
        self_link,
        kms_key_name
      from
        gcp_sql_database_instance
      where
        project = split_part($1, '/', 7)
        and self_link = $1
    ), kms_key as (
      select
        self_link,
        name
      from
        gcp_kms_key
      where
        project = split_part($1, '/', 7)
    )
    select
      k.self_link
    from
      gcp_sql_database_instance as i,
      gcp_kms_key as k
    where
      i.kms_key_name = concat('projects', split_part(k.self_link,'projects',2));
  EOQ
}

query "sql_backups_for_sql_database_instance" {
  sql = <<-EOQ
    select
      id::text as backup_id
    from
      gcp_sql_backup
    where
      self_link like $1 || '/%'
      and project = split_part($1, '/', 7);
  EOQ
}

query "sql_databases_for_sql_database_instance" {
  sql = <<-EOQ
    select
      d.self_link
    from
      gcp_sql_database d
    where
      d.self_link like $1 || '/%'
      and d.project = split_part($1, '/', 7)
  EOQ
}

query "replica_sql_database_instances_for_sql_database_instance" {
  sql = <<-EOQ
    select
      self_link
    from
      gcp_sql_database_instance
    where
      master_instance_name is not null
      and replace(self_link, name, split_part(master_instance_name, ':', 2)) = $1
      and project = split_part($1, '/', 7)
  EOQ
}

# Other queries

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
      project as "Project"
    from
      gcp_sql_database_instance
    where
      self_link = $1;
  EOQ
}

query "sql_database_instance_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_sql_database_instance
      where
        self_link = $1
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
      self_link = $1;
  EOQ
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
      d.kms_key_name = concat('projects', split_part(k.self_link,'projects',2))
      and d.self_link = $1;
  EOQ
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
      and split_part(instance_id, ':', 2) in (select name from gcp_sql_database_instance where self_link = $1)
    order by
      timestamp;
  EOQ
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
      and split_part(instance_id, ':', 2) in (select name from gcp_sql_database_instance where self_link = $1)
    order by
      timestamp;
  EOQ
}
