## Kubernetes Cluster

edge "kubernetes_cluster_to_bigquery_dataset" {
  title = "usage metering"

  sql = <<-EOQ
    select
      c.id::text as from_id,
      d.id as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_bigquery_dataset d
    where
      c.id = any($1)
      and c.resource_usage_export_config -> 'bigqueryDestination' ->> 'datasetId' = d.dataset_id;
  EOQ

  param "kubernetes_cluster_ids" {}
}

edge "kubernetes_cluster_to_compute_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      c.id::text as from_id,
      f.id::text as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n,
      gcp_compute_firewall f
    where
      c.network = n.name
      and n.self_link = f.network
      and c.id = any($1);
  EOQ

  param "kubernetes_cluster_ids" {}
}

edge "kubernetes_cluster_to_compute_instance_group" {
  title = "instance group"

  sql = <<-EOQ
    select
      c.id::text as from_id,
      g.id::text as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_instance_group g,
      jsonb_array_elements_text(instance_group_urls) ig
    where
      split_part(ig, 'instanceGroupManagers/', 2) = g.name
      and c.id = any($1);
  EOQ

  param "kubernetes_cluster_ids" {}
}

edge "kubernetes_cluster_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      coalesce(f.id::text, c.id::text) as from_id,
      s.id::text as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n,
      gcp_compute_firewall f,
      gcp_compute_subnetwork s
    where
      c.id = any($1)
      and c.network = n.name
      and c.project = n.project
      and n.self_link = f.network
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ

  param "kubernetes_cluster_ids" {}
}

edge "kubernetes_cluster_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      c.id::text as from_id,
      k.self_link as to_id,
      jsonb_build_object(
        'Database Encryption State', c.database_encryption_state
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_kms_key k
    where
      c.id = any($1)
      and c.database_encryption_key_name is not null
      and k.self_link like '%' || c.database_encryption_key_name
  EOQ

  param "kubernetes_cluster_ids" {}
}

edge "kubernetes_cluster_to_kubernetes_node_pool" {
  title = "node pool"

  sql = <<-EOQ
    select
      c.id as from_id,
      p.name as to_id
    from
      gcp_kubernetes_node_pool p,
      gcp_kubernetes_cluster c
    where
      p.cluster_name = c.name
      and p.project = c.project
      and c.id = any($1);
  EOQ

  param "kubernetes_cluster_ids" {}
}

edge "kubernetes_cluster_to_pubsub_topic" {
  title = "notifies"

  sql = <<-EOQ
    select
      c.id::text as from_id,
      t.name as to_id,
      jsonb_build_object(
        'Notifications Enabled', (c.notification_config -> 'pubsub' ->> 'enabled')
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_pubsub_topic t
    where
      c.notification_config is not null
      and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%'
      and c.id = any($1);
  EOQ

  param "kubernetes_cluster_ids" {}
}

## Kubernetes Node Pool

edge "kubernetes_node_pool_to_compute_instance_group" {
  title = "instance group"

  sql = <<-EOQ
    select
      p.name as from_id,
      g.id::text as to_id
    from
      gcp_kubernetes_node_pool p,
      gcp_compute_instance_group g,
      jsonb_array_elements_text(instance_group_urls) ig
    where
      p.name = any($1)
      and split_part(ig, 'instanceGroupManagers/', 2) = g.name;
  EOQ

  param "kubernetes_node_pool_names" {}
}
