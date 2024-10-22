node "cloudfunctions_function" {
  category = category.cloudfunctions_function

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Status', status,
        'Runtime', runtime,
        'Update Time', update_time,
        'Timeout', timeout,
        'Build Environment ID', build_id,
        'Region', location,
        'Project', project
      ) as properties
    from
      gcp_cloudfunctions_function
    where
      name = any($1);
  EOQ

  param "cloudfunctions_function_ids" {}
}