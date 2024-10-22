node "logging_bucket" {
  category = category.logging_bucket

  sql = <<-EOQ
    select
      l.name as id,
      l.title,
      jsonb_build_object(
        'Name', l.name,
        'Created Time', l.create_time,
        'Description', l.description,
        'Lifecycle State', l.lifecycle_state,
        'Location', l.location,
        'Locked', l.locked,
        'Retention Days', l.retention_days,
        'Project', project
      ) as properties
    from
      gcp_logging_bucket l
    where
      l.name = any($1);
  EOQ

  param "logging_bucket_names" {}
}