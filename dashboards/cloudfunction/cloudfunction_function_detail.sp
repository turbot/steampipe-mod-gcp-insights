dashboard "cloudfunctions_function_detail" {

  title         = "GCP Cloud Run function Detail"
  documentation = file("./dashboards/cloudfunction/docs/cloudfunctions_function_detail.md")

  tags = merge(local.cloudfunction_common_tags, {
    type = "Detail"
  })

  input "function_self_link" {
    title = "Select a function:"
    query = query.cloudfunctions_function_input
    width = 4
  }

  container {

    card {
      query = query.cloudfunctions_function_runtime
      width = 2
      args  = [self.input.function_self_link.value]
    }

    card {
      query = query.cloudfunctions_function_memory_in_mb
      width = 2
      args  = [self.input.function_self_link.value]
    }

    card {
      query = query.cloudfunctions_function_ingress_settings
      width = 2
      args  = [self.input.function_self_link.value]
    }

    card {
      query = query.cloudfunctions_function_encryption
      width = 2
      args  = [self.input.function_self_link.value]
    }

    card {
      query = query.cloudfunctions_function_trigger_type
      width = 2
      args  = [self.input.function_self_link.value]
    }

  }

  with "kms_keys_for_cloudfunctions_function" {
    query = query.kms_keys_for_cloudfunctions_function
    args  = [self.input.function_self_link.value]
  }

  with "pubsub_topics_for_cloudfunctions_function" {
    query = query.pubsub_topics_for_cloudfunctions_function
    args  = [self.input.function_self_link.value]
  }

  with "iam_service_accounts_for_cloudfunctions_function" {
    query = query.iam_service_accounts_for_cloudfunctions_function
    args  = [self.input.function_self_link.value]
  }

   with "storage_buckets_for_cloudfunctions_function" {
    query = query.storage_buckets_for_cloudfunctions_function
    args  = [self.input.function_self_link.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"


      node {
        base = node.cloudfunctions_function
        args = {
          cloudfunctions_function_self_link = [self.input.function_self_link.value]
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = with.kms_keys_for_cloudfunctions_function.rows[*].self_link
        }
      }

      node {
        base = node.pubsub_topic
        args = {
          pubsub_topic_self_links = with.pubsub_topics_for_cloudfunctions_function.rows[*].self_link
        }
      }

      node {
        base = node.iam_service_account
        args = {
          iam_service_account_names = with.iam_service_accounts_for_cloudfunctions_function.rows[*].name
        }
      }

      node {
        base = node.storage_bucket
        args = {
          storage_bucket_ids = with.storage_buckets_for_cloudfunctions_function.rows[*].bucket_id
        }
      }

      edge {
        base = edge.cloudfunctions_function_to_kms_key
        args = {
          cloudfunctions_function_self_link = [self.input.function_self_link.value]
        }
      }

      edge {
        base = edge.cloudfunctions_function_to_pubsub_topic
        args = {
          cloudfunctions_function_self_link = [self.input.function_self_link.value]
        }
      }

      edge {
        base = edge.cloudfunctions_function_to_pubsub_topic
        args = {
          cloudfunctions_function_self_link = [self.input.function_self_link.value]
        }
      }

      edge {
        base = edge.cloudfunctions_function_to_iam_service_account
        args = {
          cloudfunctions_function_self_link = [self.input.function_self_link.value]
        }
      }

      # edge {
      #   base = edge.cloudfunctions_function_to_kms_key
      #   args = {
      #     storage_bucket_ids = with.storage_buckets_for_kms_key.rows[*].bucket_id
      #   }
      # }

    }

    }

      container {
        width = 6

        table {
          title = "Overview"
          type  = "line"
          width = 6
          query = query.cloudfunctions_function_overview
          args  = [self.input.function_self_link.value]
        }

        table {
          title = "Tags"
          width = 6
          query = query.cloudfunctions_function_tags
          args  = [self.input.function_self_link.value]
        }

      }

      container {
        width = 6

        table {
          title = "VPC Connector"
          query = query.cloudfunctions_function_vpc_connector
          args  = [self.input.function_self_link.value]
        }

        table {
          title = "Max And Min Instances"
          query = query.cloudfunctions_function_min_max_instances
          args  = [self.input.function_self_link.value]
        }

      }

      container {

        table {
          title = "Event Trigger"
          query = query.cloudfunctions_function_event_trigger
          args  = [self.input.function_self_link.value]
        }

      }

    }

# Input queries

query "cloudfunctions_function_input" {
  sql = <<-EOQ
    select
      name as label,
      self_link as value,
      json_build_object(
        'project', project,
        'location', location
      ) as tags
    from
      gcp_cloudfunctions_function
    order by
      name;
  EOQ
}

# Card queries

query "cloudfunctions_function_runtime" {
  sql = <<-EOQ
    select
      runtime as "Runtime"
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
}

query "cloudfunctions_function_memory_in_mb" {
  sql = <<-EOQ
    select
      available_memory_mb as "Available Memory(mb)"
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
}

query "cloudfunctions_function_ingress_settings" {
  sql = <<-EOQ
    select
      ingress_settings as "Ingress Settings"
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
}

query "cloudfunctions_function_encryption" {
  sql = <<-EOQ
    select
      case when kms_key_name = '' then 'Disabled' else 'Enabled' end as value,
      case when kms_key_name = ''  then 'alert' else 'ok' end as type,
      'Encryption' as label
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
}

query "cloudfunctions_function_trigger_type" {
  sql = <<-EOQ
    select
      case
        when event_trigger is not null then 'Event' else 'HTTPS' end as value,
      'Trigger Type' as label
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
}


# query "bigquery_datasets_for_cloudfunctions_function" {
#   sql = <<-EOQ
#     select
#       d.id as dataset_id
#     from
#       gcp_cloudfunctions_function c,
#       gcp_bigquery_dataset d
#     where
#       c.resource_usage_export_config -> 'bigqueryDestination' ->> 'datasetId' = d.dataset_id
#       and d.project = c.project
#       and c.id = split_part($1, '/', 1);
#   EOQ
# }

# query "compute_firewalls_for_cloudfunctions_function" {
#   sql = <<-EOQ
#     select
#       f.id::text as firewall_id
#     from
#       gcp_cloudfunctions_function c,
#       gcp_compute_network n,
#       gcp_compute_firewall f
#     where
#       c.network = n.name
#       and c.project = n.project
#       and n.self_link = f.network
#       and c.id = split_part($1, '/', 1);
#   EOQ
# }

# query "compute_instance_groups_for_cloudfunctions_function" {
#   sql = <<-EOQ
#     select
#       g.id::text || '/' || g.project as group_id
#     from
#       gcp_kubernetes_node_pool p,
#       gcp_compute_instance_group g,
#       gcp_cloudfunctions_function c,
#       jsonb_array_elements_text(p.instance_group_urls) ig
#     where
#       p.cluster_name = c.name
#       and c.project = p.project
#       and split_part(ig, 'instanceGroupManagers/', 2) = g.name
#       and g.project = p.project
#       and c.id = split_part($1, '/', 1);
#   EOQ
# }

query "cloudfunctions_function_vpc_connector" {
  sql = <<-EOQ
    select
      vpc_connector  as "VPC Connector",
      vpc_connector_egress_settings as "VPC Connector Egress Settings"
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ

}

query "cloudfunctions_function_min_max_instances" {
  sql = <<-EOQ
    select
      max_instances as "Max Instances",
      min_instances as "Min Instances"
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ

}

query "cloudfunctions_function_event_trigger" {
  sql = <<-EOQ
    select
      event_trigger -> 'eventType 'as "Event Type",
      event_trigger -> 'pubsubTopic' as "Pub/Sub Topic",
      event_trigger -> 'retryPolicy' as "Retry Policy",
      event_trigger -> 'serviceAccountEmail' as "Service Account Email",
      event_trigger -> 'trigger' as "Trigger",
      event_trigger -> 'triggerRegion' as "Trigger Region"
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ

}

# Other queries
query "cloudfunctions_function_overview" {
  sql = <<-EOQ
    select
      url as "URL",
      name as "Name",
      location as "Location",
      update_time as "Update Time",
      project as "Project"
    from
      gcp_cloudfunctions_function
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ

}

query "cloudfunctions_function_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_cloudfunctions_function
      where
        project = split_part($1, '/', 6)
        and self_link = $1
    )
    select
      key as "Key",
      value as "Value"
    from
      jsondata,
      json_each_text(tags)
    order by
      key;
    EOQ

}

# With queries

query "kms_keys_for_cloudfunctions_function" {
  sql = <<-EOQ
    select
      k.self_link
    from
      gcp_cloudfunctions_function as i,
      gcp_kms_key as k
    where
      i.self_link = $1
      and i.kms_key_name = split_part(k.self_link , 'v1/', 2);
  EOQ
}

query "pubsub_topics_for_cloudfunctions_function" {
  sql = <<-EOQ
    select
      p.self_link
    from
      gcp_cloudfunctions_function as i,
      gcp_pubsub_topic as p
    where
      i.self_link = $1
      and i.event_trigger ->> 'pubsubTopic' = split_part(p.self_link , 'v1/', 2);
  EOQ
}

query "iam_service_accounts_for_cloudfunctions_function" {
  sql = <<-EOQ
    select
      s.name || '/' || s.project as name
    from
      gcp_cloudfunctions_function as i,
      gcp_service_account as s
    where
      i.self_link = $1
      and i.service_account_email = s.name;
  EOQ
}

query "storage_buckets_for_cloudfunctions_function" {
  sql = <<-EOQ
    select
      s.id as bucket_id
    from
      gcp_cloudfunctions_function as i,
      gcp_storage_bucket as s
    where
      i.self_link = $1
      and i.build_config -> 'source' -> 'storageSource' ->> 'bucket' = s.name;
  EOQ
}


