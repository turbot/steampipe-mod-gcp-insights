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
      join unnest($1::text[]) as u on id = (split_part(u, '/', 1)) and project = split_part(u, '/', 2);
  EOQ

  param "bigquery_table_ids" {}
}

node "kms_key" {
  category = category.kms_key

  sql = <<-EOQ
    select
      k.self_link,
      k.name,
      jsonb_build_object(
        'Self Link', k.self_link,
        'Name', k.name,
        'Create Time', k.create_time,
        'Purpose', k.purpose,
        'Project', project
      ) as properties
    from
      gcp_kms_key k
    where
      k.self_link = any($1);
  EOQ

  param "kms_key_names" {}
}