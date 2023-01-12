node "kubernetes_cluster" {
  category = category.kubernetes_cluster

  sql = <<-EOQ
    select
      id,
      title,
      jsonb_build_object(
        'ID', id,
        'Name', name,
        'Created Time', create_time,
        'Endpoint', endpoint,
        'Services IPv4 CIDR', services_ipv4_cidr,
        'Status', status,
        'Location', location,
        'Project', project
      ) as properties
    from
      gcp_kubernetes_cluster
    where
      id = any($1);
  EOQ

  param "kubernetes_cluster_ids" {}
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
        'Version', p.version,
        'Project', project
      ) as properties
    from
      gcp_kubernetes_node_pool p
    where
      p.name = any($1);
  EOQ

  param "kubernetes_node_pool_names" {}
}