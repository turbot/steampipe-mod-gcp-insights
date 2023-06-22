dashboard "service_account_key_age_report" {

  title         = "GCP IAM Service Account Key Age Report"
  documentation = file("./dashboards/iam/docs/iam_service_account_key_report_age.md")

  tags = merge(local.iam_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      width = 2
      sql   = query.service_account_key_count.sql
    }

    card {
      type  = "info"
      width = 2
      sql   = query.service_account_key_24_hours_count.sql
    }

    card {
      type  = "info"
      width = 2
      sql   = query.service_account_key_30_days_count.sql
    }

    card {
      type  = "info"
      width = 2
      sql   = query.service_account_key_30_90_days_count.sql
    }

    card {
      width = 2
      type  = "info"
      sql   = query.service_account_key_90_365_days_count.sql
    }

    card {
      width = 2
      type  = "info"
      sql   = query.service_account_key_1_year_count.sql
    }

  }

  table {
    column "Project ID" {
      display = "none"
    }

    sql = query.service_account_key_age_table.sql
  }

}

query "service_account_key_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Service Account Keys' as label
    from
      gcp_service_account_key;
  EOQ
}

query "service_account_key_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_service_account_key
    where
      valid_after_time > now() - '1 days' :: interval;
  EOQ
}

query "service_account_key_30_days_count" {
  sql = <<-EOQ
     select
        count(*) as value,
        '1-30 Days' as label
      from
        gcp_service_account_key
      where
        valid_after_time between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "service_account_key_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_service_account_key
    where
      valid_after_time between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "service_account_key_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_service_account_key
    where
      valid_after_time between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "service_account_key_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_service_account_key
    where
      valid_after_time <= now() - '1 year' :: interval;
  EOQ
}

query "service_account_key_age_table" {
  sql = <<-EOQ
    select
      k.name as "Key Name",
      k.service_account_name as "Service Account Name",
      now()::date - k.valid_after_time::date as "Age in Days",
      k.valid_after_time as "Create Date",
      p.name as "Project",
      k.key_type as "Key Type",
      p.project_id as "Project ID"
    from
      gcp_service_account_key as k,
      gcp_project as p
    where
      p.project_id = k.project
    order by
      k.valid_after_time,
      k.name,
      k.service_account_name;
  EOQ
}
