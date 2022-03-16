dashboard "gcp_kms_key_age_report" {

  title         = "GCP KMS Key Age Report"
  documentation = file("./dashboards/kms/docs/kms_key_report_age.md")

  tags = merge(local.kms_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.gcp_kms_key_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_kms_key_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_kms_key_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_kms_key_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.gcp_kms_key_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.gcp_kms_key_1_year_count
    }

  }

  table {
    column "Project ID" {
      display = "none"
    }

    column "Self-Link" {
      display = "none"
    }

    query = query.gcp_kms_key_age_table
  }

}

query "gcp_kms_key_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_kms_key
    where
      create_time > now() - '1 days' :: interval;
  EOQ
}

query "gcp_kms_key_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_kms_key
    where
      create_time between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "gcp_kms_key_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_kms_key
    where
      create_time between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "gcp_kms_key_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_kms_key
    where
      create_time between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "gcp_kms_key_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_kms_key
    where
      create_time <= now() - '1 year' :: interval;
  EOQ
}

query "gcp_kms_key_age_table" {
  sql = <<-EOQ
    select
      k.name as "Name",
      k.key_ring_name as "Key Ring Name",
      now()::date - k.create_time::date as "Age in Days",
      k.create_time as "Create Time",
      p.name as "Project",
      p.project_id as "Project ID",
      k.location as "Location",
      k.self_link as "Self-Link"
    from
      gcp_kms_key as k,
      gcp_project as p
    where
      p.project_id = k.project
    order by
      k.name;
  EOQ
}

