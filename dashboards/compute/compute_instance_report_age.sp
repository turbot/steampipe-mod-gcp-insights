dashboard "compute_instance_age_report" {

  title         = "GCP Compute Instance Age Report"
  documentation = file("./dashboards/compute/docs/compute_instance_report_age.md")

  tags = merge(local.compute_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.compute_instance_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.compute_instance_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.compute_instance_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.compute_instance_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.compute_instance_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.compute_instance_1_year_count
    }

  }

  table {
    column "Project ID" {
      display = "none"
    }

    column "Self-Link" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.compute_instance_detail.url_path}?input.instance_id={{.ID | @uri}}"
    }

    query = query.compute_instance_age_table
  }

}

query "compute_instance_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_compute_instance
    where
      creation_timestamp > now() - '1 days' :: interval;
  EOQ
}

query "compute_instance_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_compute_instance
    where
      creation_timestamp between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "compute_instance_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_compute_instance
    where
      creation_timestamp between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "compute_instance_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_compute_instance
    where
      creation_timestamp between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "compute_instance_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_compute_instance
    where
      creation_timestamp <= now() - '1 year' :: interval;
  EOQ
}

query "compute_instance_age_table" {
  sql = <<-EOQ
    select
      i.name as "Name",
      i.id::text as "ID",
      now()::date - i.creation_timestamp::date as "Age in Days",
      i.creation_timestamp as "Create Time",
      i.status as "Status",
      p.name as "Project",
      p.project_id as "Project ID",
      i.location as "Location",
      i.self_link as "Self-Link"
    from
      gcp_compute_instance as i,
      gcp_project as p
    where
      p.project_id = i.project
    order by
      i.name;
  EOQ
}

