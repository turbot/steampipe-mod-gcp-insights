locals {
  logging_common_tags = {
    service = "GCP/Logging"
  }
}

category "logging_bucket" {
  color = local.storage_color
  icon  = "archive-box-arrow-down"
  title = "Logging Bucket"
}