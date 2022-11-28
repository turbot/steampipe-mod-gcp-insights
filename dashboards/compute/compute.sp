locals {
  compute_common_tags = {
    service = "GCP/Compute"
  }
}

category "gcp_compute_resource_policy" {
  color = local.compute_color
  icon  = "text:RP"
  title = "Resource Policy"
}
