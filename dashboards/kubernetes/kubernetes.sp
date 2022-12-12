locals {
  kubernetes_common_tags = {
    service = "GCP/Kubernetes"
  }
}

category "kubernetes_cluster" {
  color = local.containers_color
  icon  = "hub"
  href  = "/gcp_insights.dashboard.kubernetes_cluster_detail?input.cluster_name={{.properties.'Name' | @uri}}"
  title = "Kubernetes Cluster"
}

category "kubernetes_node_pool" {
  color = local.containers_color
  icon  = "device-hub"
  title = "Kubernetes Node Pool"
}
