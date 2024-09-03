dashboard "bigquery_table_age_report" {

  title         = "GCP BigQuery Table Age Report"
  documentation = file("./dashboards/bigquery/docs/bigquery_table_report_age.md")

  tags = merge(local.bigquery_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.bigquery_table_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.bigquery_table_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.bigquery_table_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.bigquery_table_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.bigquery_table_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.bigquery_table_1_year_count
    }

  }

  table {
    column "Project ID" {
      display = "none"
    }

    column "Self-Link" {
      display = "none"
    }

    column "ID" {
      href = "${dashboard.bigquery_table_detail.url_path}?input.table_id={{.ID | @uri}}"
    }

    query = query.bigquery_table_age_table
  }

}

# Card Queries

query "bigquery_table_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_bigquery_table
    where
      creation_time > now() - '1 days' :: interval;
  EOQ
}

query "bigquery_table_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_bigquery_table
    where
      creation_time between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "bigquery_table_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_bigquery_table
    where
      creation_time between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "bigquery_table_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_bigquery_table
    where
      creation_time between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "bigquery_table_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_bigquery_table
    where
      creation_time <= now() - '1 year' :: interval;
  EOQ
}

# Table Query

query "bigquery_table_age_table" {
  sql = <<-EOQ
    select
      t.id::text as "ID",
      now()::date - t.creation_time::date as "Age in Days",
      t.creation_time as "Create Time",
      t.location as "Location",
      t.project as "Project",
      t.project as "Project ID",
      t.self_link as "Self-Link"
    from
      gcp_bigquery_table as t
    order by
      t.creation_time,
      t.name;
  EOQ
}