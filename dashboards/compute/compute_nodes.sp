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

node "compute_disk_from_compute_snapshot" {
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
      and d.source_snapshot = s.self_link;
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

node "compute_disk_from_compute_image" {
  category = category.compute_snapshot

  sql = <<-EOQ
    select
      i.name as id,
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

node "compute_disk_to_compute_resource_policy" {
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
      gcp_compute_disk d,
      jsonb_array_elements_text(resource_policies) as rp,
      gcp_compute_resource_policy r
    where
      d.id = any($1)
      and rp = r.self_link
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

node "compute_instance_to_compute_firewall" {
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
      gcp_compute_instance i,
      gcp_compute_firewall f,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'network' = f.network
      and i.id = $1;
  EOQ

  param "id" {}
}

node "compute_instance_to_service_account" {
  category = category.service_account

  sql = <<-EOQ
    select
      s.name as id,
      s.title,
      jsonb_build_object(
        'ID', s.unique_id,
        'Enabled', not s.disabled,
        'Region', s.location,
        'OAuth 2.0 client ID', s.oauth2_client_id
      ) as properties
    from
      gcp_compute_instance i,
      gcp_service_account s,
      jsonb_array_elements(service_accounts) as sa
    where
      sa ->> 'email' = s.email
      and i.id = $1;
  EOQ

  param "id" {}
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

node "compute_instance_group_compute_network_to_compute_subnetwork" {
  category = category.compute_subnetwork

  sql = <<-EOQ
    select
      s.id::text as id,
      s.title,
      jsonb_build_object(
        'ID', s.id::text,
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Location', s.location,
        'IP Cidr Range', s.ip_cidr_range
      ) as properties
    from
      gcp_compute_instance_group g,
      gcp_compute_subnetwork s
    where
      g.subnetwork = s.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

node "compute_instance_group_to_compute_autoscaler" {
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
      gcp_compute_instance_group g,
      gcp_compute_autoscaler a
    where
      g.name = split_part(a.target, 'instanceGroupManagers/', 2)
      and g.id = $1;
  EOQ

  param "id" {}
}

node "compute_instance_group_to_compute_firewall" {
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
      gcp_compute_instance_group g,
      gcp_compute_firewall f
    where
      g.network = f.network
      and g.id = $1;
  EOQ

  param "id" {}
}

node "compute_instance_group_from_compute_backend_service" {
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
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b
    where
      b ->> 'group' = g.self_link
      and g.id = $1;
  EOQ

  param "id" {}
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
        'Status', s.status
      ) as properties
    from
      gcp_compute_snapshot s
    where
      s.id = any($1);
  EOQ

  param "snapshot_ids" {}
}