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
