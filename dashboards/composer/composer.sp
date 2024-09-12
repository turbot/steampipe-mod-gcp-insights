locals {
  composer_common_tags = {
    service = "GCP/Composer"
  }
}

category "composer_environment" {
  title = "Composer Environment"
  color = local.application_integration_color
  icon  = "add_a_photo"
}