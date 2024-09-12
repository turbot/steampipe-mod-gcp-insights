dashboard "vertex_ai_model_detail" {

  title         = "GCP Vertex AI Model Detail"
  documentation = file("./dashboards/vertex_ai/docs/vertex_ai_model_detail.md")

  tags = merge(local.vertex_ai_common_tags, {
    type = "Detail"
  })

  input "model_id" {
    title = "Select a model:"
    query = query.vertex_ai_model_input
    width = 4
  }

  container {
    width = 12
    card {
      query = query.vertex_ai_model_version
      width = 3
      args  = [self.input.model_id.value]
    }

    card {
      query = query.vertex_ai_model_source
      width = 3
      args  = [self.input.model_id.value]
    }

    card {
      query = query.vertex_ai_model_encryption_enabled
      width = 3
      args  = [self.input.model_id.value]
    }

    card {
      query = query.vertex_ai_model_deployment_status
      width = 3
      args  = [self.input.model_id.value]
    }
  }

  with "kms_keys_for_vertex_ai_model" {
    query = query.kms_keys_for_vertex_ai_model
    args  = [self.input.model_id.value]
  }

  with "vertex_ai_endpoints_for_vertex_ai_model" {
    query = query.vertex_ai_endpoints_for_vertex_ai_model
    args  = [self.input.model_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.vertex_ai_model
        args = {
          vertex_ai_model_ids = [self.input.model_id.value]
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = with.kms_keys_for_vertex_ai_model.rows[*].self_link
        }
      }

      node {
        base = node.vertex_ai_endpoint
        args = {
          vertex_ai_endpoint_ids = with.vertex_ai_endpoints_for_vertex_ai_model.rows[*].endpoint_id
        }
      }

      edge {
        base = edge.vertex_ai_model_to_kms_key
        args = {
          vertex_ai_model_ids = [self.input.model_id.value]
        }
      }

      edge {
        base = edge.vertex_ai_model_to_vertex_ai_endpoint
        args = {
          vertex_ai_model_ids = [self.input.model_id.value]
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
        query = query.vertex_ai_model_overview
        args  = [self.input.model_id.value]
      }

      table {
        title = "Tags"
        width = 3
        query = query.vertex_ai_model_labels
        args  = [self.input.model_id.value]
      }

      table {
        title = "Encryption Details"
        width = 6
        query = query.vertex_ai_model_encryption
        args  = [self.input.model_id.value]
      }
    }

    container {
      width = 12

      table {
        title = "Model Endpoints Details"
        query = query.vertex_ai_model_deployed_endpoints
        args  = [self.input.model_id.value]
      }
    }
  }
}

# Input queries

query "vertex_ai_model_input" {
  sql = <<-EOQ
    select
      display_name as label,
      name || '/' || project as value,
      json_build_object(
        'project', project,
        'location', location
      ) as tags
    from
      gcp_vertex_ai_model
    order by
      display_name;
  EOQ
}

# Card Queries

query "vertex_ai_model_version" {
  sql = <<-EOQ
    select
      'Version' as label,
      version_id as value
    from
      gcp_vertex_ai_model
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_model_source" {
  sql = <<-EOQ
    select
      'Model Source' as label,
      case
    when model_source_info ->> 'source_type' = '1' then 'AutoML'
    when model_source_info ->> 'source_type' = '2' then 'Custom'
    when model_source_info ->> 'source_type' = '3' then 'BigQuery ML'
    when model_source_info ->> 'source_type' = '4' then 'Model Garden'
    when model_source_info ->> 'source_type' = '5' then 'Genie' end as value
    from
      gcp_vertex_ai_model
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_model_encryption_enabled" {
  sql = <<-EOQ
    select
      case when encryption_spec is not null then 'Enabled' else 'Disabled' end as value,
      'Encryption' as label,
      case when encryption_spec is not null then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_model
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_model_deployment_status" {
  sql = <<-EOQ
    select
      case when deployed_models != '[]' then 'Deployed' else 'Not Deployed' end as value,
      'Deployment Status' as label,
      case when deployed_models != '[]' then 'ok' else 'alert' end as "type"
    from
      gcp_vertex_ai_model
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

# Table Queries

query "vertex_ai_model_overview" {
  sql = <<-EOQ
    select
      name as "Model Name",
      display_name as "Display Name",
      create_time as "Create Time",
      project as "Project ID",
      location as "Location",
      update_time as "Update Time",
      version_id as "Version ID",
      version_description as "Version Description",
      version_create_time as "Version Create Time",
      version_update_time as "Version Update Time",
      training_pipeline as "Training Pipeline"
    from
      gcp_vertex_ai_model
    where
      name = split_part($1, '/', 1)
      and project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_model_deployed_endpoints" {
  sql = <<-EOQ
    with model_endpoints as (
      select
      split_part(d->>'endpoint','/',6) as ename
    from
      gcp_vertex_ai_model m,
      jsonb_array_elements(deployed_models) as d
    where
        m.name = split_part($1, '/', 1)
        and m.project = split_part($1, '/', 2)
    )
    select
      e.name as "Endpoint Name",
      e.display_name as "Endpoint Display Name",
      e.traffic_split as "Endpoint Traffic Split",
      e.create_time as "Endpoint Create Time",
      e.location as "Endpoint Location",
      e.project as "Endpoint Project ID"
    from
      gcp_vertex_ai_endpoint e,
      model_endpoints me
    where
      e.name = me.ename;
  EOQ
}

query "vertex_ai_model_labels" {
  sql = <<-EOQ
    with jsondata as (
      select
        labels::json as labels
      from
        gcp_vertex_ai_model
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

query "vertex_ai_model_encryption" {
  sql = <<-EOQ
    select
      kms.name as "KMS Key",
      kms.create_time as "KMS Key Creation Time",
      kms.rotation_period as "KMS Key Rotation Period",
      kms.key_ring_name as "KMS Key Ring Name"
    from
      gcp_vertex_ai_model vm
    left join
      gcp_kms_key kms
    on
      (encryption_spec ->> 'kms_key_name') = replace(kms.self_link, 'https://cloudkms.googleapis.com/v1/', '')
    where
      vm.name = split_part($1, '/', 1)
      and vm.project = split_part($1, '/', 2);
  EOQ
}

## With Queries

query "kms_keys_for_vertex_ai_model" {
  sql = <<-EOQ
    select
      kms.self_link as self_link
    from
      gcp_vertex_ai_model vm
    left join gcp_kms_key kms
    on
      (encryption_spec ->> 'kms_key_name') = replace(kms.self_link, 'https://cloudkms.googleapis.com/v1/', '')
    where
      vm.name = split_part($1, '/', 1)
      and vm.project = split_part($1, '/', 2);
  EOQ
}

query "vertex_ai_endpoints_for_vertex_ai_model" {
  sql = <<-EOQ
    with model_endpoints as (
    select
      split_part(d->>'endpoint','/',6) as ename
    from
      gcp_vertex_ai_model m,
      jsonb_array_elements(deployed_models) as d
    where
      m.name = split_part($1, '/', 1)
      and m.project = split_part($1, '/', 2)
    )
    select
      e.name || '/' || e.project as endpoint_id
    from
      gcp_vertex_ai_endpoint e,
      model_endpoints me
    where
      e.name = me.ename;
  EOQ
}