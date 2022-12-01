## Compute Disk

edge "compute_disk_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      disk_id as from_id,
      key_name as to_id
    from
      unnest($1::text[]) as disk_id,
      unnest($2::text[]) as key_name;
  EOQ

  param "compute_disk_ids" {}
  param "kms_key_names" {}
}

edge "compute_disk_to_compute_disk" {
  title = "cloned to"

  sql = <<-EOQ
    select
      disk_id as from_id,
      to_disk_ids as to_id
    from
      unnest($1::text[]) as disk_id,
      unnest($2::text[]) as to_disk_ids;
  EOQ

  param "compute_disk_ids" {}
  param "to_disk_ids" {}
}

edge "compute_disk_from_compute_disk" {
  title = "cloned to"

  sql = <<-EOQ
    select
      from_disk_ids as from_id,
      disk_id as to_id
    from
      unnest($1::text[]) as from_disk_ids,
      unnest($2::text[]) as disk_id;
  EOQ

  param "from_disk_ids" {}
  param "compute_disk_ids" {}
}

edge "compute_disk_to_compute_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      d.id::text as from_id,
      s.name as to_id
    from
      gcp_compute_disk d,
      gcp_compute_snapshot s
    where
      d.id = any($1)
      and d.self_link = s.source_disk;
  EOQ

  param "compute_disk_ids" {}
}

edge "compute_disk_from_compute_snapshot" {
  title = "created from"

  sql = <<-EOQ
    select
      s.name as from_id,
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

## Compute Instance

edge "compute_instance_to_compute_disk" {
  title = "mounts"

  sql = <<-EOQ
    select
      instance_id as from_id,
      disk_id as to_id
    from
      unnest($1::text[]) as instance_id,
      unnest($2::text[]) as disk_id;
  EOQ

  param "compute_instance_ids" {}
  param "compute_disk_ids" {}
}

edge "compute_instance_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      instance_id as from_id,
      subnet_id as to_id
    from
      unnest($1::text[]) as instance_id,
      unnest($2::text[]) as subnet_id;
  EOQ

  param "compute_instance_ids" {}
  param "compute_subnet_ids" {}
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
      and i.id = $1;
  EOQ

  param "id" {}
}

edge "compute_instance_to_service_account" {
  title = "service account"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      s.name as to_id
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

## Compute Instance Group

edge "compute_instance_group_to_compute_instance" {
  title = "manages"

  sql = <<-EOQ
    select
      instance_group_id as from_id,
      instance_id as to_id
    from
      unnest($1::text[]) as instance_group_id,
      unnest($2::text[]) as instance_id;
  EOQ

  param "compute_instance_group_ids" {}
  param "compute_instance_ids" {}
}

// edge "compute_instance_group_to_compute_network" {
//   title = "network"

//   sql = <<-EOQ
//     select
//       instance_group_id as from_id,
//       network_name as to_id
//     from
//       unnest($1::text[]) as instance_group_id,
//       unnest($2::text[]) as network_name;
//   EOQ

//   param "compute_instance_group_ids" {}
//   param "compute_network_names" {}
// }

edge "compute_instance_group_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      instance_group_id as from_id,
      subnet_id as to_id
    from
      unnest($1::text[]) as instance_group_id,
      unnest($2::text[]) as subnet_id;
  EOQ

  param "compute_instance_group_ids" {}
  param "compute_subnet_ids" {}
}

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
      and g.id = $1;
  EOQ

  param "id" {}
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
      and g.id = $1;
  EOQ

  param "id" {}
}

edge "compute_instance_group_from_compute_backend_service" {
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
      and g.id = $1;
  EOQ

  param "id" {}
}