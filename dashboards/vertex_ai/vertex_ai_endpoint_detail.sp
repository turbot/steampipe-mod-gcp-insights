dashboard "vertex_ai_endpoint_detail" {

  title         = "GCP Vertex AI Endpoint Detail"
  documentation = file("./dashboards/vertex_ai/docs/vertex_ai_endpoint_detail.md")

  tags = merge(local.vertex_ai_common_tags, {
    type = "Detail"
  })

  input "endpoint_id" {
    title = "Select an endpoint:"
    query = query.vertex_ai_endpoint_input
    width = 4
  }

  container {
    width = 12
    card {
      query = query.vertex_ai_endpoint_private_service_connect_status
      width = 3
      args  = [self.input.endpoint_id.value]
    }

    card {
      query = query.vertex_ai_endpoint_monitoring_status
      width = 3
      args  = [self.input.endpoint_id.value]
    }

    card {
      query = query.vertex_ai_endpoint_encryption_status
      width = 3
      args  = [self.input.endpoint_id.value]
    }

    card {
      query = query.vertex_ai_endpoint_traffic_split_config
      width = 3
      args  = [self.input.endpoint_id.value]
    }
  }

  with "vertex_ai_models_for_vertex_ai_endpoint" {
    query = query.vertex_ai_models_for_vertex_ai_endpoint
    args  = [self.input.endpoint_id.value]
  }

  with "kms_keys_for_vertex_ai_enpoint" {
    query = query.kms_keys_for_vertex_ai_enpoint
    args  = [self.input.endpoint_id.value]
  }

  with "compute_networks_for_vertex_ai_enpoint" {
    query = query.compute_networks_for_vertex_ai_enpoint
    args  = [self.input.endpoint_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.vertex_ai_endpoint
        args = {
          vertex_ai_endpoint_ids = [self.input.endpoint_id.value]
        }
      }

      node {
        base = node.vertex_ai_model
        args = {
          vertex_ai_model_ids = with.vertex_ai_models_for_vertex_ai_endpoint.rows[*].name
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = with.kms_keys_for_vertex_ai_enpoint.rows[*].self_link
        }
      }

      node {
        base = node.compute_network
        args = {
          compute_network_ids = with.compute_networks_for_vertex_ai_enpoint.rows[*].network_id
        }
      }

      edge {
        base = edge.vertex_ai_endpoint_to_vertex_ai_model
        args = {
          vertex_ai_endpoint_ids = [self.input.endpoint_id.value]
        }
      }

      edge {
        base = edge.vertex_ai_endpoint_to_kms_key
        args = {
          vertex_ai_endpoint_ids = [self.input.endpoint_id.value]
        }
      }

      edge {
        base = edge.vertex_ai_endpoint_to_compute_network
        args = {
          vertex_ai_endpoint_ids = [self.input.endpoint_id.value]
        }
      }
    }

  }

  container {

    container {
      width = 12

      table {
        title = "Overview"
        type  = "line"
        width = 3
        query = query.vertex_ai_endpoint_overview
        args  = [self.input.endpoint_id.value]
      }

      table {
        title = "Tags"
        width = 3
        query = query.vertex_ai_endpoint_labels
        args  = [self.input.endpoint_id.value]
      }

      table {
        title = "Encryption Details"
        width = 6
        query = query.vertex_ai_endpoint_encryption
        args  = [self.input.endpoint_id.value]
      }

    }

    container {
      width = 12

      table {
        title = "Deployed Models"
        width = 12
        query = query.vertex_ai_endpoint_deployed_models
        args  = [self.input.endpoint_id.value]
      }

      table {
        title = "Traffic Split"
        width = 12
        query = query.vertex_ai_endpoint_traffic_split
        args  = [self.input.endpoint_id.value]
      }
    }
  }
}

# Input query to select an endpoint
query "vertex_ai_endpoint_input" {
  sql = <<-EOQ
    select
      name as label,
      name || '/' || project as value,
      json_build_object(
        'project', project,
        'location', location
      ) as tags
    from
      gcp_vertex_ai_endpoint
    order by
      name;
  EOQ
}

# Card Queries

query "vertex_ai_endpoint_private_service_connect_status" {
  sql = <<-EOQ
    select
      case when enable_private_service_connect or network != '' then 'Enabled' else 'Disabled' end as value,
      'Private Service Connect' as label,
      case when enable_private_service_connect or network != '' then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_endpoint
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_endpoint_monitoring_status" {
  sql = <<-EOQ
    select
      case when model_deployment_monitoring_job != '' then 'Enabled' else 'Disabled' end as value,
      'Model Deployment Monitoring' as label,
      case when model_deployment_monitoring_job != '' then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_endpoint
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_endpoint_encryption_status" {
  sql = <<-EOQ
    select
      case when encryption_spec is not null then 'Enabled' else 'Disabled' end as value,
      'Encryption' as label,
      case when encryption_spec is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_endpoint
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_endpoint_traffic_split_config" {
  sql = <<-EOQ
    select
      case when traffic_split is not null then 'Configured' else 'Not Configured' end as value,
      'Traffic Split' as label,
      case when traffic_split is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_endpoint
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

# Table Queries

query "vertex_ai_endpoint_overview" {
  sql = <<-EOQ
      select
        name as "Name",
        create_time as "Create Time",
        title as "Title",
        location as "Location",
        project as "Project ID"
      from
        gcp_vertex_ai_endpoint
      where
        name = split_part($1, '/', 1)
        and project = split_part($1, '/', 2);
    EOQ
}

query "vertex_ai_endpoint_deployed_models" {
  sql = <<-EOQ
    select
      jsonb_array_elements(deployed_models) ->> 'model' as "Model Name",
      jsonb_array_elements(deployed_models) ->> 'display_name' as "Display Name",
      to_timestamp(
        (jsonb_array_elements(deployed_models) -> 'create_time' ->> 'seconds')::bigint
      ) as "Create Time",
      jsonb_array_elements(deployed_models) ->> 'model_version_id' as "Model Version ID",
      jsonb_array_elements(deployed_models) -> 'PredictionResources' -> 'DedicatedResources' -> 'machine_spec' ->> 'machine_type' as "Machine Type",
      (jsonb_array_elements(deployed_models) -> 'PredictionResources' -> 'DedicatedResources' ->> 'min_replica_count')::int as "Min Replica Count",
      (jsonb_array_elements(deployed_models) -> 'PredictionResources' -> 'DedicatedResources' ->> 'max_replica_count')::int as "Max Replica Count",
      (jsonb_array_elements(deployed_models) ->> 'enable_access_logging')::boolean as "Enable Access Logging"
    from
      gcp_vertex_ai_endpoint
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_endpoint_labels" {
  sql = <<-EOQ
    with jsondata as (
      select
        labels::json as labels
      from
        gcp_vertex_ai_endpoint
      where
        name = split_part($1, '/', 1)
        and project = split_part($1, '/', 2)
    )
    select
      key as "Key",
      value as "Value"
    from
      jsondata,
      json_each_text(labels)
    order by
      key;
  EOQ
}

query "vertex_ai_endpoint_traffic_split" {
  sql = <<-EOQ
    select
      name as "Model Name",
      key as "Model ID",
      value::int as "Traffic Percentage"
    from
      gcp_vertex_ai_endpoint,
      jsonb_each_text(traffic_split)
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_endpoint_encryption" {
  sql = <<-EOQ
    select
      kms.name as "KMS Key",
      kms.create_time as "KMS Key Creation Time",
      kms.rotation_period as "KMS Key Rotation Period",
      kms.key_ring_name as "KMS Key Ring Name"
    from
      gcp_vertex_ai_endpoint ve
    left join
      gcp_kms_key kms
    on
      (encryption_spec ->> 'kms_key_name') = replace(kms.self_link, 'https://cloudkms.googleapis.com/v1/', '')
    where
      ve.name = split_part($1, '/', 1)
      and ve.project = split_part($1, '/', 2);
  EOQ
}

## With Queries

query "vertex_ai_models_for_vertex_ai_endpoint" {
  sql = <<-EOQ
    select
      split_part(jsonb_array_elements(deployed_models) ->> 'model', '/models/', 2) || '/' || project as name
    from
      gcp_vertex_ai_endpoint
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "kms_keys_for_vertex_ai_enpoint" {
  sql = <<-EOQ
    select
      kms.self_link as self_link
    from
      gcp_vertex_ai_endpoint ve
      left join gcp_kms_key kms
    on
      (encryption_spec ->> 'kms_key_name') = replace(kms.self_link, 'https://cloudkms.googleapis.com/v1/', '')
    where
      ve.name = split_part($1, '/', 1)
      and ve.project = split_part($1, '/', 2);
  EOQ
}

query "compute_networks_for_vertex_ai_enpoint" {
  sql = <<-EOQ
    select
      n.id || '/' || n.project as network_id
    from
      gcp_vertex_ai_endpoint e
      left join gcp_compute_network n on split_part(e.network, '/networks/',2) = n.name
    where
      e.name = split_part($1, '/', 1)
      and e.project = split_part($1, '/', 2);
  EOQ
}