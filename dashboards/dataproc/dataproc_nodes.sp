node "dataproc_metastore_service" {
  category = category.dataproc_metastore_service

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Name', name,
        'UID', uid,
        'Created Time', create_time,
        'State', state,
        'Location', location,
        'Project', project
      ) as properties
    from
      gcp_dataproc_metastore_service
      join unnest($1::text[]) as u on self_link = u and project = split_part(u, '/', 6);
  EOQ

  param "dataproc_metastore_service_self_links" {}
}