locals {
  vpc_common_tags = {
    service = "GCP/VPC"
  }
}

category "vpc_access_connector" {
  title = "GCP VPC Access Connector"
  color = local.networking_color
  icon  = "add_a_photo"
}

