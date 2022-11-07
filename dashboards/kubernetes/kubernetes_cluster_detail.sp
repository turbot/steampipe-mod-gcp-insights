dashboard "gcp_kubernetes_cluster_detail" {

  title         = "GCP Kubernetes Cluster Detail"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_cluster_detail.md")

  tags = merge(local.kubernetes_common_tags, {
    type = "Detail"
  })

  input "cluster_name" {
    title = "Select a cluster:"
    query = query.gcp_kubernetes_cluster_input
    width = 4
  }

  container {

    card {
      query = query.gcp_kubernetes_cluster_node
      width = 2
      args = {
        name = self.input.cluster_name.value
      }
    }

    card {
      query = query.gcp_kubernetes_cluster_autopilot_enabled
      width = 2
      args = {
        name = self.input.cluster_name.value
      }
    }

    card {
      query = query.gcp_kubernetes_cluster_database_encryption
      width = 2
      args = {
        name = self.input.cluster_name.value
      }
    }

    card {
      query = query.gcp_kubernetes_cluster_degraded
      width = 2
      args = {
        name = self.input.cluster_name.value
      }
    }

    card {
      query = query.gcp_kubernetes_cluster_shielded_nodes_disabled
      width = 2
      args = {
        name = self.input.cluster_name.value
      }
    }

    card {
      query = query.gcp_kubernetes_cluster_auto_repair_disabled
      width = 2
      args = {
        name = self.input.cluster_name.value
      }
    }

  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"


      nodes = [
        node.gcp_kubernetes_cluster_node,
        node.gcp_kubernetes_cluster_to_node_pool_node,
        node.gcp_kubernetes_cluster_to_compute_network_node,
        node.gcp_kubernetes_cluster_network_to_compute_subnetwork_node,
        node.gcp_kubernetes_cluster_to_pubsub_topic_node,
        node.gcp_kubernetes_cluster_node_pool_to_compute_instance_group_node,
        node.gcp_kubernetes_cluster_to_kms_key_node,
        node.gcp_kubernetes_cluster_to_bigquery_dataset_node,
        node.gcp_kubernetes_cluster_node_pool_to_compute_instance_node,
        node.gcp_kubernetes_cluster_to_compute_firewall_node
      ]

      edges = [
        edge.gcp_kubernetes_cluster_to_node_pool_edge,
        edge.gcp_kubernetes_cluster_to_compute_network_edge,
        edge.gcp_kubernetes_cluster_network_to_compute_subnetwork_edge,
        edge.gcp_kubernetes_cluster_to_pubsub_topic_edge,
        edge.gcp_kubernetes_cluster_node_pool_to_compute_instance_group_edge,
        edge.gcp_kubernetes_cluster_to_kms_key_edge,
        edge.gcp_kubernetes_cluster_to_bigquery_dataset_edge,
        edge.gcp_kubernetes_cluster_node_pool_to_compute_instance_edge,
        edge.gcp_kubernetes_cluster_to_compute_firewall_edge
      ]

      args = {
        name = self.input.cluster_name.value
      }
    }
  }

  container {
    width = 6

    table {
      title = "Overview"
      type  = "line"
      width = 6
      query = query.gcp_kubernetes_cluster_overview
      args = {
        name = self.input.cluster_name.value
      }
    }

    table {
      title = "Tags"
      width = 6
      query = query.gcp_kubernetes_cluster_tags
      args = {
        name = self.input.cluster_name.value
      }
    }

  }

  container {
    width = 6

    table {
      title = "IP Allocation Policy"
      query = query.gcp_kubernetes_cluster_ip_allocation_policy
      args = {
        name = self.input.cluster_name.value
      }
    }

    table {
      title = "Network Configuration"
      query = query.gcp_kubernetes_cluster_network_config
      args = {
        name = self.input.cluster_name.value
      }
    }

  }

  container {

    table {
      title = "Notification Configuration"
      width = 6
      query = query.gcp_kubernetes_cluster_notification_config
      args = {
        name = self.input.cluster_name.value
      }
    }

    table {
      title = "Logging & Monitoring"
      width = 6
      query = query.gcp_kubernetes_cluster_lm
      args = {
        name = self.input.cluster_name.value
      }
    }

  }

  container {

    table {
      title = "Node Configuration"
      query = query.gcp_kubernetes_cluster_node_detail
      args = {
        name = self.input.cluster_name.value
      }
    }

    table {
      title = "Private Cluster Configuration"
      query = query.gcp_kubernetes_cluster_private_cluster_config
      args = {
        name = self.input.cluster_name.value
      }
    }

    table {
      title = "Add-ons Configuration"
      query = query.gcp_kubernetes_cluster_addons_config
      args = {
        name = self.input.cluster_name.value
      }
    }

  }

}

query "gcp_kubernetes_cluster_input" {
  sql = <<-EOQ
    select
      name as label,
      name as value,
      json_build_object(
        'location', location,
        'project', project
      ) as tags
    from
      gcp_kubernetes_cluster
    order by
      name;
  EOQ
}

query "gcp_kubernetes_cluster_node" {
  sql = <<-EOQ
    select
      sum (current_node_count) as "Total Nodes"
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_autopilot_enabled" {
  sql = <<-EOQ
    select
      case when autopilot_enabled then 'Enabled' else 'Disabled' end as "Autopilot"
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_database_encryption" {
  sql = <<-EOQ
    select
      case when database_encryption_key_name = '' then 'Disabled' else 'Enabled' end as value,
      'Database Encryption' as label,
      case when database_encryption_key_name = '' then 'alert' else 'ok' end as type
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_degraded" {
  sql = <<-EOQ
    select
      initcap(status) as value,
      'Status' as label,
      case when status = 'DEGRADED' then 'alert' else 'ok' end as type
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_shielded_nodes_disabled" {
  sql = <<-EOQ
    select
      case when shielded_nodes_enabled then 'Enabled' else 'Disabled' end as value,
      'Shielded Nodes' as label,
      case when shielded_nodes_enabled then 'ok' else 'alert' end as type
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_auto_repair_disabled" {
  sql = <<-EOQ
    select
      case when np -> 'management' -> 'autoRepair' = 'true' then 'Enabled' else 'Disabled' end as value,
      'Node Auto-Repair' as label,
      case when np -> 'management' -> 'autoRepair' = 'true' then 'ok' else 'alert' end as type
    from
      gcp_kubernetes_cluster,
      jsonb_array_elements(node_pools) as np
    where
      name = $1;
  EOQ

  param "name" {}
}

## Graph

category "gcp_kubernetes_cluster_no_link" {
  icon = local.gcp_kubernetes_cluster
}

node "gcp_kubernetes_cluster_node" {
  category = category.gcp_kubernetes_cluster_no_link

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Created Time', create_time,
        'Endpoint', endpoint,
        'Services IPv4 CIDR', services_ipv4_cidr,
        'Status', status
      ) as properties
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_to_node_pool_node" {
  category = category.gcp_kubernetes_node_pool

  sql = <<-EOQ
    select
      p.name as id,
      p.title,
      jsonb_build_object(
        'Name', p.name,
        'Initial Node Count', p.initial_node_count,
        'Status', p.status,
        'Version', p.version
      ) as properties
    from
      gcp_kubernetes_node_pool p
    where
      p.cluster_name = $1;
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_to_node_pool_edge" {
  title = "node pool"

  sql = <<-EOQ
    select
      $1 as from_id,
      p.name as to_id
    from
      gcp_kubernetes_node_pool p
    where
      p.cluster_name = $1;
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_node_pool_to_compute_instance_group_node" {
  category = category.gcp_compute_instance_group

  sql = <<-EOQ
    select
      g.id::text as id,
      g.name as title,
      jsonb_build_object(
        'ID', g.id::text,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Instance Count', g.size,
        'Named Ports', g.named_ports
      ) as properties
    from
      gcp_kubernetes_node_pool p,
      gcp_compute_instance_group g,
      jsonb_array_elements_text(instance_group_urls) ig
    where
      p.cluster_name = $1
      and split_part(ig, 'instanceGroupManagers/', 2) = g.name;
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_node_pool_to_compute_instance_group_edge" {
  title = "instance group"

  sql = <<-EOQ
    select
      p.name as from_id,
      g.id::text as to_id
    from
      gcp_kubernetes_node_pool p,
      gcp_compute_instance_group g,
      jsonb_array_elements_text(instance_group_urls) ig
    where
      p.cluster_name = $1
      and split_part(ig, 'instanceGroupManagers/', 2) = g.name;
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_node_pool_to_compute_instance_node" {
  category = category.gcp_compute_instance

  sql = <<-EOQ
    select
      i.id::text,
      i.title,
      jsonb_build_object(
        'ID', i.id::text,
        'Name', i.name,
        'Created Time', i.creation_timestamp,
        'CPU Platform', i.cpu_platform,
        'Status', i.status
      ) as properties
    from
      gcp_kubernetes_node_pool p,
      gcp_compute_instance_group g,
      jsonb_array_elements_text(instance_group_urls) ig,
      jsonb_array_elements(g.instances) g_ins,
      gcp_compute_instance i
    where
      p.cluster_name = $1
      and split_part(ig, 'instanceGroupManagers/', 2) = g.name
      and i.self_link = (g_ins ->> 'instance')
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_node_pool_to_compute_instance_edge" {
  title = "node"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      i.id::text as to_id
    from
      gcp_kubernetes_node_pool p,
      gcp_compute_instance_group g,
      jsonb_array_elements_text(instance_group_urls) ig,
      jsonb_array_elements(g.instances) g_ins,
      gcp_compute_instance i
    where
      p.cluster_name = $1
      and split_part(ig, 'instanceGroupManagers/', 2) = g.name
      and i.self_link = (g_ins ->> 'instance')
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_to_compute_network_node" {
  category = category.gcp_compute_network

  sql = <<-EOQ
    select
      n.id::text as id,
      n.title,
      jsonb_build_object(
        'ID', n.id::text,
        'Name', n.name,
        'Created Time', n.creation_timestamp,
        'Location', n.location
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n
    where
      c.name = $1
      and c.network = n.name
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_to_compute_network_edge" {
  title = "network"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      n.id::text as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n,
      gcp_compute_subnetwork s
    where
      c.name = $1
      and c.network = n.name
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_network_to_compute_subnetwork_node" {
  category = category.gcp_compute_subnetwork

  sql = <<-EOQ
    select
      s.id::text as id,
      s.title,
      jsonb_build_object(
        'ID', s.id::text,
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Location', s.location,
        'IP Cidr Range', s.ip_cidr_range
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_compute_subnetwork s
    where
      c.name = $1
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_network_to_compute_subnetwork_edge" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      c.name as from_id,
      s.id::text as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n,
      gcp_compute_subnetwork s
    where
      c.name = $1
      and c.network = n.name
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_to_pubsub_topic_node" {
  category = category.gcp_pubsub_topic

  sql = <<-EOQ
    select
      t.name as id,
      t.title,
      jsonb_build_object(
        'Name', t.name,
        'Location', t.location,
        'KMS Key', t.kms_key_name
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_pubsub_topic t
    where
      c.name = $1
      and c.notification_config is not null
      and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%';
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_to_pubsub_topic_edge" {
  title = "notifies"

  sql = <<-EOQ
    select
      c.name as from_id,
      t.name as to_id,
      jsonb_build_object(
        'Notifications Enabled', (c.notification_config -> 'pubsub' ->> 'enabled')
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_pubsub_topic t
    where
      c.name = $1
      and c.notification_config is not null
      and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%';
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_to_kms_key_node" {
  category = category.gcp_kms_key

  sql = <<-EOQ
    select
      k.name as id,
      k.title,
      jsonb_build_object(
        'Name', k.name,
        'Created Time', k.create_time,
        'Key Ring Name', key_ring_name,
        'Location', k.location
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_kms_key k
    where
      c.name = $1
      and c.database_encryption_key_name is not null
      and split_part(c.database_encryption_key_name, 'cryptoKeys/', 2) = k.name;
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_to_kms_key_edge" {
  title = "database encrypted with"

  sql = <<-EOQ
    select
      c.name as from_id,
      k.name as to_id,
      jsonb_build_object(
        'Database Encryption State', c.database_encryption_state
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_kms_key k
    where
      c.name = $1
      and c.database_encryption_key_name is not null
      and split_part(c.database_encryption_key_name, 'cryptoKeys/', 2) = k.name;
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_to_bigquery_dataset_node" {
  category = category.gcp_bigquery_dataset

  sql = <<-EOQ
    select
      d.id,
      d.title,
      jsonb_build_object(
        'ID', d.id,
        'Created Time', d.creation_time,
        'Table Expiration(ms)', d.default_table_expiration_ms,
        'KMS Key', d.kms_key_name,
        'Location', d.location
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_bigquery_dataset d
    where
      c.name = $1
      and c.resource_usage_export_config -> 'bigqueryDestination' ->> 'datasetId' = d.dataset_id;
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_to_bigquery_dataset_edge" {
  title = "usage metering"

  sql = <<-EOQ
    select
      c.name as from_id,
      d.id as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_bigquery_dataset d
    where
      c.name = $1
      and c.resource_usage_export_config -> 'bigqueryDestination' ->> 'datasetId' = d.dataset_id;
  EOQ

  param "name" {}
}

node "gcp_kubernetes_cluster_to_compute_firewall_node" {
  category = category.gcp_compute_firewall

  sql = <<-EOQ
    select
      f.id::text,
      f.title,
      jsonb_build_object(
        'ID', f.id,
        'Direction', f.direction,
        'Enabled', not f.disabled,
        'Action', f.action,
        'Priority', f.priority
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n,
      gcp_compute_firewall f
    where
      c.network = n.name
      and n.self_link = f.network
      and c.name = $1;
  EOQ

  param "name" {}
}

edge "gcp_kubernetes_cluster_to_compute_firewall_edge" {
  title = "firewall"

  sql = <<-EOQ
    select
      c.name as from_id,
      f.id::text as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n,
      gcp_compute_firewall f
    where
      c.network = n.name
      and n.self_link = f.network
      and c.name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_overview" {
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
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_kubernetes_cluster
      where
        name = $1
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

  param "name" {}
}

query "gcp_kubernetes_cluster_ip_allocation_policy" {
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
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_addons_config" {
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
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_network_config" {
  sql = <<-EOQ
    select
      network_config ->> 'network' as "Network",
      network_config ->> 'subnetwork' as "Subnetwork",
      network_config -> 'defaultSnatStatus' as "Default SNAT Status",
      network_config ->> 'enableIntraNodeVisibility' as "Enable Intra Node Visibility"
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_lm" {
  sql = <<-EOQ
    select
      case when logging_service = 'none' then 'Disabled' else 'Enabled' end as "Logging Service",
      case when monitoring_service = 'none' then 'Disabled' else 'Enabled' end as "Monitoring Service"
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_notification_config" {
  sql = <<-EOQ
    select
      notification_config -> 'pubsub' ->> 'enabled' as "Enabled",
      notification_config -> 'pubsub' ->> 'topic' as "Topic"
    from
      gcp_kubernetes_cluster
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_private_cluster_config" {
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
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_kubernetes_cluster_node_detail" {
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
      name = $1;
  EOQ

  param "name" {}
}
