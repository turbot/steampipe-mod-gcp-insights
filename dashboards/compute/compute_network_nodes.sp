node "compute_subnetwork" {
  category = category.compute_subnetwork

  sql = <<-EOQ
    select
      s.id::text as id,
      s.title,
      jsonb_build_object(
        'ID', s.id,
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Location', s.location,
        'IP Cidr Range', s.ip_cidr_range
      ) as properties
    from
      gcp_compute_subnetwork s
    where
      s.id = any($1);
  EOQ

  param "compute_subnet_ids" {}
}



