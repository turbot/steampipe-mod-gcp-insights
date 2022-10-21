category "gcp_compute_backend_bucket" {
  fold {
    title     = "Compute Backend Bucket"
    threshold = 3
  }
}

category "gcp_kms_key" {
  href = "/gcp_insights.dashboard.gcp_kms_key_detail?input.id={{.properties.'ID' | @uri}}"
  icon = local.gcp_kms_key
  fold {
    title     = "KMS Key"
    icon      = local.gcp_kms_key
    threshold = 3
  }
}

category "gcp_logging_bucket" {
  fold {
    title     = "Logging Bucket"
    threshold = 3
  }
}

category "gcp_storage_bucket" {
  href = "/gcp_insights.dashboard.gcp_storage_bucket_detail?input.id={{.properties.'ID' | @uri}}"
  icon = local.gcp_storage_bucket
  fold {
    title     = "Storage Bucket"
    icon      = local.gcp_storage_bucket
    threshold = 3
  }
}

graph "gcp_graph_categories" {
  type  = "graph"
  title = "Relationships"
}
