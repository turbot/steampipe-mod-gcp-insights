locals {
  compute_common_tags = {
    service = "GCP/Compute"
  }
}

category "compute_address" {
  color = local.networking_color
  icon  = "heroicons-outline:table-cells"
  title = "Compute Address"
}

category "compute_autoscaler" {
  color = local.compute_color
  icon  = "heroicons-outline:square-2-stack"
  title = "Compute Autoscaler"
}

category "compute_backend_bucket" {
  color = local.storage_color
  icon  = "heroicons-outline:archive-box"
  title = "Compute Backend Bucket"
}

category "compute_backend_service" {
  color = local.networking_color
  icon  = "heroicons-outline:wrench-screwdriver"
  title = "Compute Backend Service"
}

category "compute_disk" {
  color = local.storage_color
  icon  = "heroicons-outline:inbox-stack"
  href  = "/gcp_insights.dashboard.compute_disk_detail?input.disk_id={{.properties.'ID' | @uri}}"
  title = "Compute Disk"
}

category "compute_firewall" {
  color = local.networking_color
  icon  = "heroicons-outline:fire"
  title = "Compute Firewall Rule"
}

category "compute_forwarding_rule" {
  color = local.networking_color
  icon  = "heroicons-outline:arrow-right-on-rectangle"
  title = "Compute Forwarding Rule"
}

category "compute_image" {
  color = local.compute_color
  icon  = "developer-board"
  title = "Compute Image"
}

category "compute_instance" {
  color = local.compute_color
  icon  = "heroicons-outline:cpu-chip"
  href  = "/gcp_insights.dashboard.compute_instance_detail?input.instance_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance"
}

category "compute_instance_group" {
  color = local.compute_color
  icon  = "heroicons-outline:rectangle-stack"
  href  = "/gcp_insights.dashboard.compute_instance_group_detail?input.group_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance Group"
}

category "compute_instance_template" {
  color = local.compute_color
  icon  = "heroicons-outline:newspaper"
  title = "Compute Instance Template"
}

category "compute_instance" {
  color = local.compute_color
  icon  = "dns"
  href  = "/gcp_insights.dashboard.compute_instance_detail?input.instance_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance"
}

category "compute_network" {
  color = local.networking_color
  href  = "/gcp_insights.dashboard.compute_network_detail?input.network_name={{.properties.'Name' | @uri}}"
  icon  = "heroicons-outline:cloud"
  title = "Compute Network"
}

category "compute_network_interface" {
  color = local.network_color
  icon  = "memory"
  title = "Compute Network Interface"
}

category "compute_resource_policy" {
  color = local.compute_color
  icon  = "text:RP"
  title = "Resource Policy"
}

category "compute_router" {
  color = local.networking_color
  icon  = "heroicons-outline:arrows-right-left"
  title = "Compute Router"
}

category "compute_snapshot" {
  color = local.storage_color
  icon  = "heroicons-outline:viewfinder-circle"
  title = "Compute Snapshot"
}

category "compute_subnetwork" {
  color = local.networking_color
  icon  = "heroicons-outline:share"
  href  = "/gcp_insights.dashboard.compute_subnetwork_detail?input.subnetwork_id={{.properties.'ID' | @uri}}"
  title = "Compute Subnetwork"
}

category "compute_target_https_proxy" {
  color = local.networking_color
  icon  = "text:THP"
  title = "Compute Target HTTPS Proxy"
}

category "compute_target_pool" {
  color = local.networking_color
  icon  = "heroicons-outline:arrow-down-on-square"
  title = "Compute Target Pool"
}

category "compute_target_ssl_proxy" {
  color = local.networking_color
  icon  = "text:TSP"
  title = "Compute Target SSL Proxy"
}

category "compute_vpn_gateway" {
  color = local.network_color
  icon  = "vpn_lock"
  title = "Compute VPN Gateway"
}

