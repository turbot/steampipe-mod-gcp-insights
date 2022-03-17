dashboard "gcp_storage_bucket_dashboard" {

  title         = "GCP Storage Bucket Dashboard"
  documentation = file("./dashboards/storage/docs/storage_bucket_dashboard.md")

  tags = merge(local.storage_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.gcp_storage_bucket_count
      width = 2
    }

    card {
      query = query.gcp_storage_bucket_public_access_count
      width = 2
    }

    # Assessments
    card {
      query = query.gcp_storage_bucket_versioning_disabled_count
      width = 2
    }

    card {
      query = query.gcp_storage_bucket_no_retention_policy_count
      width = 2
    }

    card {
      query = query.gcp_storage_bucket_logging_disabled_count
      width = 2
    }

    card {
      query = query.gcp_storage_bucket_uniform_bucket_level_access_disabled_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Public/Private"
      query = query.gcp_storage_bucket_by_public_access
      type  = "donut"
      width = 4

      series "count" {
        point "private" {
          color = "ok"
        }
        point "public" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Versioning Status"
      query = query.gcp_storage_bucket_versioning_status
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
      title = "Retention Policy Status"
      query = query.gcp_storage_bucket_retention_policy_status
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
      title = "Logging Status"
      query = query.gcp_storage_bucket_logging_status
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
      title = "Uniform Bucket Level Access"
      query = query.gcp_storage_bucket_uniform_bucket_level_access_status
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
      title = "Buckets by Project"
      query = query.gcp_storage_bucket_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Buckets by Location"
      query = query.gcp_storage_bucket_by_location
      type  = "column"
      width = 4
    }

    chart {
      title = "Buckets by Age"
      query = query.gcp_storage_bucket_by_creation_month
      type  = "column"
      width = 4
    }

    chart {
      title = "Buckets by Storage Class"
      query = query.gcp_storage_bucket_by_storage_class
      type  = "column"
      width = 4
    }

    chart {
      title = "Buckets by Encryption Type"
      query = query.gcp_storage_bucket_by_encryption_type
      type  = "column"
      width = 4
    }
  }

}

# Card Queries

query "gcp_storage_bucket_count" {
  sql = <<-EOQ
    select count(*) as "Buckets" from gcp_storage_bucket;
  EOQ
}

query "gcp_storage_bucket_public_access_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_storage_bucket
    where
      iam_policy ->> 'bindings' like any (array ['%allAuthenticatedUsers%','%allUsers%']);
  EOQ
}

query "gcp_storage_bucket_versioning_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Versioning Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_storage_bucket
    where
      not versioning_enabled;
  EOQ
}

query "gcp_storage_bucket_no_retention_policy_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'No Retention Policy' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_storage_bucket
    where
      retention_policy is null;
  EOQ
}

query "gcp_storage_bucket_logging_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Logging Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_storage_bucket
    where
      log_bucket is null;
  EOQ
}

query "gcp_storage_bucket_uniform_bucket_level_access_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Uniform Access Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_storage_bucket
    where
      not iam_configuration_uniform_bucket_level_access_enabled;
  EOQ
}

# Assessment Queries

query "gcp_storage_bucket_by_public_access" {
  sql = <<-EOQ
    with bucket_access as (
      select
        case
          when iam_policy ->> 'bindings' like any (array   ['%allAuthenticatedUsers%','%allUsers%']) then 'public'
          else 'private'
        end as bucket_access_status
      from
        gcp_storage_bucket
      )
    select
      bucket_access_status,
      count(*)
    from
      bucket_access
    group by
      bucket_access_status;
  EOQ
}

query "gcp_storage_bucket_versioning_status" {
  sql = <<-EOQ
    with buckets as (
      select
        case
          when versioning_enabled then 'enabled'
          else 'disabled'
        end as versioning_enabled_status
      from
        gcp_storage_bucket
    )
    select
      versioning_enabled_status,
      count(*)
    from
      buckets
    group by
      versioning_enabled_status;
  EOQ
}

query "gcp_storage_bucket_retention_policy_status" {
  sql = <<-EOQ
    with buckets as (
      select
        case
          when retention_policy is null then 'disabled'
          else 'enabled'
        end as retention_policy_status
      from
        gcp_storage_bucket
    )
    select
      retention_policy_status,
      count(*)
    from
      buckets
    group by
      retention_policy_status;
  EOQ
}

query "gcp_storage_bucket_logging_status" {
  sql = <<-EOQ
    with buckets as (
      select
        case
          when log_bucket is null then 'disabled'
          else 'enabled'
        end as logging_status
      from
        gcp_storage_bucket
    )
    select
      logging_status,
      count(*)
    from
      buckets
    group by
      logging_status;
  EOQ
}

query "gcp_storage_bucket_uniform_bucket_level_access_status" {
  sql = <<-EOQ
    with buckets as (
      select
        case
          when iam_configuration_uniform_bucket_level_access_enabled then 'enabled'
          else 'disabled'
        end as bucket_access_status
      from
        gcp_storage_bucket
    )
    select
      bucket_access_status,
      count(*)
    from
      buckets
    group by
      bucket_access_status;
  EOQ
}

# Analysis Queries

query "gcp_storage_bucket_by_project" {
  sql = <<-EOQ
    select
      p.title as "project",
      count(b.*) as "total"
    from
      gcp_storage_bucket as b,
      gcp_project as p
    where
      p.project_id = b.project
    group by
      p.title
    order by count(b.*) desc;
  EOQ
}

query "gcp_storage_bucket_by_location" {
  sql = <<-EOQ
    select
      location,
      count(b.*) as total
    from
      gcp_storage_bucket as b
    group by
      location;
  EOQ
}

query "gcp_storage_bucket_by_storage_class" {
  sql = <<-EOQ
    select
      storage_class,
      count(storage_class)
    from
      gcp_storage_bucket
    group by
      storage_class;
  EOQ
}

query "gcp_storage_bucket_by_creation_month" {
  sql = <<-EOQ
    with buckets as (
      select
        title,
        time_created,
        to_char(time_created,
          'YYYY-MM') as creation_month
      from
        gcp_storage_bucket
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
        (
        select 
          min(time_created)
        from buckets)),
        date_trunc('month',
          current_date),
        interval '1 month') as d
    ),
    buckets_by_month as (
      select
        creation_month,
        count(*)
      from
        buckets
      group by
        creation_month
    )
    select
      months.month,
      buckets_by_month.count
    from
      months
      left join buckets_by_month on months.month = buckets_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "gcp_storage_bucket_by_encryption_type" {
  sql = <<-EOQ
    with bucket_encryption_status as (
      select
        case 
          when default_kms_key_name is null then 'google-managed'
          else 'customer-managed'
        end as encryption_status
      from
        gcp_storage_bucket
    )
    select
      encryption_status,
      count(*)
    from
      bucket_encryption_status
    group by
      encryption_status;
  EOQ
}


