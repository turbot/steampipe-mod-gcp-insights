dashboard "composer_environment_detail" {

  title         = "GCP Composer Environment Detail"
  documentation = file("./dashboards/composer/docs/composer_environment_detail.md")

  tags = merge(local.cloudfunction_common_tags, {
    type = "Detail"
  })

  input "environment_name" {
    title = "Select an environment:"
    query = query.composer_environment_input
    width = 4
  }

  container {

    card {
      query = query.composer_environment_node_count
      width = 2
      args  = [self.input.environment_name.value]
    }

    card {
      query = query.composer_environment_composer_version
      width = 2
      args  = [self.input.environment_name.value]
    }

   card {
      query = query.composer_environment_airflow_version
      width = 2
      args  = [self.input.environment_name.value]
    }

    card {
      query = query.composer_environment_encryption
      width = 2
      args  = [self.input.environment_name.value]
    }

    card {
      query = query.composer_environment_public_access
      width = 2
      args  = [self.input.environment_name.value]
    }

    card {
      query = query.composer_environment_web_server_public_access
      width = 2
      args  = [self.input.environment_name.value]
    }

  }

  with "kms_keys_for_composer_environment" {
    query = query.kms_keys_for_composer_environment
    args  = [self.input.environment_name.value]
  }

  with "iam_service_accounts_for_composer_environment" {
    query = query.iam_service_accounts_for_composer_environment
    args  = [self.input.environment_name.value]
  }

  with "compute_networks_for_composer_environment" {
    query = query.compute_networks_for_composer_environment
    args  = [self.input.environment_name.value]
  }

  with "compute_subnetworks_for_composer_environment" {
    query = query.compute_subnetworks_for_composer_environment
    args  = [self.input.environment_name.value]
  }

  with "storage_buckets_for_composer_environment" {
    query = query.storage_buckets_for_composer_environment
    args  = [self.input.environment_name.value]
  }

  with "kubernetes_clusters_for_composer_environment" {
    query = query.kubernetes_clusters_for_composer_environment
    args  = [self.input.environment_name.value]
  }

    container {

      graph {
        title = "Relationships"
        type  = "graph"


        node {
          base = node.composer_environment
          args = {
            composer_environment_names = [self.input.environment_name.value]
          }
        }

        node {
          base = node.kms_key
          args = {
            kms_key_self_links = with.kms_keys_for_composer_environment.rows[*].self_link
          }
        }

        node {
          base = node.iam_service_account
          args = {
            iam_service_account_names = with.iam_service_accounts_for_composer_environment.rows[*].name
          }
        }

        node {
          base = node.compute_network
          args = {
            compute_network_ids = with.compute_networks_for_composer_environment.rows[*].network_id
          }
        }

        node {
          base = node.compute_subnetwork
          args = {
            compute_subnetwork_ids = with.compute_subnetworks_for_composer_environment.rows[*].subnetwork_id
          }
        }

        node {
          base = node.storage_bucket
          args = {
            storage_bucket_ids = with.storage_buckets_for_composer_environment.rows[*].bucket_id
          }
        }

        node {
          base = node.kubernetes_cluster
          args = {
            kubernetes_cluster_ids = with.kubernetes_clusters_for_composer_environment.rows[*].cluster_id
          }
        }

        edge {
          base = edge.composer_environment_to_kms_key
          args = {
            composer_environment_names = [self.input.environment_name.value]
          }
        }

        edge {
          base = edge.composer_environment_to_iam_service_account
          args = {
            composer_environment_names = [self.input.environment_name.value]
          }
        }

        edge {
          base = edge.composer_environment_to_compute_network
          args = {
            composer_environment_names = [self.input.environment_name.value]
          }
        }

        edge {
          base = edge.composer_environment_to_compute_subnetwork
          args = {
            composer_environment_names = [self.input.environment_name.value]
          }
        }

        edge {
          base = edge.composer_environment_to_storage_bucket
          args = {
            composer_environment_names = [self.input.environment_name.value]
          }
        }

        edge {
          base = edge.composer_environment_to_kubernetes_cluster
          args = {
            composer_environment_names = [self.input.environment_name.value]
          }
        }

        }
      }

      container {
        width = 6

        table {
          title = "Overview"
          type  = "line"
          width = 6
          query = query.composer_environment_overview
          args  = [self.input.environment_name.value]
        }

        table {
          title = "Tags"
          width = 6
          query = query.composer_environment_tags
          args  = [self.input.environment_name.value]
        }

      }

      container {
        width = 6

        table {
          title = "Encryption Config"
          query = query.composer_environment_encryption_config
          args  = [self.input.environment_name.value]
        }

        table {
          title = "Maintenance Window"
          query = query.composer_environment_maintenance_window
          args  = [self.input.environment_name.value]
        }

        table {
          title = "Node Config"
          query = query.composer_environment_node_config
          args  = [self.input.environment_name.value]
        }

      }

      container {

        table {
          title = "Private Environment Config"
          query = query.composer_private_environment_config
          args  = [self.input.environment_name.value]
        }

      }


      container {
        title = "Workloads configuration"

        table {
          title = "Scheduler"
          width = 6
          query = query.composer_environment_scheduler_configuration
          args  = [self.input.environment_name.value]
        }

        table {
          title = "DAG processor"
          width = 6
          query = query.composer_environment_dag_processor_configuration
          args  = [self.input.environment_name.value]
        }

        table {
          title = "Triggerer"
          width = 6
          query = query.composer_environment_triggerer_configuration
          args  = [self.input.environment_name.value]
        }

        table {
          title = "Web server"
          width = 6
          query = query.composer_environment_web_server_configuration
          args  = [self.input.environment_name.value]
        }

        table {
          title = "Worker"
          query = query.composer_environment_worker_configuration
          args  = [self.input.environment_name.value]
        }

      }

}

# Input queries

query "composer_environment_input" {
  sql = <<-EOQ
    select
      title as label,
      name as value,
      json_build_object(
        'project', project,
        'location', location
      ) as tags
    from
      gcp_composer_environment
    order by
      title;
  EOQ
}

# Card queries

query "composer_environment_node_count" {
  sql = <<-EOQ
    select
      node_count as "Node Count"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_composer_version" {
  sql = <<-EOQ
    select
      split_part(software_config ->> 'imageVersion', '-', 2)  as "Composer Version"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_airflow_version" {
  sql = <<-EOQ
    select
      split_part(software_config ->> 'imageVersion', 'airflow-', 2)  as "Airflow Version"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_encryption" {
  sql = <<-EOQ
    select
      case when encryption_config ->> 'kmsKeyName' is not null then 'Enabled' else 'Disabled' end as value,
      case when encryption_config ->> 'kmsKeyName' is not null  then 'ok' else 'alert' end as type,
      'Encryption' as label
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_public_access" {
  sql = <<-EOQ
    select
      case
        when private_environment_config -> 'privateClusterConfig' = '{}' then 'Enabled' else 'Disabled' end as value,
      'Public Access' as label,
       case when private_environment_config -> 'privateClusterConfig' = '{}' then 'alert' else 'ok' end as "type"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_web_server_public_access" {
  sql = <<-EOQ
    select
      case
        when web_server_network_access_control->'allowedIpRanges' @> '[{"value": "0.0.0.0/0"}]'::jsonb
          and web_server_network_access_control->'allowedIpRanges' @> '[{"value": "::0/0"}]'::jsonb then 'Enabled' else 'Disabled' end as value,
      'Web Server Public Access' as label,
       case when web_server_network_access_control->'allowedIpRanges' @> '[{"value": "0.0.0.0/0"}]'::jsonb
          and web_server_network_access_control->'allowedIpRanges' @> '[{"value": "::0/0"}]'::jsonb then 'alert' else 'ok' end as "type"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_maintenance_window" {
  sql = <<-EOQ
    select
      maintenance_window ->> 'endTime' as "End Time",
      maintenance_window ->> 'recurrence' as "Recurrence",
      maintenance_window ->> 'startTime' as "Start Time"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_node_config" {
  sql = <<-EOQ
    select
      node_config ->> 'network' as "Network",
      node_config ->> 'serviceAccount' as "Service Account",
      node_config ->> 'subnetwork' as "Subnetwork"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_encryption_config" {
  sql = <<-EOQ
    select
      case when encryption_config ->> 'kmsKeyName' is not null then 'Enabled' else 'Disabled' end as "Encryption",
      encryption_config ->> 'kmsKeyName' as  "kMS Key Name"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_private_environment_config" {
  sql = <<-EOQ
    select
      private_environment_config ->> 'cloudComposerConnectionSubnetwork' as "Cloud Composer Connection Subnetwork",
      private_environment_config ->> 'cloudComposerNetworkIpv4CidrBlock' as "Cloud Composer Network Ipv4 Cidr Block",
      private_environment_config ->> 'cloudSqlIpv4CidrBlock' as "Cloud Sql Ipv4 Cidr Block",
      private_environment_config ->> 'enablePrivateEnvironment' as "Enable Private Environment",
      private_environment_config -> 'networkingConfig' ->> 'connectionType' as "Connection Type",
      private_environment_config -> 'privateClusterConfig' ->> 'masterIpv4CidrBlock' as "Master Ipv4 Cidr Block",
      private_environment_config -> 'privateClusterConfig' ->> 'masterIpv4ReservedRange' as "Master Ipv4 Reserved Range"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_scheduler_configuration" {
  sql = <<-EOQ
    select
      workloads_config -> 'scheduler' ->> 'count' as "Count",
      workloads_config -> 'scheduler' ->> 'cpu' as "CPU",
      workloads_config -> 'scheduler' ->> 'memoryGb' as "Memory GB",
      workloads_config -> 'scheduler' ->> 'storageGb' as "Storage GB"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_dag_processor_configuration" {
  sql = <<-EOQ
    select
      workloads_config -> 'dagProcessor' ->> 'count' as "Count",
      workloads_config -> 'dagProcessor' ->> 'cpu' as "CPU",
      workloads_config -> 'dagProcessor' ->> 'memoryGb' as "Memory GB",
      workloads_config -> 'dagProcessor' ->> 'storageGb' as "Storage GB"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_triggerer_configuration" {
  sql = <<-EOQ
    select
      workloads_config -> 'triggerer' -> 'count' as "Count",
      workloads_config -> 'triggerer' -> 'cpu' as "CPU",
      workloads_config -> 'triggerer' -> 'memoryGb' as "Memory GB"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_web_server_configuration" {
  sql = <<-EOQ
    select
      workloads_config -> 'webServer' -> 'count' as "Count",
      workloads_config -> 'webServer' -> 'cpu' as "CPU",
      workloads_config -> 'webServer' -> 'storageGb' as "Storage GB"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

query "composer_environment_worker_configuration" {
  sql = <<-EOQ
    select
      workloads_config -> 'worker' -> 'maxCount' as "Max Count",
      workloads_config -> 'worker' -> 'minCount' as "Min Count",
      workloads_config -> 'worker' -> 'cpu' as "CPU",
      workloads_config -> 'worker' -> 'storageGb' as "Storage GB",
      workloads_config -> 'worker' -> 'memoryGb' as "Memory GB"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ
}

# Other queries
query "composer_environment_overview" {
  sql = <<-EOQ
    select
      uuid as "uuid",
      name as "Name",
      environment_size as "Environment Size",
      software_config ->> 'webServerPluginsMode' as "Web Server Plugins Mode",
      location as "Location",
      update_time as "Update Time",
      create_time as "Create Time",
      project as "Project"
    from
      gcp_composer_environment
    where
      project = split_part($1, '/', 2)
      and name = $1;
  EOQ

}

query "composer_environment_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_composer_environment
      where
        project = split_part($1, '/', 2)
        and name = $1
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

query "kms_keys_for_composer_environment" {
  sql = <<-EOQ
    select
      k.self_link
    from
      gcp_composer_environment as i,
      gcp_kms_key as k
    where
      i.name = $1
      and i.encryption_config ->> 'kmsKeyName' = split_part(k.self_link , 'v1/', 2);
  EOQ
}

query "iam_service_accounts_for_composer_environment" {
  sql = <<-EOQ
    select
      s.name || '/' || s.project as name
    from
      gcp_composer_environment as i,
      gcp_service_account as s
    where
      i.name = $1
      and i.node_config ->> 'serviceAccount' = s.name;
  EOQ
}

query "compute_networks_for_composer_environment" {
  sql = <<-EOQ
     select
        n.id::text || '/' || n.project as network_id
      from
        gcp_composer_environment as v,
        gcp_compute_network as n
      where
        v.name = $1
        and v.node_config ->> 'network' = split_part(n.self_link , 'v1/', 2);
  EOQ
}

query "compute_subnetworks_for_composer_environment" {
  sql = <<-EOQ
     select
        n.id::text || '/' || n.project as subnetwork_id
      from
        gcp_composer_environment as v,
        gcp_compute_subnetwork as n
      where
        v.name = $1
        and v.node_config ->> 'subnetwork' = split_part(n.self_link , 'v1/', 2);
  EOQ
}

query "storage_buckets_for_composer_environment" {
  sql = <<-EOQ
    select
      s.id as bucket_id
    from
      gcp_composer_environment as i,
      gcp_storage_bucket as s
    where
      i.name = $1
      and i.storage_config_bucket = s.name
      and i.project = s.project
  EOQ
}

query "kubernetes_clusters_for_composer_environment" {
  sql = <<-EOQ
    select
      c.id::text || '/' || c.project as cluster_id
    from
      gcp_kubernetes_cluster c,
      gcp_composer_environment i
    where
      i.gke_cluster = split_part(c.self_link, 'v1/', 2)
      and i.name = $1
  EOQ
}
