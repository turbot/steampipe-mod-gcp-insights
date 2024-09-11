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
      join unnest($1::text[]) as u on t.id = (split_part(u, '/', 1)) and t.project = split_part(u, '/', 2)
    where
      k.self_link like '%' || t.kms_key_name || '%';
  EOQ

  param "bigquery_table_ids" {}
}

edge "bigquery_table_to_bigquery_dataset" {
  title = "belongs to"

  sql = <<-EOQ
    select
      t.id as from_id,
      d.id as to_id
    from
      gcp_bigquery_table t
      join unnest($1::text[]) as u on t.id = (split_part(u, '/', 1)) and t.project = split_part(u, '/', 2),
      gcp_bigquery_dataset d
    where
      t.dataset_id = d.dataset_id
      and t.project = d.project;
  EOQ

  param "bigquery_table_ids" {}
}