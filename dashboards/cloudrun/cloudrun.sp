locals {
  cloudrun_common_tags = {
    service = "GCP/CloudRun"
  }
}

category "cloud_run_service" {
  title = "Cloud Run Service"
  color = local.compute_color
  icon  = "add_a_photo"
}
