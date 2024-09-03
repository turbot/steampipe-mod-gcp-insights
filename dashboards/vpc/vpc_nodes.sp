node "vpc_access_connector" {
  category = category.vpc_access_connector

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Machine Type', machine_type,
        'IP CIDR Range', ip_cidr_range,
        'State', state,
        'Min Throughput', min_throughput,
        'Project', project,
        'Location', location
      ) as properties
    from
      gcp_vpc_access_connector
      join unnest($1::text[]) as u on self_link = u;
  EOQ

  param "vpc_access_connector_self_links" {}
}
