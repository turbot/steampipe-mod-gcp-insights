dashboard "composer_environment_dashboard" {

  title         = "GCP Composer Environment Dashboard"
  documentation = file("./dashboards/composer/docs/composer_environment_dashboard.md")

  tags = merge(local.composer_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.composer_environment_count
      width = 3
    }

    card {
      query = query.composer_environment_encryption_count
      width = 3
    }

    card {
      query = query.composer_environment_public_access_count
      width = 3
    }

    card {
      query = query.composer_environment_web_server_public_access_count
      width = 3
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Status"
      query = query.composer_environment_status
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
      title = "Encryption Status"
      query = query.composer_environment_encryption_status
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
      title = "Environments by Project"
      query = query.composer_environment_by_project
      type  = "column"
      width = 3
    }

    chart {
      title = "Environments by Location"
      query = query.composer_environment_by_location
      type  = "column"
      width = 3
    }

    chart {
      title = "Environments by State"
      query = query.composer_environment_by_state
      type  = "column"
      width = 3
    }

    chart {
      title = "Environments by Age"
      query = query.composer_environment_by_creation_month
      type  = "column"
      width = 3
    }

    chart {
      title = "Environments by Software Image Version"
      query = query.composer_environment_by_software_image_version
      type  = "column"
      width = 3
    }

    chart {
      title = "Environments by Size"
      query = query.composer_environment_by_environment_size
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "composer_environment_count" {
  sql = <<-EOQ
    select count(*) as "Environments" from gcp_composer_environment;
  EOQ
}

query "composer_environment_encryption_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_composer_environment
    where
      encryption_config ->> 'kmsKeyName' is not null;
  EOQ
}

query "composer_environment_public_access_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Public Access Enabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_composer_environment
    where
      private_environment_config -> 'privateClusterConfig' = '{}';
  EOQ
}

query "composer_environment_web_server_public_access_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Web Server Public Access Enabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_composer_environment
    where
      web_server_network_access_control->'allowedIpRanges' @> '[{"value": "0.0.0.0/0"}]'::jsonb
      and web_server_network_access_control->'allowedIpRanges' @> '[{"value": "::0/0"}]'::jsonb;
  EOQ
}

query "composer_environment_https_triggered_service_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'HTTPS Triggered Service' as label
    from
      gcp_composer_environment
    where
      event_trigger is null;
  EOQ
}

# Assessment Queries

query "composer_environment_encryption_status" {
  sql = <<-EOQ
    select
      encryption_status,
      count(*)
    from (
      select name,
        case when encryption_config ->> 'kmsKeyName' is not null then
          'enabled'
        else
          'disabled'
        end encryption_status
      from
        gcp_composer_environment) as c
    group by
      encryption_status
    order by
      encryption_status;
  EOQ
}

query "composer_environment_status" {
  sql = <<-EOQ
    select
      state,
      count(*)
    from (
      select name,
        case when state = 'RUNNING' then
          'running'
        else
          'not-running'
        end state
      from
        gcp_composer_environment) as c
    group by
      state
    order by
      state;
  EOQ
}


# Analysis Queries

query "composer_environment_by_project" {
  sql = <<-EOQ
    select
      p.title as "Project",
      count(i.*) as "total"
    from
      gcp_composer_environment as i,
      gcp_project as p
    where
      p.project_id = i.project
    group by
      p.title
    order by count(i.*) desc;
  EOQ
}

query "composer_environment_by_location" {
  sql = <<-EOQ
    select
      location,
      count(i.*) as total
    from
      gcp_composer_environment as i
    group by
      location;
  EOQ
}

query "composer_environment_by_state" {
  sql = <<-EOQ
    select
      state,
      count(state)
    from
      gcp_composer_environment
    group by
      state;
  EOQ
}

query "composer_environment_by_software_image_version" {
  sql = <<-EOQ
    select
      software_config ->> 'imageVersion',
      count(software_config ->> 'imageVersion')
    from
      gcp_composer_environment
    group by
      software_config ->> 'imageVersion';
  EOQ
}

query "composer_environment_by_environment_size" {
  sql = <<-EOQ
    select
      environment_size,
      count(environment_size)
    from
      gcp_composer_environment
    group by
      environment_size;
  EOQ
}

query "composer_environment_by_creation_month" {
  sql = <<-EOQ
    with environments as (
      select
        title,
        create_time,
        to_char(create_time,
          'YYYY-MM') as creation_month
      from
        gcp_composer_environment
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
        (
        select
          min(create_time)
        from environments)),
        date_trunc('month',
          current_date),
        interval '1 month') as d
    ),
    environments_by_month as (
      select
        creation_month,
        count(*)
      from
        environments
      group by
        creation_month
    )
    select
      months.month,
      environments_by_month.count
    from
      months
      left join environments_by_month on months.month = environments_by_month.creation_month
    order by
      months.month;
  EOQ
}