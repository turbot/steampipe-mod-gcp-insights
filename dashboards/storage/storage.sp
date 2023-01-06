locals {
  storage_common_tags = {
    service = "GCP/Storage"
  }
}

category "storage_bucket" {
  title = "Storage Bucket"
  color = local.storage_color
  href  = "/gcp_insights.dashboard.storage_bucket_detail?input.bucket_id={{.properties.'ID' | @uri}}"
  icon  = "cleaning_bucket"
}
