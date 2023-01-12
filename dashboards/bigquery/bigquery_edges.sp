edge "bigquery_dataset_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      d.id as from_id,
      k.self_link as to_id
    from
      gcp_kms_key k,
      gcp_bigquery_dataset d
    where
      k.self_link like '%' || d.kms_key_name || '%'
      and d.id = any($1);
  EOQ

  param "bigquery_dataset_ids" {}
}

edge "bigquery_table_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      t.id as from_id,
      k.self_link as to_id
    from
      gcp_kms_key k,
      gcp_bigquery_table t
    where
      k.self_link like '%' || t.kms_key_name || '%'
      and t.id = any($1);
  EOQ

  param "bigquery_table_ids" {}
}