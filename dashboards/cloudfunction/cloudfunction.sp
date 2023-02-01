locals {
  cloudfunction_common_tags = {
    service = "GCP/Cloudfunction"
  }
}

category "cloudfunctions_function" {
  title = "Cloudfunction Function"
  color = local.compute_color
  icon  = "function"
}