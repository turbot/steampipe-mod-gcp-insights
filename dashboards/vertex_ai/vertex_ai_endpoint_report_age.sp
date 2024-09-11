dashboard "vertex_ai_endpoint_age_report" {

  title         = "GCP Vertex AI Endpoint Age Report"
  documentation = file("./dashboards/vertex_ai/docs/vertex_ai_endpoint_report_age.md")

  tags = merge(local.vertex_ai_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.vertex_ai_endpoint_total_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.vertex_ai_endpoint_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.vertex_ai_endpoint_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.vertex_ai_endpoint_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.vertex_ai_endpoint_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.vertex_ai_endpoint_1_year_count
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

    column "Name" {
      href = "${dashboard.vertex_ai_endpoint_detail.url_path}?input.model_id={{.ID | @uri}}"
    }

    query = query.vertex_ai_endpoint_age_table
  }

}

### Queries
query "vertex_ai_endpoint_total_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Total' as label
    from
      gcp_vertex_ai_endpoint;
  EOQ
}

query "vertex_ai_endpoint_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_vertex_ai_endpoint
    where
      create_time > now() - '1 days' :: interval;
  EOQ
}

# Count for endpoints created in the last 30 days
query "vertex_ai_endpoint_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_vertex_ai_endpoint
    where
      create_time between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

# Count for endpoints created between 30 and 90 days
query "vertex_ai_endpoint_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_vertex_ai_endpoint
    where
      create_time between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

# Count for endpoints created between 90 days and 1 year
query "vertex_ai_endpoint_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_vertex_ai_endpoint
    where
      create_time between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

# Count for endpoints created more than 1 year ago
query "vertex_ai_endpoint_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_vertex_ai_endpoint
    where
      create_time <= now() - '1 year' :: interval;
  EOQ
}

# Table displaying the details of endpoints and their age
query "vertex_ai_endpoint_age_table" {
  sql = <<-EOQ
    select
      e.name as "Name",
      e.display_name as "Display Name",
      now()::date - e.create_time::date as "Age in Days",
      e.create_time as "Create Time",
      p.name as "Project",
      e.name || '/' || project as "ID",
      p.project_id as "Project ID",
      e.location as "Location"
    from
      gcp_vertex_ai_endpoint as e,
      gcp_project as p
    where
      p.project_id = e.project
    order by
      e.create_time,
      e.name;
  EOQ
}
