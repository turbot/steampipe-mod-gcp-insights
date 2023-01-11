node "compute_address" {
  category = category.compute_address

  sql = <<-EOQ
    select
      a.id::text,
      a.title,
      jsonb_build_object(
        'ID', a.id::text,
        'Created Time', a.creation_timestamp,
        'Address', a.address,
        'Address Type', a.address_type,
        'Purpose', a.purpose,
        'Status', a.status,
        'Project', project
      ) as properties
    from
      gcp_compute_address a
    where
      a.id = any($1)

    union

    select
      a.id::text,
      a.title,
      jsonb_build_object(
        'ID', a.id::text,
        'Created Time', a.creation_timestamp,
        'Address', a.address,
        'Address Type', a.address_type,
        'Purpose', a.purpose,
        'Status', a.status,
        'Project', project
      ) as properties
    from
      gcp_compute_global_address a
    where
      a.id = any($1)
  EOQ

  param "compute_address_ids" {}
}

node "compute_autoscaler" {
  category = category.compute_autoscaler

  sql = <<-EOQ
    select
      a.id::text,
      a.title,
      jsonb_build_object(
        'ID', a.id::text,
        'Name', a.name,
        'Created Time', a.creation_timestamp,
        'Status', a.status,
        'Location', a.location,
        'Project', project
      ) as properties
    from
      gcp_compute_autoscaler a
    where
      a.id = any($1);
  EOQ

  param "compute_autoscaler_ids" {}
}

node "compute_backend_bucket" {
  category = category.compute_backend_bucket

  sql = <<-EOQ
    select
      c.id::text,
      c.title,
      jsonb_build_object(
        'Name', c.name,
        'Created Time', c.creation_timestamp,
        'Description', c.description,
        'Location', c.location,
        'Project', project
      ) as properties
    from
      gcp_compute_backend_bucket c
    where
      c.id = any($1);
  EOQ

  param "compute_backend_bucket_ids" {}
}

node "compute_backend_service" {
  category = category.compute_backend_service

  sql = <<-EOQ
    select
      bs.id::text,
      bs.title,
      jsonb_build_object(
        'ID', bs.id::text,
        'Name', bs.name,
        'Enable CDN', bs.enable_cdn,
        'Protocol', bs.protocol,
        'Location', bs.location,
        'Project', project
      ) as properties
    from
      gcp_compute_backend_service bs
    where
      bs.id = any($1);
  EOQ

  param "compute_backend_service_ids" {}
}

node "compute_disk" {
  category = category.compute_disk

  sql = <<-EOQ
    select
      id::text,
      title,
      jsonb_build_object(
        'ID', id::text,
        'Name', name,
        'Created Time', creation_timestamp,
        'Size(GB)', size_gb,
        'Status', status,
        'Encryption Key Type', disk_encryption_key_type,
        'Project', project
      ) as properties
    from
      gcp_compute_disk
    where
      id = any($1);
  EOQ

  param "compute_disk_ids" {}
}

node "compute_firewall" {
  category = category.compute_firewall

  sql = <<-EOQ
    select
      f.id::text,
      f.title,
      jsonb_build_object(
        'ID', f.id::text,
        'Direction', f.direction,
        'Enabled', not f.disabled,
        'Action', f.action,
        'Priority', f.priority,
        'Project', project
      ) as properties
    from
      gcp_compute_firewall f
    where
      f.id = any($1);
  EOQ

  param "compute_firewall_ids" {}
}

node "compute_forwarding_rule" {
  category = category.compute_forwarding_rule

  sql = <<-EOQ
    select
      r.id::text,
      r.title,
      jsonb_build_object(
        'ID', r.id::text,
        'Created Time', r.creation_timestamp,
        'IP Address', r.ip_address,
        'Global Access', r.allow_global_access,
        'Load Balancing Scheme', r.load_balancing_scheme,
        'Network Tier', r.network_tier,
        'Project', project
      ) as properties
    from
      gcp_compute_forwarding_rule r
    where
      r.id = any($1)

    union

    select
      r.id::text,
      r.title,
      jsonb_build_object(
        'ID', r.id::text,
        'Created Time', r.creation_timestamp,
        'IP Address', r.ip_address,
        'Global Access', r.allow_global_access,
        'Load Balancing Scheme', r.load_balancing_scheme,
        'Network Tier', r.network_tier,
        'Project', project
      ) as properties
    from
      gcp_compute_global_forwarding_rule r
    where
      r.id = any($1)
  EOQ

  param "compute_forwarding_rule_ids" {}
}

node "compute_image" {
  category = category.compute_image

  sql = <<-EOQ
    select
      i.id::text,
      i.title,
      jsonb_build_object(
        'ID', i.id::text,
        'Name', i.name,
        'Created Time', i.creation_timestamp,
        'Size(GB)', i.disk_size_gb,
        'Status', i.status
      ) as properties
    from
      gcp_compute_image i
    where
      i.id = any($1);
  EOQ

  param "compute_image_ids" {}
}

node "compute_instance" {
  category = category.compute_instance

  sql = <<-EOQ
    select
      id::text,
      title,
      jsonb_build_object(
        'ID', id::text,
        'Name', name,
        'Created Time', creation_timestamp,
        'CPU Platform', cpu_platform,
        'Status', status,
        'Location', location,
        'Project', project
      ) as properties
    from
      gcp_compute_instance
    where
      id = any($1);
  EOQ

  param "compute_instance_ids" {}
}

node "compute_instance_group" {
  category = category.compute_instance_group

  sql = <<-EOQ
    select
      id::text,
      title,
      jsonb_build_object(
        'ID', g.id::text,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Instance Count', g.size,
        'Named Ports', g.named_ports,
        'Project', project
      ) as properties
    from
      gcp_compute_instance_group g
    where
      id = any($1);
  EOQ

  param "compute_instance_group_ids" {}
}

node "compute_instance_template" {
  category = category.compute_instance_template

  sql = <<-EOQ
    select
      t.id::text,
      t.title,
      jsonb_build_object(
        'ID', t.id::text,
        'Name', t.name,
        'Created Time', t.creation_timestamp,
        'Location', t.location,
        'Project', project
      ) as properties
    from
      gcp_compute_instance_template t
    where
      t.id = any($1);
  EOQ

  param "compute_instance_template_ids" {}
}

node "compute_network" {
  category = category.compute_network

  sql = <<-EOQ
    select
      n.id::text as id,
      n.title,
      jsonb_build_object(
        'ID', n.id::text,
        'Name', n.name,
        'Created Time', n.creation_timestamp,
        'Project', project
      ) as properties
    from
      gcp_compute_network n
    where
      n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

node "compute_network_peers" {
  category = category.compute_network_peers

  sql = <<-EOQ
    with peer_network as (
      select
        p ->> 'name' as name,
        p ->> 'state' as state,
        'projects' || split_part(p ->> 'network', 'projects', 2) as network,
        p ->> 'autoCreateRoutes' as auto_create_routes,
        p ->> 'exchangeSubnetRoutes' as exchange_subnet_routes,
        p ->> 'exportSubnetRoutesWithPublicIp' as export_subnet_routes_with_public_ip
      from
        gcp_compute_network,
        jsonb_array_elements(peerings) as p
      where
        id = any($1)
    )
    select
      network as id,
      name as title,
      jsonb_build_object(
        'State', state,
        'Project', split_part(network, '/', 2),
        'Network', network,
        'Auto Create Routes', auto_create_routes,
        'Exchange Subnet Routes', exchange_subnet_routes,
        'Export Subnet Routes With Public IP', export_subnet_routes_with_public_ip
      ) as properties
    from
      peer_network;
  EOQ

  param "compute_network_ids" {}
}

node "compute_resource_policy" {
  category = category.compute_resource_policy

  sql = <<-EOQ
   select
      r.id::text,
      r.title,
      jsonb_build_object(
        'Name', r.name,
        'Created Time', r.creation_timestamp,
        'Status', r.status,
        'Project', project
      ) as properties
    from
      gcp_compute_resource_policy r
    where
      r.id = any($1);
  EOQ

  param "compute_resource_policy_ids" {}
}

node "compute_router" {
  category = category.compute_router

  sql = <<-EOQ
    select
      r.id::text,
      r.title,
      jsonb_build_object(
        'ID', r.id::text,
        'Name', r.name,
        'Created Time', r.creation_timestamp,
        'Location', r.location,
        'Project', project
      ) as properties
    from
      gcp_compute_router r
    where
      r.id = any($1);
  EOQ

  param "compute_router_ids" {}
}

node "compute_snapshot" {
  category = category.compute_snapshot

  sql = <<-EOQ
    select
      s.name as id,
      s.title,
      jsonb_build_object(
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Size(GB)', s.disk_size_gb,
        'Status', s.status,
        'Project', project
      ) as properties
    from
      gcp_compute_snapshot s
    where
      s.name = any($1);
  EOQ

  param "compute_snapshot_names" {}
}

node "compute_subnetwork" {
  category = category.compute_subnetwork

  sql = <<-EOQ
    select
      s.id::text,
      s.title,
      jsonb_build_object(
        'ID', s.id::text,
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Location', s.location,
        'IP Cidr Range', s.ip_cidr_range,
        'Project', project
      ) as properties
    from
      gcp_compute_subnetwork s
    where
      s.id = any($1);
  EOQ

  param "compute_subnetwork_ids" {}
}

node "compute_vpn_gateway" {
  category = category.compute_vpn_gateway

  sql = <<-EOQ
    select
      g.id::text,
      g.title,
      jsonb_build_object(
        'ID', g.id::text,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Location', g.location,
        'Project', project
      ) as properties
    from
      gcp_compute_ha_vpn_gateway g
    where
      g.id = any($1);
  EOQ

  param "compute_vpn_gateway_ids" {}
}
