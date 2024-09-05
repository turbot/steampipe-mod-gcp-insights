node "composer_environment" {
  category = category.compute_backend_bucket

  sql = <<-EOQ
    select
      c.name as id,
      c.title,
      jsonb_build_object(
        'uuid', c.uuid,
        'Creat Time', c.create_time,
        'Update Time', c.update_time,
        'Location', c.location,
        'Project', project
      ) as properties
    from
      gcp_composer_environment c
    where
      c.name = any($1);
  EOQ

  param "composer_environment_names" {}
}