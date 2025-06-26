dashboard "kms_key_dashboard" {

  title         = "GCP KMS Key Dashboard"
  documentation = file("./dashboards/kms/docs/kms_key_dashboard.md")

  tags = merge(local.kms_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.kms_key_count
      width = 3
      href = dashboard.kms_key_inventory_report.url_path
    }

    card {
      query = query.kms_rotation_disabled_count
      width = 3
    }

  }

  container {

    title = "Assessments"
    width = 6

    chart {
      title = "Rotation Status"
      query = query.kms_key_rotation_status
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
      title = "Keys by Project"
      query = query.kms_key_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Keys by Location"
      query = query.kms_key_by_location
      type  = "column"
      width = 4
    }

    chart {
      title = "Keys by Age"
      query = query.kms_key_by_creation_month
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "kms_key_count" {
  sql = <<-EOQ
    select count(*) as "Keys" from gcp_kms_key;
  EOQ
}

query "kms_rotation_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Rotation Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_kms_key
    where
      rotation_period is null;
  EOQ
}

# Assessment Queries


query "kms_key_rotation_status" {
  sql = <<-EOQ
    select
      rotation_status,
      count(*)
    from (
      select
        case when rotation_period is null then
          'disabled'
        else
          'enabled'
        end rotation_status
      from
        gcp_kms_key
    ) as k
    group by
      rotation_status
    order by
      rotation_status desc;
  EOQ
}

# Analysis Queries

query "kms_key_by_project" {
  sql = <<-EOQ
    select
      p.title as "Project",
      count(k.*) as "total"
    from
      gcp_kms_key as k,
      gcp_project as p
    where
      p.project_id = k.project
    group by
      p.title
    order by count(k.*) desc;
  EOQ
}

query "kms_key_by_location" {
  sql = <<-EOQ
    select
      location,
      count(k.*) as total
    from
      gcp_kms_key as k
    group by
      location;
  EOQ
}

query "kms_key_by_creation_month" {
  sql = <<-EOQ
    with keys as (
      select
        title,
        create_time,
        to_char(create_time,
          'YYYY-MM') as creation_month
      from
        gcp_kms_key
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
        from keys)),
        date_trunc('month',
          current_date),
        interval '1 month') as d
    ),
    keys_by_month as (
      select
        creation_month,
        count(*)
      from
        keys
      group by
        creation_month
    )
    select
      months.month,
      keys_by_month.count
    from
      months
      left join keys_by_month on months.month = keys_by_month.creation_month
    order by
      months.month;
  EOQ
}
