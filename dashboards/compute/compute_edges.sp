## Compute Backend

edge "compute_backend_bucket_to_storage_bucket" {
  title = "bucket"

  sql = <<-EOQ
    select
      c.id::text as from_id,
      b.id::text as to_id
    from
      gcp_storage_bucket b,
      gcp_compute_backend_bucket c
    where
      c.id = any($1)
      and b.name = c.bucket_name;
  EOQ

  param "compute_backend_bucket_ids" {}
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

edge "compute_disk_to_kms_key_version" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      d.id::text as from_id,
      k.name || '_' || k.crypto_key_version as to_id
    from
      gcp_compute_disk d,
      gcp_kms_key_version k
    where
      d.disk_encryption_key is not null
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', 'cryptoKeyVersions/', 2) = k.crypto_key_version::text
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/', 8) = k.name
      and d.id = any($1);
  EOQ

  param "compute_disk_ids" {}
}

## Compute Image

edge "compute_image_to_compute_disk" {
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

  param "compute_image_ids" {}
}

edge "compute_image_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      k.name as to_id
    from
      gcp_compute_image as i,
      gcp_kms_key as k
    where
      split_part(i.image_encryption_key->>'kmsKeyName', '/', 8) = k.name
      and i.id = any($1);
  EOQ

  param "compute_image_ids" {}
}

edge "compute_image_to_kms_key_version" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      k.name || '_' || k.crypto_key_version as to_id
    from
      gcp_compute_image as i,
      gcp_kms_key_version as k
    where
      split_part(i.image_encryption_key->>'kmsKeyName', '/', 8) = k.name
      and split_part(i.image_encryption_key ->> 'kmsKeyName', 'cryptoKeyVersions/', 2) = k.crypto_key_version::text
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

edge "compute_instance_to_iam_service_account" {
  title = "iam service account"

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
      and i.id = any($1);
  EOQ

  param "compute_instance_ids" {}
}

## Compute Network

edge "compute_network_to_compute_backend_service" {
  title = "backend service"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      bs.id::text as to_id
    from
      gcp_compute_backend_service bs,
      gcp_compute_network n
    where
      bs.network = n.self_link
      and n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

edge "compute_network_to_compute_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      f.id::text as to_id
    from
      gcp_compute_firewall f,
      gcp_compute_network n
    where
      f.network = n.self_link
      and n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

edge "compute_network_to_compute_forwarding_rule" {
  title = "forwarding rule"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      fr.id::text as to_id
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_network n
    where
      split_part(fr.network, 'networks/', 2) = n.name
      and fr.project = n.project
      and n.id = any($1)

    union

    select
      n.id::text as from_id,
      fr.id::text as to_id
    from
      gcp_compute_global_forwarding_rule fr,
      gcp_compute_network n
    where
      split_part(fr.network, 'networks/', 2) = n.name
      and fr.project = n.project
      and n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

edge "compute_network_to_compute_instance" {
  title = "compute instance"

  sql = <<-EOQ
    select
      i.id::text as to_id,
      n.id::text as from_id
    from
      gcp_compute_instance i,
      gcp_compute_network n,
      jsonb_array_elements(network_interfaces) as ni
    where
      n.self_link = ni ->> 'network'
      and n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

edge "compute_network_to_compute_router" {
  title = "router"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      r.id::text as to_id
    from
      gcp_compute_router r,
      gcp_compute_network n
    where
      r.network = n.self_link
      and n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

edge "compute_network_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      s.id::text as to_id
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

edge "compute_network_to_dns_policy" {
  title = "dns policy"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      p.id::text as to_id
    from
      gcp_dns_policy p,
      jsonb_array_elements(p.networks) pn,
      gcp_compute_network n
    where
      pn ->> 'networkUrl' = n.self_link
      and n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

edge "compute_network_to_kubernetes_cluster" {
  title = "kubernetes cluster"

  sql = <<-EOQ
    select
      c.name as to_id,
      n.id::text as from_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n
    where
      n.id = any($1)
      and n.id = c.network
  EOQ

  param "compute_network_ids" {}
}

edge "compute_network_to_sql_database_instance" {
  title = "database instance"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      i.name as to_id
    from
      gcp_sql_database_instance i,
      gcp_compute_network n
    where
      n.self_link like '%' || (i.ip_configuration ->> 'privateNetwork') || '%'
      and n.id = any($1);
  EOQ

  param "compute_network_ids" {}
}

## Compute Snapshot

edge "compute_snapshot_to_compute_disk" {
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

  param "compute_snapshot_names" {}
}

edge "compute_snapshot_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.name as from_id,
      k.name as to_id
    from
      gcp_compute_snapshot s,
      gcp_kms_key k
    where
      split_part(s.kms_key_name, '/', 8) = k.name
      and s.name = any($1);
  EOQ

  param "compute_snapshot_names" {}
}

edge "compute_snapshot_to_kms_key_version" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.name as from_id,
      v.name || '_' || v.crypto_key_version as to_id
    from
      gcp_compute_snapshot s,
      gcp_kms_key_version v
    where
      v.crypto_key_version::text = split_part(s.kms_key_name, 'cryptoKeyVersions/', 2)
      and split_part(s.kms_key_name, '/', 8) = v.name
      and s.name = any($1);
  EOQ

  param "compute_snapshot_names" {}
}

## Compute Subnetwork

edge "compute_subnetwork_to_compute_address" {
  title = "compute address"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      a.id::text as to_id
    from
      gcp_compute_address a,
      gcp_compute_subnetwork s
    where
      s.id = any($1)
      and s.self_link = a.subnetwork

    union

    select
      s.id::text as from_id,
      a.id::text as to_id
    from
      gcp_compute_global_address a,
      gcp_compute_subnetwork s
    where
      s.id = any($1)
      and s.self_link = a.subnetwork;
  EOQ

  param "compute_subnetwork_ids" {}
}

edge "compute_subnetwork_to_compute_forwarding_rule" {
  title = "forwarding rule"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      r.id::text as to_id
    from
      gcp_compute_forwarding_rule r,
      gcp_compute_subnetwork s
    where
      s.id = any($1)
      and split_part(r.subnetwork, 'subnetworks/', 2) = s.name

    union

    select
      s.id::text as from_id,
      r.id::text as to_id
    from
      gcp_compute_global_forwarding_rule r,
      gcp_compute_subnetwork s
    where
      s.id = any($1)
      and split_part(r.subnetwork, 'subnetworks/', 2) = s.name;
  EOQ

  param "compute_subnetwork_ids" {}
}

edge "compute_subnetwork_to_compute_instance_group" {
  title = "compute instance group"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      g.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_subnetwork s
    where
      g.subnetwork = s.self_link
      and s.id = any($1);
  EOQ

  param "compute_subnetwork_ids" {}
}

edge "compute_subnetwork_to_compute_instance" {
  title = "compute instance"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      i.id::text as to_id
    from
      gcp_compute_instance i,
      gcp_compute_subnetwork s,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'subnetwork' = s.self_link
      and s.id = any($1);
  EOQ

  param "compute_subnetwork_ids" {}
}

edge "compute_subnetwork_to_compute_instance_template" {
  title = "compute instance template"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      t.id::text as to_id
    from
      gcp_compute_instance_template t,
      jsonb_array_elements(instance_network_interfaces) ni,
      gcp_compute_subnetwork s
    where
      ni ->> 'subnetwork' = s.self_link
      and s.id = any($1);
  EOQ

  param "compute_subnetwork_ids" {}
}

edge "compute_subnetwork_to_compute_network" {
  title = "network"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      n.id::text as to_id
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and s.id = any($1);
  EOQ

  param "compute_subnetwork_ids" {}
}

edge "compute_subnetwork_to_kubernetes_cluster" {
  title = "kubernetes cluster"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      c.name as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_subnetwork s
    where
      s.id = any($1)
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ

  param "compute_subnetwork_ids" {}
}

## Compute VPN Gateway

edge "compute_vpn_gateway_to_compute_network" {
  title = "network"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      n.id::text as to_id
    from
      gcp_compute_ha_vpn_gateway g,
      gcp_compute_network n
    where
      g.network = n.self_link
      and g.id = any($1);
  EOQ

  param "compute_vpn_gateway_ids" {}
}
