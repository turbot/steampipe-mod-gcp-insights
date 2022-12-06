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
      s.id::text,
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
      s.id::text as id,
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

node "compute_snapshot" {
  category = category.compute_snapshot

  sql = <<-EOQ
    select
      s.id:text,
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

  param "compute_snapshot_ids" {}
}
