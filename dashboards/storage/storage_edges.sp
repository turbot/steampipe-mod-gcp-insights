edge "storage_bucket_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      b.id as from_id,
      k.name as to_id
    from
      gcp_storage_bucket b,
      gcp_kms_key k
    where
      b.id = any($1)
      and b.default_kms_key_name is not null
      and split_part(b.default_kms_key_name, 'cryptoKeys/', 2) = k.name;
  EOQ

  param "storage_bucket_ids" {}
}

edge "storage_bucket_to_logging_bucket" {
  title = "logs to"

  sql = <<-EOQ
    select
      b.id as from_id,
      l.name as to_id,
      jsonb_build_object(
        'Log Object Prefix', b.log_object_prefix
      ) as properties
    from
      gcp_storage_bucket b,
      gcp_logging_bucket l
    where
      b.id = any($1)
      and b.log_bucket is not null
      and b.log_bucket = l.name;
  EOQ

  param "storage_bucket_ids" {}
}