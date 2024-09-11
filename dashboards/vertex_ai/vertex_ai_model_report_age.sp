dashboard "vertex_ai_model_age_report" {

  title         = "GCP Vertex AI Model Age Report"
  documentation = file("./dashboards/vertex_ai/docs/vertex_ai_model_report_age.md")

  tags = merge(local.vertex_ai_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.vertex_ai_model_total_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.vertex_ai_model_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.vertex_ai_model_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.vertex_ai_model_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.vertex_ai_model_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.vertex_ai_model_1_year_count
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
      display = "none"
    }

    query = query.vertex_ai_model_age_table
  }

}

### Queries

query "vertex_ai_model_total_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Total' as label
    from
      gcp_vertex_ai_model;
  EOQ
}

query "vertex_ai_model_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_vertex_ai_model
    where
      create_time > now() - '1 days' :: interval;
  EOQ
}

query "vertex_ai_model_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_vertex_ai_model
    where
      create_time between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "vertex_ai_model_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_vertex_ai_model
    where
      create_time between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "vertex_ai_model_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_vertex_ai_model
    where
      create_time between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "vertex_ai_model_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_vertex_ai_model
    where
      create_time <= now() - '1 year' :: interval;
  EOQ
}

query "vertex_ai_model_age_table" {
  sql = <<-EOQ
    select
      m.name as "Name",
      m.display_name as "Display Name",
      now()::date - m.create_time::date as "Age in Days",
      m.create_time as "Create Time",
      p.name as "Project",
      p.project_id as "Project ID",
      m.location as "Location"
    from
      gcp_vertex_ai_model as m,
      gcp_project as p
    where
      p.project_id = m.project
    order by
      m.create_time,
      m.name;
  EOQ
}