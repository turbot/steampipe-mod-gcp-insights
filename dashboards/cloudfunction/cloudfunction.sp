locals {
  cloudfunction_common_tags = {
    service = "GCP/CloudFunctions"
  }
}

category "cloudfunctions_function" {
  title = "CloudFunctions Function"
  color = local.compute_color
  icon  = "function"
}
