dashboard "composer_environment_age_report" {

  title         = "GCP Composer Environment Age Report"
  documentation = file("./dashboards/composer/docs/composer_environment_report_age.md")

  tags = merge(local.composer_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.composer_environment_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.composer_environment_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.composer_environment_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.composer_environment_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.composer_environment_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.composer_environment_1_year_count
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
      href = "${dashboard.composer_environment_detail.url_path}?input.environment_name={{.Name | @uri}}"
    }

    query = query.composer_environment_age_table
  }

}

query "composer_environment_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_composer_environment
    where
      create_time > now() - '1 days' :: interval;
  EOQ
}

query "composer_environment_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_composer_environment
    where
      create_time between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "composer_environment_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_composer_environment
    where
      create_time between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "composer_environment_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_composer_environment
    where
      create_time between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "composer_environment_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_composer_environment
    where
      create_time <= now() - '1 year' :: interval;
  EOQ
}

query "composer_environment_age_table" {
  sql = <<-EOQ
    select
      e.name as "Name",
      now()::date - e.create_time::date as "Age in Days",
      e.create_time as "Create Time",
      e.update_time as "Update Time",
      p.name as "Project",
      p.project_id as "Project ID",
      e.location as "Location"
    from
      gcp_composer_environment as e,
      gcp_project as p
    where
      p.project_id = e.project
    order by
      e.create_time,
      e.name;
  EOQ
}

