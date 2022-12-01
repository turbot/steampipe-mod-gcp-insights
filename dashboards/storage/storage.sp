locals {
  storage_common_tags = {
    service = "GCP/Storage"
  }
}

category "logging_bucket" {
  color = local.storage_color
  icon  = "archive-box-arrow-down"
  title = "Logging Bucket"
}

category "storage_bucket" {
  color = local.storage_color
  href  = "/gcp_insights.dashboard.storage_bucket_detail?input.bucket_id={{.properties.'ID' | @uri}}"
  icon  = "archive-box"
  title = "Storage Bucket"
}
