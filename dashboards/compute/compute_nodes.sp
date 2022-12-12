node "compute_address" {
  category = category.compute_address

  sql = <<-EOQ
    select
      a.id::text,
      a.title,
      jsonb_build_object(
        'ID', a.id,
        'Created Time', a.creation_timestamp,
        'Address', a.address,
        'Address Type', a.address_type,
        'Purpose', a.purpose,
        'Status', a.status
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
        'ID', a.id,
        'Created Time', a.creation_timestamp,
        'Address', a.address,
        'Address Type', a.address_type,
        'Purpose', a.purpose,
        'Status', a.status
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
        'ID', a.id,
        'Name', a.name,
        'Created Time', a.creation_timestamp,
        'Status', a.status,
        'Location', a.location
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
      c.id::text as id,
      c.title,
      jsonb_build_object(
        'Name', c.name,
        'Created Time', c.creation_timestamp,
        'Description', c.description,
        'Location', c.location
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
        'ID', bs.id,
        'Name', bs.name,
        'Enable CDN', bs.enable_cdn,
        'Protocol', bs.protocol,
        'Location', bs.location
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
        'ID', id,
        'Name', name,
        'Created Time', creation_timestamp,
        'Size(GB)', size_gb,
        'Status', status,
        'Encryption Key Type', disk_encryption_key_type
      ) as properties
    from
      gcp_compute_disk
    where
      id = any($1);
  EOQ

  param "compute_disk_ids" {}
}

node "compute_disk_from_compute_disk" {
  category = category.compute_disk

  sql = <<-EOQ
    select
      cd.id::text,
      cd.title,
      jsonb_build_object(
        'ID', cd.id::text,
        'Name', cd.name,
        'Created Time', cd.creation_timestamp,
        'Size(GB)', cd.size_gb,
        'Status', cd.status,
        'Encryption Key Type', cd.disk_encryption_key_type
      ) as properties
    from
      gcp_compute_disk d,
      gcp_compute_disk cd
    where
      d.id = any($1)
      and d.source_disk_id = cd.id::text;
  EOQ

  param "compute_disk_ids" {}
}

node "compute_disk_from_compute_image" {
  category = category.compute_snapshot

  sql = <<-EOQ
    select
      i.id::text,
      i.title,
      jsonb_build_object(
        'Name', i.name,
        'Created Time', i.creation_timestamp,
        'Size(GB)', i.disk_size_gb,
        'Status', i.status
      ) as properties
    from
      gcp_compute_disk d,
      gcp_compute_image i
    where
      d.id = any($1)
      and d.source_image = i.self_link;
  EOQ

  param "compute_disk_ids" {}
}

node "compute_disk_from_compute_snapshot" {
  category = category.compute_snapshot

  sql = <<-EOQ
    select
      s.name,
      s.title,
      jsonb_build_object(
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Size(GB)', s.disk_size_gb,
        'Status', s.status
      ) as properties
    from
      gcp_compute_disk d,
      gcp_compute_snapshot s
    where
      d.id = any($1)
      and d.source_snapshot = s.self_link;
  EOQ

  param "compute_disk_ids" {}
}

node "compute_disk_to_compute_disk" {
  category = category.compute_disk

  sql = <<-EOQ
    select
      cd.id::text,
      cd.title,
      jsonb_build_object(
        'ID', cd.id::text,
        'Name', cd.name,
        'Created Time', cd.creation_timestamp,
        'Size(GB)', cd.size_gb,
        'Status', cd.status,
        'Encryption Key Type', cd.disk_encryption_key_type
      ) as properties
    from
      gcp_compute_disk d,
      gcp_compute_disk cd
    where
      d.id = any($1)
      and d.id::text = cd.source_disk_id;
  EOQ

  param "compute_disk_ids" {}
}

node "compute_disk_to_compute_image" {
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
      gcp_compute_disk d,
      gcp_compute_image i
    where
      d.id = any($1)
      and d.self_link = i.source_disk;
  EOQ

  param "compute_disk_ids" {}
}

node "compute_disk_to_compute_snapshot" {
  category = category.compute_snapshot

  sql = <<-EOQ
    select
      s.name as id,
      s.title,
      jsonb_build_object(
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Size(GB)', s.disk_size_gb,
        'Status', s.status
      ) as properties
    from
      gcp_compute_disk d,
      gcp_compute_snapshot s
    where
      d.id = any($1)
      and d.self_link = s.source_disk;
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
        'ID', f.id,
        'Direction', f.direction,
        'Enabled', not f.disabled,
        'Action', f.action,
        'Priority', f.priority
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
        'Network Tier', r.network_tier
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
        'Network Tier', r.network_tier
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
        'ID', id,
        'Name', name,
        'Created Time', creation_timestamp,
        'CPU Platform', cpu_platform,
        'Status', status
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
        'ID', g.id,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Instance Count', g.size,
        'Named Ports', g.named_ports
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
        'ID', t.id,
        'Name', t.name,
        'Created Time', t.creation_timestamp,
        'Location', t.location
      ) as properties
    from
      gcp_compute_instance_template t
    where
      t.id = $1;
  EOQ

  param "compute_instance_template_ids" {}
}

node "compute_network" {
  category = category.compute_network

  sql = <<-EOQ
    select
      n.name as id,
      n.title,
      jsonb_build_object(
        'ID', n.id,
        'Name', n.name,
        'Created Time', n.creation_timestamp
      ) as properties
    from
      gcp_compute_network n
    where
      n.name = any($1);
  EOQ

  param "compute_network_names" {}
}

node "compute_resource_policy" {
  category = category.compute_resource_policy

  sql = <<-EOQ
   select
      r.id as id,
      r.title,
      jsonb_build_object(
        'Name', r.name,
        'Created Time', r.creation_timestamp,
        'Status', r.status
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
        'ID', r.id,
        'Name', r.name,
        'Created Time', r.creation_timestamp,
        'Location', r.location
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
      s.name,
      s.title,
      jsonb_build_object(
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Size(GB)', s.disk_size_gb,
        'Status', s.status
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
      s.id::text as id,
      s.title,
      jsonb_build_object(
        'ID', s.id,
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Location', s.location,
        'IP Cidr Range', s.ip_cidr_range
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
        'ID', g.id,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Location', g.location
      ) as properties
    from
      gcp_compute_vpn_gateway g
    where
      g.id = any($1);
  EOQ

  param "compute_vpn_gateway_ids" {}
}
