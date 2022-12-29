locals {
  compute_common_tags = {
    service = "GCP/Compute"
  }
}

category "compute_address" {
  color = local.networking_color
  icon  = "swipe_right_alt"
  title = "Compute Address"
}

category "compute_autoscaler" {
  color = local.compute_color
  icon  = "library_add"
  title = "Compute Autoscaler"
}

category "compute_backend_bucket" {
  color = local.storage_color
  icon  = "cleaning_bucket"
  title = "Compute Backend Bucket"
}

category "compute_backend_service" {
  color = local.networking_color
  icon  = "text:BS"
  title = "Compute Backend Service"
}

category "compute_disk" {
  color = local.storage_color
  icon  = "hard_drive"
  href  = "/gcp_insights.dashboard.compute_disk_detail?input.disk_id={{.properties.'ID' | @uri}}"
  title = "Compute Disk"
}

category "compute_firewall" {
  color = local.networking_color
  icon  = "enhanced_encryption"
  title = "Compute Firewall Rule"
}

category "compute_forwarding_rule" {
  color = local.networking_color
  icon  = "text:FR"
  title = "Compute Forwarding Rule"
}

category "compute_image" {
  color = local.compute_color
  icon  = "image"
  title = "Compute Image"
}

category "compute_instance_group" {
  color = local.compute_color
  icon  = "hub"
  href  = "/gcp_insights.dashboard.compute_instance_group_detail?input.group_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance Group"
}

category "compute_instance_template" {
  color = local.compute_color
  icon  = "rocket_launch"
  title = "Compute Instance Template"
}

category "compute_instance" {
  color = local.compute_color
  icon  = "memory"
  href  = "/gcp_insights.dashboard.compute_instance_detail?input.instance_id={{.properties.'ID' | @uri}}"
  title = "Compute Instance"
}

category "compute_network" {
  color = local.networking_color
  href  = "/gcp_insights.dashboard.compute_network_detail?input.network_id={{.properties.'ID' | @uri}}"
  icon  = "cloud"
  title = "Compute Network"
}

category "compute_network_interface" {
  color = local.networking_color
  icon  = "settings_input_antenna"
  title = "Compute Network Interface"
}

category "compute_resource_policy" {
  color = local.compute_color
  icon  = "text:RP"
  title = "Resource Policy"
}

category "compute_router" {
  color = local.networking_color
  icon  = "table_rows"
  title = "Compute Router"
}

category "compute_snapshot" {
  color = local.storage_color
  icon  = "add_a_photo"
  title = "Compute Snapshot"
}

category "compute_subnetwork" {
  color = local.networking_color
  icon  = "lan"
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
  icon  = "directions"
  title = "Compute Target Pool"
}

category "compute_target_ssl_proxy" {
  color = local.networking_color
  icon  = "text:TSP"
  title = "Compute Target SSL Proxy"
}

category "compute_vpn_gateway" {
  color = local.networking_color
  icon  = "vpn_lock"
  title = "Compute VPN Gateway"
}

