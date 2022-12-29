locals {
  logging_common_tags = {
    service = "GCP/Logging"
  }
}

category "logging_bucket" {
  color = local.storage_color
  icon  = "library_books"
  title = "Logging Bucket"
}