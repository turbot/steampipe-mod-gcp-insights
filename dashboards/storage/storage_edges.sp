edge "storage_bucket_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      b.id as from_id,
      k.self_link as to_id
    from
      gcp_storage_bucket b
      join unnest($1::text[]) as u on b.id = split_part(u, '/', 1) and b.project = split_part(u, '/', 2),
      gcp_kms_key k
    where
      b.default_kms_key_name is not null
      and k.self_link like '%' || b.default_kms_key_name;
  EOQ

  param "storage_bucket_ids" {}
}

edge "storage_bucket_to_logging_bucket" {
  title = "logs to"

  sql = <<-EOQ
    with storage_bucket as (
      select
        id,
        log_object_prefix,
        log_bucket
      from
        gcp_storage_bucket
        join unnest($1::text[]) as u on id = split_part(u, '/', 1) and project = split_part(u, '/', 2)
      where
        log_bucket is not null
    ), logging_bucket as (
      select
        name
      from
        gcp_logging_bucket
    )
    select
      b.id as from_id,
      l.name as to_id,
      jsonb_build_object(
        'Log Object Prefix', b.log_object_prefix
      ) as properties
    from
      storage_bucket b,
      logging_bucket l
    where
      b.log_bucket = l.name;
  EOQ

  param "storage_bucket_ids" {}
}