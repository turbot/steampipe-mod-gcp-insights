category "gcp_bigquery_dataset" {
  color = local.sql_color
  icon  = "square-3-stack-3d"
  title = "BigQuery Dataset"
}

category "gcp_bigquery_table" {
  color = local.sql_color
  icon  = "table-cells"
  title = "BigQuery Table"
}

category "gcp_compute_address" {
  color = local.network_color
  icon  = "map-pin"
  title = "Compute Address"
}

category "gcp_compute_autoscaler" {
  color = local.network_color
  icon  = "square-2-stack"
  title = "Compute Autoscaler"
}

category "gcp_compute_backend_bucket" {
  color = local.storage_color
  icon  = "archive-box"
  title = "Compute Backend Bucket"
}

category "gcp_compute_backend_service" {
  color = local.compute_color
  icon  = "wrench-screwdriver"
  title = "Compute Backend Service"
}

category "gcp_compute_disk" {
  color = local.compute_color
  icon  = "inbox-stack"
  href  = "/gcp_insights.dashboard.gcp_compute_disk_detail?input.disk_id={{.properties.'ID' | @uri}}"
  title = "Compute Disk"
}

category "gcp_compute_forwarding_rule" {
  color = local.network_color
  icon  = "arrow-right-on-rectangle"
  href  = "/gcp_insights.dashboard.gcp_compute_forwarding_rule_detail?input.id={{.properties.'ID' | @uri}}"
  title = "Compute Forwarding Rule"
}

category "gcp_compute_firewall" {
  color = local.compute_color
  icon  = "fire"
  title = "Compute Firewall Rule"
}

category "gcp_compute_image" {
  color = local.compute_color
  icon  = "rectangle-group"
  title = "Compute Image"
}

category "gcp_compute_instance" {
  color = local.compute_color
  icon  = "cpu-chip"
  href  = "/gcp_insights.dashboard.gcp_compute_instance_detail?input.instance_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance"
}

category "gcp_compute_instance_group" {
  color = local.compute_color
  icon  = "rectangle-stack"
  href  = "/gcp_insights.dashboard.gcp_compute_instance_group_detail?input.group_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance Group"
}

category "gcp_compute_instance_template" {
  color = local.compute_color
  icon  = "newspaper"
  title = "Compute Instance Template"
}

category "gcp_compute_network" {
  color = local.network_color
  href  = "/gcp_insights.dashboard.gcp_compute_network_detail?input.network_name={{.properties.'Name' | @uri}}"
  icon  = "cloud"
  title = "Compute Network"
}

category "gcp_compute_network_interface" {
  color = local.network_color
  icon  = "text:CNI"
  title = "Compute Network Interface"
}

category "gcp_compute_router" {
  color = local.network_color
  icon  = "arrows-right-left"
  title = "Compute Router"
}

category "gcp_compute_snapshot" {
  color = local.compute_color
  icon  = "viewfinder-circle"
  title = "Compute Snapshot"
}

category "gcp_compute_subnetwork" {
  color = local.network_color
  icon  = "share"
  href  = "/gcp_insights.dashboard.gcp_compute_subnetwork_detail?input.subnetwork_id={{.properties.'ID' | @uri}}"
  title = "Compute Subnetwork"
}

category "gcp_compute_vpn_gateway" {
  color = local.network_color
  icon  = "text:VPNGW"
  title = "Compute VPN Gateway"
}

category "gcp_compute_target_pool" {
  color = local.network_color
  icon  = "arrow-down-on-square"
  title = "Compute Target Pool"
}

category "gcp_compute_target_https_proxy" {
  color = local.network_color
  icon  = "text:THP"
  title = "Compute Target HTTPS Proxy"
}

category "gcp_compute_target_ssl_proxy" {
  color = local.network_color
  icon  = "text:TSP"
  title = "Compute Target SSL Proxy"
}

category "gcp_dns_policy" {
  color = local.dns_color
  icon  = "globe-alt"
  title = "DNS Policy"
}

category "gcp_iam_role" {
  color = local.iam_color
  icon  = "user-plus"
  title = "IAM Role"
}

category "gcp_kms_key" {
  color = local.kms_color
  href  = "/gcp_insights.dashboard.gcp_kms_key_detail?input.key_name={{.properties.'Name' | @uri}}"
  icon  = "key"
  title = "KMS Key"
}

category "gcp_kms_key_ring" {
  color = local.kms_color
  icon  = "key"
  title = "KMS Key Ring"
}

category "gcp_kms_key_version" {
  color = local.kms_color
  icon  = "key"
  title = "KMS Key Version"
}

category "gcp_kubernetes_cluster" {
  color = local.kubernetes_color
  icon  = "cog"
  href  = "/gcp_insights.dashboard.gcp_kubernetes_cluster_detail?input.cluster_name={{.properties.'Name' | @uri}}"
  title = "Kubernetes Cluster"
}

category "gcp_kubernetes_node_pool" {
  color = local.kubernetes_color
  icon  = "squares-2x2"
  title = "Kubernetes Node Pool"
}

category "gcp_logging_bucket" {
  color = local.logging_color
  icon  = "archive-box-arrow-down"
  title = "Logging Bucket"
}

category "gcp_pubsub_subscription" {
  color = local.pubsub_color
  icon  = "rss"
  title = "Pub/Sub Subscription"
}

category "gcp_pubsub_topic" {
  color = local.pubsub_color
  href  = "/gcp_insights.dashboard.gcp_pubsub_topic_detail?input.name={{.properties.'Name' | @uri}}"
  icon  = "text:PST"
  title = "Pubsub Topic"
}

category "gcp_storage_bucket" {
  color = local.storage_color
  href  = "/gcp_insights.dashboard.gcp_storage_bucket_detail?input.bucket_id={{.properties.'ID' | @uri}}"
  icon  = "archive-box"
  title = "Storage Bucket"
}

category "gcp_sql_backup" {
  color = local.sql_color
  icon  = "arrow-down-on-square-stack"
  title = "GCP SQL Backup"
}

category "gcp_sql_database_instance" {
  color = local.sql_color
  href  = "/gcp_insights.dashboard.gcp_sql_database_instance_detail?input.database_instance_name={{.properties.'Name' | @uri}}"
  icon  = "circle-stack"
  title = "SQL Database Instance"
}

category "gcp_sql_database" {
  color = local.sql_color
  icon  = "square-3-stack-3d"
  title = "GCP SQL Database"
}
