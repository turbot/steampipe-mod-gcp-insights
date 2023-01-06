locals {
  logging_common_tags = {
    service = "GCP/Logging"
  }
}

category "logging_bucket" {
  title = "Logging Bucket"
  color = local.storage_color
  icon  = "library_books"
}