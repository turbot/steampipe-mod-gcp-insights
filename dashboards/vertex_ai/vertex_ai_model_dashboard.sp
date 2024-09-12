dashboard "vertex_ai_model_dashboard" {

  title         = "GCP Vertex AI Model Dashboard"
  documentation = file("./dashboards/vertex_ai/docs/vertex_ai_model_dashboard.md")

  tags = merge(local.vertex_ai_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.vertex_ai_model_count
      width = 2
    }

    card {
      query = query.vertex_ai_model_with_encryption_count
      width = 2
    }

    card {
      query = query.vertex_ai_model_with_deployed_models_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Encryption Status"
      query = query.vertex_ai_model_encryption_status
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
      title = "Model Status"
      query = query.vertex_ai_model_deployed_status
      type  = "donut"
      width = 3

      series "count" {
        point "deployed" {
          color = "ok"
        }
        point "not deployed" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Explanation Spec Status"
      query = query.vertex_ai_model_explanation_spec_status
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
      title = "Models by Project"
      query = query.vertex_ai_model_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Models by Endpoint"
      query = query.vertex_ai_model_by_endpoint
      type  = "column"
      width = 4
    }

    chart {
      title = "Models by Version"
      query = query.vertex_ai_model_by_version
      type  = "column"
      width = 4
    }

    chart {
      title = "Models by Version Update Time"
      query = query.vertex_ai_model_by_version_update_time
      type  = "column"
      width = 4
    }

    chart {
      title = "Models by Location"
      query = query.vertex_ai_model_by_location
      type  = "column"
      width = 4
    }

    chart {
      title = "Models by Creation Date"
      query = query.vertex_ai_model_by_creation_date
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "vertex_ai_model_count" {
  sql = <<-EOQ
    select count(*) as "Models" from gcp_vertex_ai_model;
  EOQ
}

query "vertex_ai_model_with_encryption_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Encryption' as label,
      case when encryption_spec is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_model
    group by
      encryption_spec;
  EOQ
}

query "vertex_ai_model_with_deployed_models_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Deployed Models' as label,
      case when deployed_models is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_model
    group by
      deployed_models;
  EOQ
}

query "vertex_ai_model_with_versions_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Model Versions' as label,
      case when version_id is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_model
    group by
      version_id;
  EOQ
}

query "vertex_ai_model_with_explanation_spec_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Explanation Spec Configured' as label,
      case when explanation_spec is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_model
    group by
      explanation_spec;
  EOQ
}

# Assessment Queries

query "vertex_ai_model_encryption_status" {
  sql = <<-EOQ
    select
      case when encryption_spec is not null then 'enabled' else 'disabled' end as "status",
      count(*) as "count"
    from
      gcp_vertex_ai_model
    group by
      status;
  EOQ
}

query "vertex_ai_model_deployed_status" {
  sql = <<-EOQ
    select
      case when deployed_models is not null then 'deployed' else 'not deployed' end as "status",
      count(*) as "count"
    from
      gcp_vertex_ai_model
    group by
      status;
  EOQ
}

query "vertex_ai_model_explanation_spec_status" {
  sql = <<-EOQ
    select
      case when explanation_spec is not null then 'configured' else 'not configured' end as "status",
      count(*) as "count"
    from
      gcp_vertex_ai_model
    group by
      status;
  EOQ
}

# Analysis Queries

query "vertex_ai_model_by_project" {
  sql = <<-EOQ
    select
      project as "Project",
      count(*) as "total"
    from
      gcp_vertex_ai_model
    group by
      project
    order by count(*) desc;
  EOQ
}

query "vertex_ai_model_by_endpoint" {
  sql = <<-EOQ
    select
      e.display_name as "Model Name",
      count(dm) as "Endpoint Count"
    from
      gcp_vertex_ai_model e,
      jsonb_array_elements(e.deployed_models) as dm
    group by
      e.display_name
    order by
      "Endpoint Count" desc;
  EOQ
}

query "vertex_ai_model_by_location" {
  sql = <<-EOQ
    select
      location as "Location",
      count(*) as "total"
    from
      gcp_vertex_ai_model
    group by
      location;
  EOQ
}

query "vertex_ai_model_by_version" {
  sql = <<-EOQ
    select
      version_id as "Version",
      count(*) as "total"
    from
      gcp_vertex_ai_model
    group by
      version_id;
  EOQ
}

query "vertex_ai_model_by_version_update_time" {
  sql = <<-EOQ
    select
      date_trunc('month', version_update_time) as "Update Month",
      count(*) as "total"
    from
      gcp_vertex_ai_model
    group by
      "Update Month"
    order by
      "Update Month";
  EOQ
}

query "vertex_ai_model_by_creation_date" {
  sql = <<-EOQ
    select
      date_trunc('month', create_time) as "Creation Month",
      count(*) as "total"
    from
      gcp_vertex_ai_model
    group by
      "Creation Month"
    order by
      "Creation Month";
  EOQ
}