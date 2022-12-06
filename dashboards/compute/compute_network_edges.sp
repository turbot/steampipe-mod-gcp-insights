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
      and n.name = any($1);
  EOQ

  param "compute_network_names" {}
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

edge "compute_subnetwork_to_compute_network" {
  title = "network"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      n.name as to_id
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and s.id = any($1);
  EOQ

  param "compute_subnet_ids" {}
}