node "bigquery_dataset" {
  category = category.bigquery_dataset

  sql = <<-EOQ
    select
      d.id,
      d.title,
      jsonb_build_object(
        'ID', d.id,
        'Created Time', d.creation_time,
        'Table Expiration(ms)', d.default_table_expiration_ms,
        'KMS Key', d.kms_key_name,
        'Location', d.location,
        'Project', project
      ) as properties
    from
      gcp_bigquery_dataset d
    where
      d.dataset_id = any($1);
  EOQ

  param "bigquery_dataset_ids" {}
}

node "bigquery_table" {
  category = category.bigquery_table

  sql = <<-EOQ
    select
      t.id,
      t.title,
      jsonb_build_object(
        'ID', t.id,
        'Created Time', t.creation_time,
        'Dataset Id', t.dataset_id,
        'Expiration Time', t.expiration_time,
        'KMS Key', t.kms_key_name,
        'Location', t.location,
        'Project', project
      ) as properties
    from
      gcp_bigquery_table t
    where
      t.id = any($1);
  EOQ

  param "bigquery_table_ids" {}
}