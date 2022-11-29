locals {
  compute_common_tags = {
    service = "GCP/Compute"
  }
}

category "gcp_compute_address" {
  color = local.network_color
  icon  = "table-cells"
  title = "Compute Address"
}

category "gcp_compute_autoscaler" {
  color = local.compute_color
  icon  = "square-2-stack"
  title = "Compute Autoscaler"
}

category "gcp_compute_backend_bucket" {
  color = local.storage_color
  icon  = "archive-box"
  title = "Compute Backend Bucket"
}

category "gcp_compute_backend_service" {
  color = local.network_color
  icon  = "wrench-screwdriver"
  title = "Compute Backend Service"
}

category "gcp_compute_disk" {
  color = local.storage_color
  icon  = "inbox-stack"
  href  = "/gcp_insights.dashboard.gcp_compute_disk_detail?input.disk_id={{.properties.'ID' | @uri}}"
  title = "Compute Disk"
}

category "gcp_compute_forwarding_rule" {
  color = local.network_color
  icon  = "arrow-right-on-rectangle"
  href  = "/gcp_insights.dashboard.gcp_compute_forwarding_rule_detail?input.id={{.properties.'ID' | @uri}}"
  title = "Compute Forwarding Rule"
}

category "gcp_compute_firewall" {
  color = local.network_color
  icon  = "fire"
  title = "Compute Firewall Rule"
}

category "gcp_compute_image" {
  color = local.compute_color
  icon  = "text:image"
  title = "Compute Image"
}

category "gcp_compute_instance" {
  color = local.compute_color
  icon  = "cpu-chip"
  href  = "/gcp_insights.dashboard.gcp_compute_instance_detail?input.instance_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance"
}

category "gcp_compute_instance_group" {
  color = local.compute_color
  icon  = "rectangle-stack"
  href  = "/gcp_insights.dashboard.gcp_compute_instance_group_detail?input.group_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance Group"
}

category "gcp_compute_instance_template" {
  color = local.compute_color
  icon  = "newspaper"
  title = "Compute Instance Template"
}

category "gcp_compute_network" {
  color = local.network_color
  href  = "/gcp_insights.dashboard.gcp_compute_network_detail?input.network_name={{.properties.'Name' | @uri}}"
  icon  = "cloud"
  title = "Compute Network"
}

category "gcp_compute_network_interface" {
  color = local.network_color
  icon  = "text:NIC"
  title = "Compute Network Interface"
}

category "gcp_compute_router" {
  color = local.network_color
  icon  = "arrows-right-left"
  title = "Compute Router"
}

category "gcp_compute_snapshot" {
  color = local.storage_color
  icon  = "viewfinder-circle"
  title = "Compute Snapshot"
}

category "gcp_compute_subnetwork" {
  color = local.network_color
  icon  = "share"
  href  = "/gcp_insights.dashboard.gcp_compute_subnetwork_detail?input.subnetwork_id={{.properties.'ID' | @uri}}"
  title = "Compute Subnetwork"
}

category "gcp_compute_target_https_proxy" {
  color = local.network_color
  icon  = "text:THP"
  title = "Compute Target HTTPS Proxy"
}

category "gcp_compute_target_pool" {
  color = local.network_color
  icon  = "arrow-down-on-square"
  title = "Compute Target Pool"
}

category "gcp_compute_target_ssl_proxy" {
  color = local.network_color
  icon  = "text:TSP"
  title = "Compute Target SSL Proxy"
}

category "gcp_compute_vpn_gateway" {
  color = local.network_color
  icon  = "text:VPNGW"
  title = "Compute VPN Gateway"
}
