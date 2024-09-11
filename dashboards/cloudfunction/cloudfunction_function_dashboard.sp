dashboard "cloudfunctions_function_dashboard" {

  title         = "GCP Cloud Run function Dashboard"
  documentation = file("./dashboards/cloudfunction/docs/cloudfunctions_function_dashboard.md")

  tags = merge(local.cloudfunction_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.cloudfunctions_function_count
      width = 3
    }

    card {
      query = query.cloudfunctions_function_encryption_count
      width = 3
    }

    card {
      query = query.cloudfunctions_function_event_triggered_service_count
      width = 3
    }

    card {
      query = query.cloudfunctions_function_https_triggered_service_count
      width = 3
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Function Status"
      query = query.cloudfunctions_function_status
      type  = "donut"
      width = 3

      series "count" {
        point "active" {
          color = "ok"
        }
        point "in-active" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Function Encryption Status"
      query = query.cloudfunctions_function_encryption_status
      type  = "donut"
      width = 3

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
      title = "Functions by Project"
      query = query.cloudfunctions_function_by_project
      type  = "column"
      width = 3
    }

    chart {
      title = "Functions by Location"
      query = query.cloudfunctions_function_by_location
      type  = "column"
      width = 3
    }

    chart {
      title = "Functions by State"
      query = query.cloudfunctions_function_by_state
      type  = "column"
      width = 3
    }

    chart {
      title = "Functions by Runtime"
      query = query.cloudfunctions_function_by_runtime
      type  = "column"
      width = 3
    }

    chart {
      title = "Functions by Trigger"
      query = query.cloudfunctions_function_by_trigger
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "cloudfunctions_function_count" {
  sql = <<-EOQ
    select count(*) as "Functions" from gcp_cloudfunctions_function;
  EOQ
}

query "cloudfunctions_function_encryption_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Function Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_cloudfunctions_function
    where
      kms_key_name = '';
  EOQ
}


query "cloudfunctions_function_event_triggered_service_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Event Triggered Service' as label
    from
      gcp_cloudfunctions_function
    where
      event_trigger is not null;
  EOQ
}

query "cloudfunctions_function_https_triggered_service_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'HTTPS Triggered Service' as label
    from
      gcp_cloudfunctions_function
    where
      event_trigger is null;
  EOQ
}

# Assessment Queries

query "cloudfunctions_function_encryption_status" {
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
        gcp_cloudfunctions_function) as c
    group by
      encryption_status
    order by
      encryption_status;
  EOQ
}

query "cloudfunctions_function_status" {
  sql = <<-EOQ
    select
      status,
      count(*)
    from (
      select name,
        case when status = 'ACTIVE' then
          'active'
        else
          'in-active'
        end status
      from
        gcp_cloudfunctions_function) as c
    group by
      status
    order by
      status;
  EOQ
}


# Analysis Queries

query "cloudfunctions_function_by_project" {
  sql = <<-EOQ
    select
      p.title as "Project",
      count(i.*) as "total"
    from
      gcp_cloudfunctions_function as i,
      gcp_project as p
    where
      p.project_id = i.project
    group by
      p.title
    order by count(i.*) desc;
  EOQ
}

query "cloudfunctions_function_by_location" {
  sql = <<-EOQ
    select
      location,
      count(i.*) as total
    from
      gcp_cloudfunctions_function as i
    group by
      location;
  EOQ
}

query "cloudfunctions_function_by_state" {
  sql = <<-EOQ
    select
      status,
      count(status)
    from
      gcp_cloudfunctions_function
    group by
      status;
  EOQ
}

query "cloudfunctions_function_by_runtime" {
  sql = <<-EOQ
    select
      runtime,
      count(runtime)
    from
      gcp_cloudfunctions_function
    group by
      runtime;
  EOQ
}

query "cloudfunctions_function_by_trigger" {
  sql = <<-EOQ
    with trigger_type_count as (
      select
        case
          when event_trigger is not null then 'event_trigger' else 'https_trigger'
        end as trigger_type
      from
        gcp_cloudfunctions_function
    )
    select
      trigger_type,
      count(*)
    from
      trigger_type_count
    group by
      trigger_type;
  EOQ
}
