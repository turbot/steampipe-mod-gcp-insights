locals {
  storage_common_tags = {
    service = "GCP/Storage"
  }
}

category "gcp_logging_bucket" {
  color = local.storage_color
  icon  = "archive-box-arrow-down"
  title = "Logging Bucket"
}

category "gcp_storage_bucket" {
  color = local.storage_color
  href  = "/gcp_insights.dashboard.gcp_storage_bucket_detail?input.bucket_id={{.properties.'ID' | @uri}}"
  icon  = "archive-box"
  title = "Storage Bucket"
}
