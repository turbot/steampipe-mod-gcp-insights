dashboard "dataplex_lake_age_report" {

  title         = "GCP Dataplex Lake Age Report"
  documentation = file("./dashboards/dataplex/docs/dataplex_lake_report_age.md")

  tags = merge(local.dataplex_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.dataplex_lake_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.dataplex_lake_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.dataplex_lake_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.dataplex_lake_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.dataplex_lake_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.dataplex_lake_1_year_count
    }

  }

  table {
    column "Project ID" {
      display = "none"
    }

    column "Self-Link" {
      display = "none"
    }

    query = query.dataplex_lake_age_table
  }

}

query "dataplex_lake_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_dataplex_lake
    where
      create_time > now() - '1 days' :: interval;
  EOQ
}

query "dataplex_lake_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_dataplex_lake
    where
      create_time between now() - '30 days'::interval and now();
  EOQ
}

query "dataplex_lake_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_dataplex_lake
    where
      create_time between now() - '90 days'::interval and now() - '30 days'::interval;
  EOQ
}

query "dataplex_lake_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_dataplex_lake
    where
      create_time between now() - '365 days'::interval and now() - '90 days'::interval;
  EOQ
}

query "dataplex_lake_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_dataplex_lake
    where
      create_time <= now() - '1 year' :: interval;
  EOQ
}

query "dataplex_lake_age_table" {
  sql = <<-EOQ
    select
      l.name as "Name",
      now()::date - l.create_time::date as "Age in Days",
      l.create_time as "Create Time",
      p.name as "Project",
      p.project_id as "Project ID",
      l.location as "Location",
      l.self_link as "Self-Link"
    from
      gcp_dataplex_lake as l,
      gcp_project as p
    where
      p.project_id = l.project
    order by
      l.create_time,
      l.name;
  EOQ
}