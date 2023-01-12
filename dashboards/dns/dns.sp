locals {
  dns_common_tags = {
    service = "GCP/DNS"
  }
}

category "dns_policy" {
  title = "DNS Policy"
  color = local.networking_color
  icon  = "policy"
}
