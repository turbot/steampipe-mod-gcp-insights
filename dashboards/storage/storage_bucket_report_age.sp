dashboard "gcp_storage_bucket_age_report" {

  title         = "GCP Storage Bucket Age Report"
  documentation = file("./dashboards/storage/docs/storage_bucket_report_age.md")

  tags = merge(local.storage_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.gcp_storage_bucket_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_storage_bucket_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_storage_bucket_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_storage_bucket_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.gcp_storage_bucket_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.gcp_storage_bucket_1_year_count
    }

  }

  table {
    column "Project ID" {
      display = "none"
    }

    column "Self-Link" {
      display = "none"
    }

    query = query.gcp_storage_bucket_age_table
  }

}

query "gcp_storage_bucket_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_storage_bucket
    where
      time_created > now() - '1 days' :: interval;
  EOQ
}

query "gcp_storage_bucket_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_storage_bucket
    where
      time_created between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "gcp_storage_bucket_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_storage_bucket
    where
      time_created between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "gcp_storage_bucket_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_storage_bucket
    where
      time_created between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "gcp_storage_bucket_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_storage_bucket
    where
      time_created <= now() - '1 year' :: interval;
  EOQ
}

query "gcp_storage_bucket_age_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      now()::date - b.time_created::date as "Age in Days",
      b.time_created as "Create Time",
      p.name as "Project",
      p.project_id as "Project ID",
      b.location as "Location",
      b.self_link as "Self-Link"
    from
      gcp_storage_bucket as b,
      gcp_project as p
    where
      p.project_id = b.project
    order by
      b.name;
  EOQ
}

