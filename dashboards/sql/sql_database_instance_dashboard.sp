dashboard "gcp_sql_database_instance_dashboard" {

  title         = "GCP SQL Database Instance Dashboard"
  documentation = file("./dashboards/database/docs/gcp_sql_database_instance_dashboard.md")

  tags = merge(local.sql_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.gcp_sql_database_instance_count
      width = 2
    }

    card {
      query = query.gcp_sql_database_instance_encryption_count
      width = 2
    }

    card {
      query = query.gcp_sql_database_instance_backup_enabled_count
      width = 2
    }

    card {
      query = query.gcp_sql_database_instance_point_in_time_recovery_enable_count
      width = 2
    }

    card {
      query = query.gcp_sql_database_instance_public_access_count
      width = 2
    }

    card {
      query = query.gcp_sql_database_instance_ssl_enabled_count
      width = 2
    }
  }

  container {

    title = "Assessments"

    chart {
      title = "Database Encryption Status"
      query = query.gcp_sql_database_instance_encryption_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Database Backup Status"
      query = query.gcp_sql_database_instance_backup_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Point-in-time Recovery Status"
      query = query.gcp_sql_database_instance_point_in_time_recovery_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Public Access Status"
      query = query.gcp_sql_database_instance_public_access_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "SSL Status"
      query = query.gcp_sql_database_ssl_status
      type  = "donut"
      width = 4

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Instances by Project"
      query = query.gcp_sql_database_instance_by_project
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by Location"
      query = query.gcp_sql_database_instance_by_location
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by State"
      query = query.gcp_sql_database_instance_by_state
      type  = "column"
      width = 3
    }

    chart {
      title = "Instances by Replica"
      query = query.gcp_sql_database_instance_by_replica
      type  = "column"
      width = 3
    }
  }

}

# Card Queries

query "gcp_sql_database_instance_count" {
  sql = <<-EOQ
    select count(*) as "Database Instances" from gcp_sql_database_instance;
  EOQ
}

query "gcp_sql_database_instance_encryption_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Database Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_sql_database_instance
    where
      kms_key_name = '';
  EOQ
}

query "gcp_sql_database_instance_backup_enabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Backup Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_sql_database_instance
    where
      backup_enabled;
  EOQ
}

query "gcp_sql_database_instance_point_in_time_recovery_enable_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Point-in-time Recovery Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_sql_database_instance
    where
      enable_point_in_time_recovery;
  EOQ
}

query "gcp_sql_database_instance_failover_replica_available_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Fail Over Replica Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_sql_database_instance
    where
      failover_replica_available;
  EOQ
}

query "gcp_sql_database_instance_public_access_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Public Access Enabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_sql_database_instance
    where
      ip_configuration -> 'authorizedNetworks' @> '[{"name": "internet", "value": "0.0.0.0/0"}]';
  EOQ
}

query "gcp_sql_database_instance_ssl_enabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'SSL Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_sql_database_instance
    where
      ip_configuration -> 'requireSsl' is null
  EOQ
}
# Assessment Queries

query "gcp_sql_database_instance_encryption_status" {
  sql = <<-EOQ
    select
      encryption_status,
      count(*)
    from (
      select name,
        case when kms_key_name = '' then
          'disabled'
        else
          'enabled'
        end encryption_status
      from
        gcp_sql_database_instance) as c
    group by
      encryption_status
    order by
      encryption_status;
  EOQ
}

query "gcp_sql_database_instance_backup_status" {
  sql = <<-EOQ
    select
      backup_status,
      count(*)
    from (
      select name,
        case when backup_enabled then
          'disabled'
        else
          'enabled'
        end backup_status
      from
        gcp_sql_database_instance) as c
    group by
      backup_status
    order by
      backup_status;
  EOQ
}

query "gcp_sql_database_instance_point_in_time_recovery_status" {
  sql = <<-EOQ
    select
      point_in_time_recovery_status,
      count(*)
    from (
      select name,
        case when enable_point_in_time_recovery then
          'disabled'
        else
          'enabled'
        end point_in_time_recovery_status
      from
        gcp_sql_database_instance) as c
    group by
      point_in_time_recovery_status
    order by
      point_in_time_recovery_status;
  EOQ
}

query "gcp_sql_database_instance_public_access_status" {
  sql = <<-EOQ
    select
      public_access_status,
      count(*)
    from (
      select name,
        case when ip_configuration -> 'authorizedNetworks' @> '[{"name": "internet", "value": "0.0.0.0/0"}]' then
          'enabled'
        else
          'disabled'
        end public_access_status
      from
        gcp_sql_database_instance) as c
    group by
      public_access_status
    order by
      public_access_status;
  EOQ
}

query "gcp_sql_database_ssl_status" {
  sql = <<-EOQ
    select
      ssl_status,
      count(*)
    from (
      select name,
        case when ip_configuration -> 'requireSsl' is null then
          'disabled'
        else
          'enabled'
        end ssl_status
      from
        gcp_sql_database_instance) as c
    group by
      ssl_status
    order by
      ssl_status;
  EOQ
}

# Analysis Queries

query "gcp_sql_database_instance_by_project" {
  sql = <<-EOQ
    select
      p.title as "project",
      count(i.*) as "total"
    from
      gcp_sql_database_instance as i,
      gcp_project as p
    where
      p.project_id = i.project
    group by
      p.title
    order by count(i.*) desc;
  EOQ
}

query "gcp_sql_database_instance_by_location" {
  sql = <<-EOQ
    select
      location,
      count(i.*) as total
    from
      gcp_sql_database_instance as i
    group by
      location;
  EOQ
}

query "gcp_sql_database_instance_by_state" {
  sql = <<-EOQ
    select
      state,
      count(state)
    from
      gcp_sql_database_instance
    group by
      state;
  EOQ
}

query "gcp_sql_database_instance_by_replica" {
  sql = <<-EOQ
    select
      name,
      jsonb_array_length(replica_names) as replica_count
    from
      gcp_sql_database_instance
    where 
      master_instance_name = '';
  EOQ
}