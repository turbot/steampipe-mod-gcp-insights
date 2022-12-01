## Kubernetes Cluster

edge "kubernetes_cluster_to_compute_instance_group" {
  title = "instance group"

  sql = <<-EOQ
    select
      cluster_name as from_id,
      instance_group_id as to_id
    from
      unnest($1::text[]) as cluster_name,
      unnest($2::text[]) as instance_group_id;
  EOQ

  param "kubernetes_cluster_names" {}
  param "compute_instance_group_ids" {}
}

edge "kubernetes_cluster_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      c.name as from_id,
      k.name as to_id,
      jsonb_build_object(
        'Database Encryption State', c.database_encryption_state
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_kms_key k
    where
      c.name = any($1)
      and c.database_encryption_key_name is not null
      and split_part(c.database_encryption_key_name, 'cryptoKeys/', 2) = k.name;
  EOQ

  param "kubernetes_cluster_names" {}
}

edge "kubernetes_cluster_to_pubsub_topic" {
  title = "notifies"

  sql = <<-EOQ
    select
      c.name as from_id,
      t.name as to_id,
      jsonb_build_object(
        'Notifications Enabled', (c.notification_config -> 'pubsub' ->> 'enabled')
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_pubsub_topic t
    where
      c.name = any($1)
      and c.notification_config is not null
      and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%';
  EOQ

  param "kubernetes_cluster_names" {}
}

edge "kubernetes_cluster_to_kubernetes_node_pool" {
  title = "node pool"

  sql = <<-EOQ
    select
      cluster_name as from_id,
      pool_name as to_id
    from
      unnest($1::text[]) as cluster_name,
      unnest($2::text[]) as pool_name;
  EOQ

  param "kubernetes_cluster_names" {}
  param "kubernetes_node_pool_names" {}
}

edge "kubernetes_cluster_to_bigquery_dataset" {
  title = "usage metering"

  sql = <<-EOQ
    select
      cluster_name as from_id,
      dataset_id as to_id
    from
      unnest($1::text[]) as cluster_name,
      unnest($2::text[]) as dataset_id;
  EOQ

  param "kubernetes_cluster_names" {}
  param "bigquery_dataset_ids" {}
}

edge "kubernetes_cluster_to_compute_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      cluster_name as from_id,
      firewall_id as to_id
    from
      unnest($1::text[]) as cluster_name,
      unnest($2::text[]) as firewall_id;
  EOQ

  param "kubernetes_cluster_names" {}
  param "compute_firewall_ids" {}
}

edge "kubernetes_cluster_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      cluster_name as from_id,
      subnet_id as to_id
    from
      unnest($1::text[]) as cluster_name,
      unnest($2::text[]) as subnet_id;
  EOQ

  param "kubernetes_cluster_names" {}
  param "compute_subnet_ids" {}
}

## Kubernetes Node Pool

edge "kubernetes_node_pool_to_compute_instance_group" {
  title = "instance group"

  sql = <<-EOQ
    select
      pool_name as from_id,
      group_id as to_id
    from
      unnest($1::text[]) as pool_name,
      unnest($2::text[]) as group_id
  EOQ

  param "kubernetes_node_pool_names" {}
  param "compute_instance_group_ids" {}
}