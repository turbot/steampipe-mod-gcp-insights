node "storage_bucket" {
  category = category.storage_bucket

  sql = <<-EOQ
    select
      id,
      title,
      jsonb_build_object(
        'Name', name,
        'Created Time', time_created,
        'Storage Class', storage_class,
        'Project', project
      ) as properties
    from
      gcp_storage_bucket
      join unnest($1::text[]) as u on id = split_part(u, '/', 1) and project = split_part(u, '/', 2);
  EOQ

  param "storage_bucket_ids" {}
}