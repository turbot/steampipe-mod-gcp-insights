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
      instance_id as from_id,
      firewall_id as to_id
    from
      unnest($1::text[]) as instance_id,
      unnest($2::text[]) as firewall_id;
  EOQ

  param "compute_instance_ids" {}
  param "compute_firewall_ids" {}
}

edge "compute_instance_to_service_account" {
  title = "service account"

  sql = <<-EOQ
    select
      instance_id as from_id,
      account_name as to_id
    from
      unnest($1::text[]) as instance_id,
      unnest($2::text[]) as account_name;
  EOQ

  param "compute_instance_ids" {}
  param "iam_service_account_names" {}
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
      instance_group_id as from_id,
      autoscaler_id as to_id
    from
      unnest($1::text[]) as instance_group_id,
      unnest($2::text[]) as autoscaler_id;
  EOQ

  param "compute_instance_group_ids" {}
  param "compute_autoscaler_ids" {}
}

edge "compute_instance_group_to_compute_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      instance_group_id as from_id,
      firewall_id as to_id
    from
      unnest($1::text[]) as instance_group_id,
      unnest($2::text[]) as firewall_id;
  EOQ

  param "compute_instance_group_ids" {}
  param "compute_firewall_ids" {}
}

edge "compute_backend_service_to_compute_instance_group" {
  title = "instance group"

  sql = <<-EOQ
    select
      service_id as from_id,
      instance_group_id as to_id
    from
      unnest($1::text[]) as instance_group_id,
      unnest($2::text[]) as service_id;
  EOQ

  param "compute_instance_group_ids" {}
  param "compute_backend_service_ids" {}
}

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