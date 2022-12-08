locals {
  kubernetes_common_tags = {
    service = "GCP/Kubernetes"
  }
}

category "kubernetes_cluster" {
  color = local.kubernetes_color
  icon  = "heroicons-outline:cog"
  href  = "/gcp_insights.dashboard.kubernetes_cluster_detail?input.cluster_name={{.properties.'Name' | @uri}}"
  title = "Kubernetes Cluster"
}

category "kubernetes_node_pool" {
  color = local.kubernetes_color
  icon  = "text:pool"
  title = "Kubernetes Node Pool"
}
