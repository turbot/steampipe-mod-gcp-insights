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