locals {
  kubernetes_common_tags = {
    service = "GCP/Kubernetes"
  }
}

category "kubernetes_cluster" {
  title = "Kubernetes Cluster"
  color = local.containers_color
  href  = "/gcp_insights.dashboard.kubernetes_cluster_detail?input.cluster_id={{.properties.'ID' | @uri}}"
  icon  = "view_in_ar"
}

category "kubernetes_node_pool" {
  title = "Kubernetes Node Pool"
  color = local.containers_color
  icon  = "device_hub"
}
