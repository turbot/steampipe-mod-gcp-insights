category "gcp_bigquery_dataset" {
  icon = local.gcp_bigquery_dataset
  fold {
    title     = "BigQuery Datasets"
    icon      = local.gcp_bigquery_dataset
    threshold = 3
  }
}

category "gcp_compute_address" {
  fold {
    title     = "Compute Address"
    threshold = 3
  }
}

category "gcp_compute_autoscaler" {
  fold {
    title     = "Compute Autoscalers"
    threshold = 3
  }
}

category "gcp_compute_backend_bucket" {
  fold {
    title     = "Compute Backend Buckets"
    threshold = 3
  }
}

category "gcp_compute_backend_service" {
  fold {
    title     = "Compute Backend Services"
    threshold = 3
  }
}

category "gcp_compute_disk" {
  href = "/gcp_insights.dashboard.gcp_compute_disk_detail?input.id={{.properties.'ID' | @uri}}"
  fold {
    title     = "Compute Disks"
    threshold = 3
  }
}

category "gcp_compute_firewall" {
  icon = local.gcp_compute_firewall
  fold {
    title     = "Compute Firewall Rules"
    icon      = local.gcp_compute_firewall
    threshold = 3
  }
}

category "gcp_compute_forwarding_rule" {
  fold {
    title     = "Compute Forwarding Rules"
    threshold = 3
  }
}

category "gcp_compute_health_check" {
  fold {
    title     = "Compute Health Checks"
    threshold = 3
  }
}

category "gcp_compute_image" {
  fold {
    title     = "Compute Images"
    threshold = 3
  }
}

category "gcp_compute_instance" {
  href = "/gcp_insights.dashboard.gcp_compute_instance_detail?input.id={{.properties.'ID' | @uri}}"
  icon = local.gcp_compute_instance
  fold {
    title     = "Compute Instances"
    icon      = local.gcp_compute_instance
    threshold = 3
  }
}

category "gcp_compute_instance_group" {
  href = "/gcp_insights.dashboard.gcp_compute_instance_group?input.id={{.properties.'ID' | @uri}}"
  fold {
    title     = "Compute Instance Groups"
    threshold = 3
  }
}

category "gcp_compute_instance_template" {
  fold {
    title     = "Compute Instance Templates"
    threshold = 3
  }
}

category "gcp_compute_machine_type" {
  fold {
    title     = "Compute Machine Types"
    threshold = 3
  }
}

category "gcp_compute_network" {
  href = "/gcp_insights.dashboard.gcp_compute_network_detail?input.name={{.properties.'Name' | @uri}}"
  icon = local.gcp_compute_network
  fold {
    title     = "Compute Networks"
    icon      = local.gcp_compute_network
    threshold = 3
  }
}

category "gcp_compute_network_interface" {
  fold {
    title     = "Compute Network Interfaces"
    threshold = 3
  }
}

category "gcp_compute_router" {
  icon = local.gcp_compute_router
  fold {
    title     = "Compute Routers"
    icon      = local.gcp_compute_router
    threshold = 3
  }
}

category "gcp_compute_snapshot" {
  fold {
    title     = "Compute Snapshots"
    threshold = 3
  }
}

category "gcp_compute_subnetwork" {
  href = "/gcp_insights.dashboard.gcp_compute_subnetwork_detail?input.id={{.properties.'ID' | @uri}}"
  fold {
    title     = "Compute Subnetworks"
    threshold = 3
  }
}

category "gcp_compute_vpn_gateway" {
  fold {
    title     = "Compute VPN Gateway"
    threshold = 3
  }
}

category "gcp_dns_policy" {
  fold {
    title     = "DNS Policy"
    threshold = 3
  }
}

category "gcp_kms_key" {
  # href = "/gcp_insights.dashboard.gcp_kms_key_detail?input.id={{.properties.'ID' | @uri}}"
  icon = local.gcp_kms_key
  fold {
    title     = "KMS Keys"
    icon      = local.gcp_kms_key
    threshold = 3
  }
}

category "gcp_kubernetes_cluster" {
  href = "/gcp_insights.dashboard.gcp_kubernetes_cluster_detail?input.name={{.properties.'Name' | @uri}}"
  icon = local.gcp_kubernetes_cluster
  fold {
    title     = "Kubernetes Clusters"
    icon      = local.gcp_kubernetes_cluster
    threshold = 3
  }
}

category "gcp_kubernetes_node_pool" {
  fold {
    title     = "Kubernetes Node Pools"
    threshold = 3
  }
}

category "gcp_logging_bucket" {
  fold {
    title     = "Logging Buckets"
    threshold = 3
  }
}

category "gcp_pubsub_topic" {
  icon = local.gcp_pubsub_topic
  fold {
    title     = "Pubsub Topics"
    icon      = local.gcp_pubsub_topic
    threshold = 3
  }
}

category "gcp_storage_bucket" {
  href = "/gcp_insights.dashboard.gcp_storage_bucket_detail?input.id={{.properties.'ID' | @uri}}"
  icon = local.gcp_storage_bucket
  fold {
    title     = "Storage Buckets"
    icon      = local.gcp_storage_bucket
    threshold = 3
  }
}

category "gcp_sql_database_instance" {
  fold {
    title     = "SQL Database Instances"
    threshold = 3
  }
}

graph "gcp_graph_categories" {
  type  = "graph"
  title = "Relationships"
}

category "gcp_pubsub_topic" {
  icon = local.gcp_pubsub_topic
  fold {
    title     = "Pub/Sub Topic"
    icon      = local.gcp_pubsub_topic
    threshold = 3
  }
}

category "gcp_pubsub_subscription" {
  fold {
    title     = "Pub/Sub Subscription"
    threshold = 3
  }
}

category "gcp_iam_role" {
  fold {
    title     = "IAM Role"
    threshold = 3
  }
}