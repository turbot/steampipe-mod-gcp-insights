dashboard "dataplex_task_age_report" {

  title         = "GCP Dataplex Task Age Report"
  documentation = file("./dashboards/dataplex/docs/dataplex_task_report_age.md")

  tags = merge(local.dataplex_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.dataplex_task_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.dataplex_task_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.dataplex_task_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.dataplex_task_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.dataplex_task_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.dataplex_task_1_year_count
    }

  }

  table {
    column "Project ID" {
      display = "none"
    }

    column "Self-Link" {
      display = "none"
    }

    query = query.dataplex_task_age_table
  }

}

query "dataplex_task_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_dataplex_task
    where
      create_time > now() - '1 days' :: interval;
  EOQ
}

query "dataplex_task_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_dataplex_task
    where
      create_time between now() - '30 days'::interval and now();
  EOQ
}

query "dataplex_task_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_dataplex_task
    where
      create_time between now() - '90 days'::interval and now() - '30 days'::interval;
  EOQ
}

query "dataplex_task_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_dataplex_task
    where
      create_time between now() - '365 days'::interval and now() - '90 days'::interval;
  EOQ
}

query "dataplex_task_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_dataplex_task
    where
      create_time <= now() - '1 year' :: interval;
  EOQ
}

query "dataplex_task_age_table" {
  sql = <<-EOQ
    select
      t.name as "Name",
      now()::date - t.create_time::date as "Age in Days",
      t.create_time as "Create Time",
      p.name as "Project",
      p.project_id as "Project ID",
      t.location as "Location",
      t.self_link as "Self-Link"
    from
      gcp_dataplex_task as t,
      gcp_project as p
    where
      p.project_id = t.project
    order by
      t.create_time,
      t.name;
  EOQ
}