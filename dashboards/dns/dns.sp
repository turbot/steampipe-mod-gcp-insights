locals {
  dns_common_tags = {
    service = "GCP/DNS"
  }
}

category "dns_policy" {
  color = local.networking_color
  icon  = "text:DP"
  title = "DNS Policy"
}
