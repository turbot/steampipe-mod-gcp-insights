node "cloud_run_service" {
  category = category.cloud_run_service

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Create Time', create_time,
        'Ingress', ingress,
        'UID' , uid,
        'URI' , uri,
        'Project', project
      ) as properties
    from
      gcp_cloud_run_service
      join unnest($1::text[]) as u on self_link = u;
  EOQ

  param "cloud_run_service_self_links" {}
}