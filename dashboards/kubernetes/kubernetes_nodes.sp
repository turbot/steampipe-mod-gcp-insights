node "kubernetes_cluster" {
  category = category.kubernetes_cluster

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Created Time', create_time,
        'Endpoint', endpoint,
        'Services IPv4 CIDR', services_ipv4_cidr,
        'Status', status
      ) as properties
    from
      gcp_kubernetes_cluster
    where
      name = any($1);
  EOQ

  param "kubernetes_cluster_names" {}
}

node "kubernetes_node_pool" {
  category = category.kubernetes_node_pool

  sql = <<-EOQ
    select
      p.name as id,
      p.title,
      jsonb_build_object(
        'Name', p.name,
        'Initial Node Count', p.initial_node_count,
        'Status', p.status,
        'Version', p.version
      ) as properties
    from
      gcp_kubernetes_node_pool p
    where
      p.name = any($1);
  EOQ

  param "kubernetes_node_pool_names" {}
}