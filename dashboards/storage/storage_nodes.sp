node "storage_bucket" {
  category = category.storage_bucket

  sql = <<-EOQ
    select
      id,
      title,
      jsonb_build_object(
        'Name', name,
        'Created Time', time_created,
        'Storage Class', storage_class
      ) as properties
    from
      gcp_storage_bucket
    where
      id = any($1);
  EOQ

  param "storage_bucket_ids" {}
}

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
        'Retention Days', l.retention_days
      ) as properties
    from
      gcp_logging_bucket l
    where
      l.name = any($1);
  EOQ

  param "logging_bucket_names" {}
}

node "compute_backend_bucket" {
  category = category.compute_backend_bucket

  sql = <<-EOQ
    select
      c.id::text as id,
      c.title,
      jsonb_build_object(
        'Name', c.name,
        'Created Time', c.creation_timestamp,
        'Description', c.description,
        'Location', c.location
      ) as properties
    from
      gcp_compute_backend_bucket c
    where
      c.id = any($1);
  EOQ

  param "compute_backend_bucket_ids" {}
}