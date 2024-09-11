locals {
  cloudrun_common_tags = {
    service = "GCP/CloudRun"
  }
}

category "cloud_run_service" {
  title = "Cloud Run Service"
  color = local.storage_color
  # href  = "/gcp_insights.dashboard.storage_bucket_detail?input.bucket_id={{.properties.'ID' | @uri}}"
  icon  = "cleaning_bucket"
}
