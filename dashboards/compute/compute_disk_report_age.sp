dashboard "gcp_compute_disk_age_report" {

  title         = "GCP Compute Disk Age Report"
  documentation = file("./dashboards/compute/docs/compute_disk_report_age.md")

  tags = merge(local.compute_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.gcp_compute_disk_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_compute_disk_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_compute_disk_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_compute_disk_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.gcp_compute_disk_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.gcp_compute_disk_1_year_count
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
      href = "${dashboard.gcp_compute_disk_detail.url_path}?input.disk_id={{.ID | @uri}}"
    }

    query = query.gcp_compute_disk_age_table
  }

}

query "gcp_compute_disk_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_compute_disk
    where
      creation_timestamp > now() - '1 days' :: interval;
  EOQ
}

query "gcp_compute_disk_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_compute_disk
    where
      creation_timestamp between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "gcp_compute_disk_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_compute_disk
    where
      creation_timestamp between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "gcp_compute_disk_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_compute_disk
    where
      creation_timestamp between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "gcp_compute_disk_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_compute_disk
    where
      creation_timestamp <= now() - '1 year' :: interval;
  EOQ
}

query "gcp_compute_disk_age_table" {
  sql = <<-EOQ
    select
      d.name as "Name",
      d.id as "ID",
      now()::date - d.creation_timestamp::date as "Age in Days",
      d.creation_timestamp as "Create Time",
      d.status as "Status",
      p.name as "Project",
      p.project_id as "Project ID",
      d.location as "Location",
      d.self_link as "Self-Link"
    from
      gcp_compute_disk as d,
      gcp_project as p
    where
      p.project_id = d.project
    order by
      d.name;
  EOQ
}

