locals {
  kubernetes_common_tags = {
    service = "GCP/Kubernetes"
  }
}

category "gcp_kubernetes_cluster" {
  color = local.kubernetes_color
  icon  = "cog"
  href  = "/gcp_insights.dashboard.gcp_kubernetes_cluster_detail?input.cluster_name={{.properties.'Name' | @uri}}"
  title = "Kubernetes Cluster"
}

category "gcp_kubernetes_node_pool" {
  color = local.kubernetes_color
  icon  = "text:pool"
  title = "Kubernetes Node Pool"
}
