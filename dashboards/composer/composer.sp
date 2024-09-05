locals {
  composer_common_tags = {
    service = "GCP/Composer"
  }
}

category "composer_environment" {
  title = "Compute Environment"
  color = local.orange
  icon  = "add_a_photo"
}