locals {
  dns_common_tags = {
    service = "GCP/DNS"
  }
}

category "dns_policy" {
  color = local.networking_color
  icon  = "heroicons-outline:globe-alt"
  title = "DNS Policy"
}
