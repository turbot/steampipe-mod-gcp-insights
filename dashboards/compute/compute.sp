locals {
  compute_common_tags = {
    service = "GCP/Compute"
  }
}

category "compute_address" {
  title = "Compute Address"
  color = local.networking_color
  icon  = "swipe_right_alt"
}

category "compute_autoscaler" {
  title = "Compute Autoscaler"
  color = local.compute_color
  icon  = "library_add"
}

category "compute_backend_bucket" {
  title = "Compute Backend Bucket"
  color = local.storage_color
  icon  = "cleaning_bucket"
}

category "compute_backend_service" {
  title = "Compute Backend Service"
  color = local.networking_color
  icon  = "grid_view"
}

category "compute_disk" {
  title = "Compute Disk"
  color = local.storage_color
  href  = "/gcp_insights.dashboard.compute_disk_detail?input.disk_id={{.properties.'ID' | @uri}}"
  icon  = "hard_drive"
}

category "compute_firewall" {
  title = "Compute Firewall Rule"
  color = local.networking_color
  icon  = "enhanced_encryption"
}

category "compute_forwarding_rule" {
  title = "Compute Forwarding Rule"
  color = local.networking_color
  icon  = "arrow_forward_ios"

}

category "compute_image" {
  title = "Compute Image"
  color = local.compute_color
  icon  = "image"
}

category "compute_instance_group" {
  title = "Compute Instance Group"
  color = local.compute_color
  href  = "/gcp_insights.dashboard.compute_instance_group_detail?input.group_id={{.properties.'ID' | @uri}}"
  icon  = "hub"
}

category "compute_instance_template" {
  title = "Compute Instance Template"
  color = local.compute_color
  icon  = "rocket_launch"
}

category "compute_instance" {
  title = "Compute Instance"
  color = local.compute_color
  href  = "/gcp_insights.dashboard.compute_instance_detail?input.instance_id={{.properties.'ID' | @uri}}"
  icon  = "memory"
}

category "compute_network" {
  title = "Compute Network"
  color = local.networking_color
  href  = "/gcp_insights.dashboard.compute_network_detail?input.network_id={{.properties.'ID' | @uri}}"
  icon  = "cloud"
}

category "compute_network_peers" {
  title = "Compute Network Peers"
  color = local.networking_color
  icon  = "cloud"
}

category "compute_network_interface" {
  title = "Compute Network Interface"
  color = local.networking_color
  icon  = "settings_input_antenna"
}

category "compute_resource_policy" {
  title = "Resource Policy"
  color = local.compute_color
  icon  = "rule_folder"
}

category "compute_router" {
  title = "Compute Router"
  color = local.networking_color
  icon  = "table_rows"
}

category "compute_snapshot" {
  title = "Compute Snapshot"
  color = local.storage_color
  icon  = "add_a_photo"
}

category "compute_subnetwork" {
  title = "Compute Subnet"
  color = local.networking_color
  href  = "/gcp_insights.dashboard.compute_subnetwork_detail?input.subnetwork_id={{.properties.'ID' | @uri}}"
  icon  = "lan"
}

category "compute_target_https_proxy" {
  title = "Compute Target HTTPS Proxy"
  color = local.networking_color
  icon  = "https"
}

category "compute_target_pool" {
  title = "Compute Target Pool"
  color = local.networking_color
  icon  = "directions"
}

category "compute_target_ssl_proxy" {
  title = "Compute Target SSL Proxy"
  color = local.networking_color
  icon  = "private_connectivity"
}

category "compute_vpn_gateway" {
  title = "Compute VPN Gateway"
  color = local.networking_color
  icon  = "vpn_lock"
}

