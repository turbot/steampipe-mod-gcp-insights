locals {
  kubernetes_common_tags = {
    service = "GCP/Kubernetes"
  }
}

category "kubernetes_cluster" {
  color = local.containers_color
  icon  = "view_in_ar"
  href  = "/gcp_insights.dashboard.kubernetes_cluster_detail?input.cluster_id={{.properties.'ID' | @uri}}"
  title = "Kubernetes Cluster"
}

category "kubernetes_node_pool" {
  color = local.containers_color
  icon  = "device_hub"
  title = "Kubernetes Node Pool"
}
