dashboard "kubernetes_cluster_detail" {

  title         = "GCP Kubernetes Cluster Detail"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_cluster_detail.md")

  tags = merge(local.kubernetes_common_tags, {
    type = "Detail"
  })

  input "cluster_id" {
    title = "Select a cluster:"
    query = query.kubernetes_cluster_input
    width = 4
  }

  container {

    card {
      query = query.kubernetes_cluster_node
      width = 2
      args  = [self.input.cluster_id.value]
    }

    card {
      query = query.kubernetes_cluster_autopilot_enabled
      width = 2
      args  = [self.input.cluster_id.value]
    }

    card {
      query = query.kubernetes_cluster_database_encryption
      width = 2
      args  = [self.input.cluster_id.value]
    }

    card {
      query = query.kubernetes_cluster_degraded
      width = 2
      args  = [self.input.cluster_id.value]
    }

    card {
      query = query.kubernetes_cluster_shielded_nodes_disabled
      width = 2
      args  = [self.input.cluster_id.value]
    }

    card {
      query = query.kubernetes_cluster_auto_repair_disabled
      width = 2
      args  = [self.input.cluster_id.value]
    }

  }

  with "bigquery_datasets_from_kubernetes_cluster_id" {
    query = query.bigquery_datasets_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  with "compute_firewalls_from_kubernetes_cluster_id" {
    query = query.compute_firewalls_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  with "compute_instance_groups_from_kubernetes_cluster_id" {
    query = query.compute_instance_groups_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  with "compute_instances_from_kubernetes_cluster_id" {
    query = query.compute_instances_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  with "compute_networks_from_kubernetes_cluster_id" {
    query = query.compute_networks_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  with "compute_subnets_from_kubernetes_cluster_id" {
    query = query.compute_subnets_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  with "kms_keys_from_kubernetes_cluster_id" {
    query = query.kms_keys_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  with "kubernetes_node_pools_from_kubernetes_cluster_id" {
    query = query.kubernetes_node_pools_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  with "pubsub_topics_from_kubernetes_cluster_id" {
    query = query.pubsub_topics_from_kubernetes_cluster_id
    args  = [self.input.cluster_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.bigquery_dataset
        args = {
          bigquery_dataset_ids = with.bigquery_datasets_from_kubernetes_cluster_id.rows[*].dataset_id
        }
      }

      node {
        base = node.compute_firewall
        args = {
          compute_firewall_ids = with.compute_firewalls_from_kubernetes_cluster_id.rows[*].firewall_id
        }
      }

      node {
        base = node.compute_instance
        args = {
          compute_instance_ids = with.compute_instances_from_kubernetes_cluster_id.rows[*].instance_id
        }
      }

      node {
        base = node.compute_instance_group
        args = {
          compute_instance_group_ids = with.compute_instance_groups_from_kubernetes_cluster_id.rows[*].group_id
        }
      }

      node {
        base = node.compute_network
        args = {
          compute_network_ids = with.compute_networks_from_kubernetes_cluster_id.rows[*].network_id
        }
      }

      node {
        base = node.compute_subnetwork
        args = {
          compute_subnetwork_ids = with.compute_subnets_from_kubernetes_cluster_id.rows[*].subnetwork_id
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = with.kms_keys_from_kubernetes_cluster_id.rows[*].self_link
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_ids = [self.input.cluster_id.value]
        }
      }

      node {
        base = node.kubernetes_node_pool
        args = {
          kubernetes_node_pool_names = with.kubernetes_node_pools_from_kubernetes_cluster_id.rows[*].pool_name
        }
      }

      node {
        base = node.pubsub_topic
        args = {
          pubsub_topic_self_links = with.pubsub_topics_from_kubernetes_cluster_id.rows[*].self_link
        }
      }

      edge {
        base = edge.compute_instance_group_to_compute_instance
        args = {
          compute_instance_group_ids = with.compute_instance_groups_from_kubernetes_cluster_id.rows[*].group_id
        }
      }

      edge {
        base = edge.compute_subnetwork_to_compute_network
        args = {
          compute_subnetwork_ids = with.compute_subnets_from_kubernetes_cluster_id.rows[*].subnetwork_id
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_bigquery_dataset
        args = {
          kubernetes_cluster_ids = [self.input.cluster_id.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_compute_firewall
        args = {
          kubernetes_cluster_ids = [self.input.cluster_id.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_compute_subnetwork
        args = {
          kubernetes_cluster_ids = [self.input.cluster_id.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_kms_key
        args = {
          kubernetes_cluster_ids = [self.input.cluster_id.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_kubernetes_node_pool
        args = {
          kubernetes_cluster_ids = [self.input.cluster_id.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_pubsub_topic
        args = {
          kubernetes_cluster_ids = [self.input.cluster_id.value]
        }
      }

      edge {
        base = edge.kubernetes_node_pool_to_compute_instance_group
        args = {
          kubernetes_node_pool_names = with.kubernetes_node_pools_from_kubernetes_cluster_id.rows[*].pool_name
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
      query = query.kubernetes_cluster_overview
      args  = [self.input.cluster_id.value]
    }

    table {
      title = "Tags"
      width = 6
      query = query.kubernetes_cluster_tags
      args  = [self.input.cluster_id.value]
    }

  }

  container {
    width = 6

    table {
      title = "IP Allocation Policy"
      query = query.kubernetes_cluster_ip_allocation_policy
      args  = [self.input.cluster_id.value]
    }

    table {
      title = "Network Configuration"
      query = query.kubernetes_cluster_network_config
      args  = [self.input.cluster_id.value]
    }

  }

  container {

    table {
      title = "Notification Configuration"
      width = 6
      query = query.kubernetes_cluster_notification_config
      args  = [self.input.cluster_id.value]
    }

    table {
      title = "Logging & Monitoring"
      width = 6
      query = query.kubernetes_cluster_lm
      args  = [self.input.cluster_id.value]
    }

  }

  container {

    table {
      title = "Node Configuration"
      query = query.kubernetes_cluster_node_detail
      args  = [self.input.cluster_id.value]
    }

    table {
      title = "Private Cluster Configuration"
      query = query.kubernetes_cluster_private_cluster_config
      args  = [self.input.cluster_id.value]
    }

    table {
      title = "Add-ons Configuration"
      query = query.kubernetes_cluster_addons_config
      args  = [self.input.cluster_id.value]
    }

  }

}

# Input queries

query "kubernetes_cluster_input" {
  sql = <<-EOQ
    select
      name as label,
      id as value,
      json_build_object(
        'project', project,
        'location', location
      ) as tags
    from
      gcp_kubernetes_cluster
    order by
      name;
  EOQ
}

# Card queries

query "kubernetes_cluster_node" {
  sql = <<-EOQ
    select
      sum (current_node_count) as "Total Nodes"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ
}

query "kubernetes_cluster_autopilot_enabled" {
  sql = <<-EOQ
    select
      case when autopilot_enabled then 'Enabled' else 'Disabled' end as "Autopilot"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ
}

query "kubernetes_cluster_database_encryption" {
  sql = <<-EOQ
    select
      case when database_encryption_key_name = '' then 'Disabled' else 'Enabled' end as value,
      'Database Encryption' as label,
      case when database_encryption_key_name = '' then 'alert' else 'ok' end as type
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ
}

query "kubernetes_cluster_degraded" {
  sql = <<-EOQ
    select
      initcap(status) as value,
      'Status' as label,
      case when status = 'DEGRADED' then 'alert' else 'ok' end as type
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ
}

query "kubernetes_cluster_shielded_nodes_disabled" {
  sql = <<-EOQ
    select
      case when shielded_nodes_enabled then 'Enabled' else 'Disabled' end as value,
      'Shielded Nodes' as label,
      case when shielded_nodes_enabled then 'ok' else 'alert' end as type
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ
}

query "kubernetes_cluster_auto_repair_disabled" {
  sql = <<-EOQ
    select
      case when np -> 'management' -> 'autoRepair' = 'true' then 'Enabled' else 'Disabled' end as value,
      'Node Auto-Repair' as label,
      case when np -> 'management' -> 'autoRepair' = 'true' then 'ok' else 'alert' end as type
    from
      gcp_kubernetes_cluster,
      jsonb_array_elements(node_pools) as np
    where
      id = $1;
  EOQ
}

# With queries

query "bigquery_datasets_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      d.id as dataset_id
    from
      gcp_kubernetes_cluster c,
      gcp_bigquery_dataset d
    where
      c.resource_usage_export_config -> 'bigqueryDestination' ->> 'datasetId' = d.dataset_id
      and d.project = c.project
      and c.id = $1;
  EOQ
}

query "compute_firewalls_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      f.id::text as firewall_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n,
      gcp_compute_firewall f
    where
      c.network = n.name
      and c.project = n.project
      and n.self_link = f.network
      and c.id = $1;
  EOQ
}

query "compute_instance_groups_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      g.id::text as group_id
    from
      gcp_kubernetes_node_pool p,
      gcp_compute_instance_group g,
      gcp_kubernetes_cluster c,
      jsonb_array_elements_text(p.instance_group_urls) ig
    where
      p.cluster_name = c.name
      and c.project = p.project
      and split_part(ig, 'instanceGroupManagers/', 2) = g.name
      and g.project = p.project
      and c.id = $1;
  EOQ
}

query "compute_instances_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      i.id::text as instance_id
    from
      gcp_kubernetes_node_pool p,
      gcp_compute_instance_group g,
      gcp_kubernetes_cluster c,
      jsonb_array_elements_text(p.instance_group_urls) ig,
      jsonb_array_elements(g.instances) g_ins,
      gcp_compute_instance i
    where
      p.cluster_name = c.name
      and c.project = p.project
      and split_part(ig, 'instanceGroupManagers/', 2) = g.name
      and g.project = p.project
      and i.self_link = (g_ins ->> 'instance')
      and c.id = $1;
  EOQ
}

query "compute_networks_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      n.id::text as network_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n
    where
      c.id = $1
      and c.network = n.name
      and c.project = n.project;
  EOQ
}

query "compute_subnets_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      s.id::text as subnetwork_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_subnetwork s
    where
      c.id = $1
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ
}

query "kms_keys_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      k.self_link
    from
      gcp_kubernetes_cluster c,
      gcp_kms_key k
    where
      c.database_encryption_key_name is not null
      and k.project = c.project
      and k.self_link like '%' || c.database_encryption_key_name
      and c.id = $1;
  EOQ
}

query "kubernetes_node_pools_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      p.name as pool_name
    from
      gcp_kubernetes_node_pool p,
      gcp_kubernetes_cluster c
    where
      p.cluster_name = c.name
      and p.project = c.project
      and c.id = $1;
  EOQ
}

query "pubsub_topics_from_kubernetes_cluster_id" {
  sql = <<-EOQ
    select
      t.self_link as topic_name
    from
      gcp_kubernetes_cluster c,
      gcp_pubsub_topic t
    where
      c.id = $1
      and c.notification_config is not null
      and t.project = c.project
      and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%';
  EOQ
}

# Other queries
query "kubernetes_cluster_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      current_master_version as "Current Master Version",
      location_type as "Location Type",
      create_time as "Creation Time",
      location as "Location",
      project as "Project"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ

}

query "kubernetes_cluster_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_kubernetes_cluster
      where
        id = $1
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

query "kubernetes_cluster_ip_allocation_policy" {
  sql = <<-EOQ
    select
      ip_allocation_policy ->> 'clusterIpv4Cidr' as "Cluster IPv4 CIDR",
      ip_allocation_policy ->> 'clusterSecondaryRangeName' as "Cluster Secondary Range Name",
      ip_allocation_policy ->> 'servicesIpv4Cidr' as "Services IPv4 CIDR",
      ip_allocation_policy ->> 'servicesSecondaryRangeName' as "Services Secondary Range Name",
      ip_allocation_policy ->> 'useIpAliases' as "Use IP Aliases"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ

}

query "kubernetes_cluster_addons_config" {
  sql = <<-EOQ
    select
      case when addons_config -> 'dnsCacheConfig' ->> 'enabled' = 'true' then 'Enabled' else 'Disabled' end as "DNS Cache Config",
      case when addons_config -> 'gcePersistentDiskCsiDriverConfig' ->> 'enabled' = 'true' then 'Enabled' else 'Disabled' end as "GCE Persistent Disk CSI Driver Config",
      case when addons_config -> 'horizontalPodAutoscaling' ->> 'enabled' = 'true' then 'Enabled' else 'Disabled' end as "Horizontal Pod Autoscaling",
      case when addons_config -> 'httpLoadBalancing' ->> 'enabled' = 'true' then 'Enabled' else 'Disabled' end as "HTTP Load Balancing",
      case when addons_config -> 'kubernetesDashboard' ->> 'enabled' = 'true' then 'Enabled' else 'Disabled' end as "Kubernetes Dashboard",
      case when addons_config -> 'networkPolicyConfig' ->> 'enabled' = 'true' then 'Enabled' else 'Disabled' end as "Network Policy Config"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ

}

query "kubernetes_cluster_network_config" {
  sql = <<-EOQ
    select
      network_config ->> 'network' as "Network",
      network_config ->> 'subnetwork' as "Subnetwork",
      network_config -> 'defaultSnatStatus' as "Default SNAT Status",
      network_config ->> 'enableIntraNodeVisibility' as "Enable Intra Node Visibility"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ

}

query "kubernetes_cluster_lm" {
  sql = <<-EOQ
    select
      case when logging_service = 'none' then 'Disabled' else 'Enabled' end as "Logging Service",
      case when monitoring_service = 'none' then 'Disabled' else 'Enabled' end as "Monitoring Service"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ

}

query "kubernetes_cluster_notification_config" {
  sql = <<-EOQ
    select
      notification_config -> 'pubsub' ->> 'enabled' as "Enabled",
      notification_config -> 'pubsub' ->> 'topic' as "Topic"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ
}

query "kubernetes_cluster_private_cluster_config" {
  sql = <<-EOQ
    select
      private_cluster_config ->> 'enablePrivateNodes' as "Enable Private Nodes",
      private_cluster_config ->> 'masterIpv4CidrBlock' as "Master IPv4 CIDR Block",
      private_cluster_config ->> 'peeringName' as "Peering Name",
      private_cluster_config ->> 'privateEndpoint' as "Private Endpoint",
      private_cluster_config ->> 'publicEndpoint' as "Public Endpoint"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ
}

query "kubernetes_cluster_node_detail" {
  sql = <<-EOQ
    select
      current_node_version as "Current Node Version",
      max_pods_per_node as "Max Pods Per Node",
      initial_node_count as "Initial Node Count",
      node_ipv4_cidr_size as "Node IPv4 CIDR Size",
      node_config ->> 'diskSizeGb' as "Disk Size (GB)",
      node_config ->> 'diskType' as "Disk Type",
      node_config ->> 'imageType' as "Image Type",
      node_config ->> 'machineType' as "Machine Type",
      node_config -> 'metadata' ->> 'disable-legacy-endpoints' as "Disable Legacy Endpoints",
      node_config ->> 'serviceAccount' as "Service Account",
      node_config -> 'shieldedInstanceConfig' ->> 'enableIntegrityMonitoring' as "Enable Integrity Monitoring"
    from
      gcp_kubernetes_cluster
    where
      id = $1;
  EOQ
}
