## Compute Backend

edge "compute_backend_bucket_to_storage_bucket" {
  title = "bucket"

  sql = <<-EOQ
    select
      c.id::text as from_id,
      b.id as to_id
    from
      gcp_storage_bucket b,
      gcp_compute_backend_bucket c
    where
      b.id = any($1)
      and b.name = c.bucket_name;
  EOQ

  param "storage_bucket_ids" {}
}

edge "compute_backend_service_to_compute_instance_group" {
  title = "instance group"

  sql = <<-EOQ
    select
      bs.id::text as from_id,
      g.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b
    where
      b ->> 'group' = g.self_link
      and bs.id = any($1);
  EOQ

  param "compute_backend_service_ids" {}
}

## Compute Disk

edge "compute_disk_from_compute_disk" {
  title = "cloned to"

  sql = <<-EOQ
    select
      cd.id::text as from_id,
      d.id::text as to_id
    from
      gcp_compute_disk d,
      gcp_compute_disk cd
    where
      d.id = any($1)
      and d.source_disk_id = cd.id::text;
  EOQ

  param "compute_disk_ids" {}
}

edge "compute_disk_from_compute_image" {
  title = "created from"

  sql = <<-EOQ
    select
      i.name as from_id,
      d.id::text as to_id
    from
      gcp_compute_disk d,
      gcp_compute_image i
    where
      d.id = any($1)
      and d.source_image = i.self_link;
  EOQ

  param "compute_disk_ids" {}
}

edge "compute_disk_from_compute_snapshot" {
  title = "created from"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      d.id::text as to_id
    from
      gcp_compute_disk d,
      gcp_compute_snapshot s
    where
      d.id = any($1)
      and d.source_snapshot = s.self_link;
  EOQ

  param "compute_disk_ids" {}
}

edge "compute_disk_to_compute_disk" {
  title = "cloned to"

  sql = <<-EOQ
    select
      d.id::text as from_id,
      cd.id::text as to_id
    from
      gcp_compute_disk d,
      gcp_compute_disk cd
    where
      d.id = any($1)
      and d.id::text = cd.source_disk_id;
  EOQ

  param "compute_disk_ids" {}
}

edge "compute_disk_to_compute_image" {
  title = "image"

  sql = <<-EOQ
    select
      d.id::text as from_id,
      i.id::text as to_id
    from
      gcp_compute_disk d,
      gcp_compute_image i
    where
      d.id = any($1)
      and d.self_link = i.source_disk;
  EOQ

  param "compute_disk_ids" {}
}

edge "compute_disk_to_compute_resource_policy" {
  title = "resource policy"

  sql = <<-EOQ
    select
      d.id::text as from_id,
      r.id as to_id
    from
      gcp_compute_disk d,
      jsonb_array_elements_text(resource_policies) as rp,
      gcp_compute_resource_policy r
    where
      d.id = any($1)
      and rp = r.self_link;
  EOQ

  param "compute_disk_ids" {}
}

edge "compute_disk_to_compute_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      d.id::text as from_id,
      s.id::text as to_id
    from
      gcp_compute_disk d,
      gcp_compute_snapshot s
    where
      d.id = any($1)
      and d.self_link = s.source_disk;
  EOQ

  param "compute_disk_ids" {}
}

edge "compute_disk_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      d.id::text as from_id,
      k.name as to_id
    from
      gcp_compute_disk d,
      gcp_kms_key k
    where
      d.id = any($1)
      and d.disk_encryption_key is not null
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/', 8) = k.name;
  EOQ

  param "compute_disk_ids" {}
}

## Compute Instance

edge "compute_instance_to_compute_disk" {
  title = "mounts"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      d.id::text as to_id
    from
      gcp_compute_instance i,
      gcp_compute_disk d,
      jsonb_array_elements(disks) as disk
    where
      i.id = any($1)
      and d.self_link = (disk ->> 'source');
  EOQ

  param "compute_instance_ids" {}
}

edge "compute_instance_to_compute_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      f.id::text as to_id
    from
      gcp_compute_instance i,
      gcp_compute_firewall f,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'network' = f.network
      and i.id = any($1);
  EOQ

  param "compute_instance_ids" {}
}

edge "compute_instance_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      s.id::text as to_id
    from
      gcp_compute_instance i,
      gcp_compute_subnetwork s,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'subnetwork' = s.self_link
      and i.id = any($1);
  EOQ

  param "compute_instance_ids" {}
}

edge "compute_instance_to_service_account" {
  title = "service account"

  sql = <<-EOQ
    select
      i.id as from_id,
      s.name as to_id
    from
      gcp_compute_instance i,
      gcp_service_account s,
      jsonb_array_elements(service_accounts) as sa
    where
      sa ->> 'email' = s.email
      and i.id = any($1);
  EOQ

  param "compute_instance_ids" {}
}

## Compute Image

edge "compute_image_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.id as from_id,
      k.name as to_id
    from
      gcp_compute_image as i,
      gcp_kms_key as k
    where
      split_part(i.image_encryption_key->>'kmsKeyName', '/', -3) = k.name
      and i.id = any($1);
  EOQ

  param "compute_image_ids" {}
}

## Compute Instance Group

edge "compute_instance_group_to_compute_autoscaler" {
  title = "autoscaler"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      a.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_autoscaler a
    where
      g.name = split_part(a.target, 'instanceGroupManagers/', 2)
      and g.id = any($1);
  EOQ

  param "compute_instance_group_ids" {}
}

edge "compute_instance_group_to_compute_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      f.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_firewall f
    where
      g.network = f.network
      and g.id = any($1);
  EOQ

  param "compute_instance_group_ids" {}
}

edge "compute_instance_group_to_compute_instance" {
  title = "manages"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      i.id::text as to_id
    from
      gcp_compute_instance as i,
      gcp_compute_instance_group as g,
      jsonb_array_elements(instances) as ins
    where
      g.id = any($1)
      and (ins ->> 'instance') = i.self_link;
  EOQ

  param "compute_instance_group_ids" {}
}

edge "compute_instance_group_to_compute_network" {
  title = "network"

  sql = <<-EOQ
    select
      case when g.subnetwork = '' then (g.id::text) else (s.id::text) end as from_id,
      n.id::text as to_id
    from
      gcp_compute_instance_group g
        left join gcp_compute_subnetwork s 
        on g.subnetwork = s.self_link,
      gcp_compute_network n
    where
      g.network = n.self_link
      and g.id = any($1);
  EOQ

  param "compute_instance_group_ids" {}
}

edge "compute_instance_group_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      s.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_network n,
      gcp_compute_subnetwork s
    where
      g.network = n.self_link
      and g.subnetwork = s.self_link
      and g.id = any($1);
  EOQ

  param "compute_instance_group_ids" {}
}

## Compute Snapshot

edge "compute_snapshot_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      v.name || '_' || v.crypto_key_version as to_id
    from
      gcp_compute_snapshot s,
      gcp_kms_key_version v
    where
      v.crypto_key_version::text = split_part(s.kms_key_name, 'cryptoKeyVersions/', 2)
      and split_part(s.kms_key_name, '/', 8) = v.name
      and s.id = any($1);
  EOQ

  param "compute_snapshot_ids" {}
}















