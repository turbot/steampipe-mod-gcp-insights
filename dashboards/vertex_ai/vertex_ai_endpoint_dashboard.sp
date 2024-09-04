dashboard "vertex_ai_endpoint_dashboard" {

  title         = "GCP Vertex AI Endpoint Dashboard"
  documentation = file("./dashboards/vertex_ai/docs/vertex_ai_endpoint_dashboard.md")

  tags = merge(local.vertex_ai_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.gcp_vertex_ai_endpoint_count
      width = 2
    }

    card {
      query = query.gcp_vertex_ai_endpoint_private_service_connect_count
      width = 2
    }

    card {
      query = query.gcp_vertex_ai_endpoint_with_monitoring_count
      width = 2
    }

    card {
      query = query.gcp_vertex_ai_endpoint_with_encryption_count
      width = 2
    }

    card {
      query = query.gcp_vertex_ai_endpoint_traffic_split_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Private Service Connect Status"
      query = query.gcp_vertex_ai_endpoint_private_service_connect_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Endpoint Monitoring Status"
      query = query.gcp_vertex_ai_endpoint_monitoring_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Encryption Status"
      query = query.gcp_vertex_ai_endpoint_encryption_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Traffic Split Configurations"
      query = query.gcp_vertex_ai_endpoint_traffic_split_status
      type  = "donut"
      width = 3

      series "count" {
        point "configured" {
          color = "ok"
        }
        point "not configured" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Endpoints by Project"
      query = query.gcp_vertex_ai_endpoint_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Endpoints by Location"
      query = query.gcp_vertex_ai_endpoint_by_location
      type  = "column"
      width = 4
    }

    chart {
      title = "Endpoints by Creation Date"
      query = query.gcp_vertex_ai_endpoint_by_creation_date
      type  = "column"
      width = 4
    }

    chart {
      title = "Endpoints by Update Date"
      query = query.gcp_vertex_ai_endpoint_by_update_date
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "gcp_vertex_ai_endpoint_count" {
  sql = <<-EOQ
    select count(*) as "Endpoints" from gcp_vertex_ai_endpoint;
  EOQ
}

query "gcp_vertex_ai_endpoint_private_service_connect_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Private Service Connect Enabled' as label,
      case when enable_private_service_connect then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_endpoint
    group by
      enable_private_service_connect;
  EOQ
}

query "gcp_vertex_ai_endpoint_with_monitoring_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Monitoring Enabled' as label,
      case when model_deployment_monitoring_job is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_endpoint
    group by
      model_deployment_monitoring_job;
  EOQ
}

query "gcp_vertex_ai_endpoint_with_encryption_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unencrypted' as label,
      case when encryption_spec is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_endpoint
    group by
      encryption_spec;
  EOQ
}

query "gcp_vertex_ai_endpoint_traffic_split_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Traffic Split Configured' as label,
      case when traffic_split is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_endpoint
    group by
      traffic_split;
  EOQ
}

# Assessment Queries

query "gcp_vertex_ai_endpoint_private_service_connect_status" {
  sql = <<-EOQ
    select
      case when enable_private_service_connect then 'enabled' else 'disabled' end as "status",
      count(*) as "count"
    from
      gcp_vertex_ai_endpoint
    group by
      status;
  EOQ
}

query "gcp_vertex_ai_endpoint_monitoring_status" {
  sql = <<-EOQ
    select
      case when model_deployment_monitoring_job is not null then 'enabled' else 'disabled' end as "status",
      count(*) as "count"
    from
      gcp_vertex_ai_endpoint
    group by
      status;
  EOQ
}

query "gcp_vertex_ai_endpoint_encryption_status" {
  sql = <<-EOQ
    select
      case when encryption_spec is not null then 'enabled' else 'disabled' end as "status",
      count(*) as "count"
    from
      gcp_vertex_ai_endpoint
    group by
      status;
  EOQ
}

query "gcp_vertex_ai_endpoint_traffic_split_status" {
  sql = <<-EOQ
    select
      case when traffic_split is not null then 'configured' else 'not configured' end as "status",
      count(*) as "count"
    from
      gcp_vertex_ai_endpoint
    group by
      status;
  EOQ
}

# Analysis Queries

query "gcp_vertex_ai_endpoint_by_project" {
  sql = <<-EOQ
    select
      project as "Project",
      count(*) as "total"
    from
      gcp_vertex_ai_endpoint
    group by
      project
    order by count(*) desc;
  EOQ
}

query "gcp_vertex_ai_endpoint_by_location" {
  sql = <<-EOQ
    select
      location as "Location",
      count(*) as "total"
    from
      gcp_vertex_ai_endpoint
    group by
      location;
  EOQ
}

query "gcp_vertex_ai_endpoint_by_creation_date" {
  sql = <<-EOQ
    select
      date_trunc('month', create_time) as "Creation Month",
      count(*) as "total"
    from
      gcp_vertex_ai_endpoint
    group by
      "Creation Month"
    order by
      "Creation Month";
  EOQ
}

query "gcp_vertex_ai_endpoint_by_update_date" {
  sql = <<-EOQ
    select
      date_trunc('month', update_time) as "Update Month",
      count(*) as "total"
    from
      gcp_vertex_ai_endpoint
    group by
      "Update Month"
    order by
      "Update Month";
  EOQ
}