
edge "kms_key_ring_to_kms_key" {
  title = "organizes"

  sql = <<-EOQ
    select
      concat(p.name, '_key_ring') as from_id,
      k.name as to_id
    from
      gcp_kms_key_ring p,
      gcp_kms_key k
    where
      p.name = any($1)
      and k.key_ring_name = p.name
  EOQ

  param "kms_key_ring_names" {}
}

edge "kms_key_to_kms_key_version" {
  title = "version"

  sql = <<-EOQ
    select
      $1 as from_id,
      v.name || '_' || v.crypto_key_version as to_id
    from
      gcp_kms_key_version v
    where
      v.name = any($1);
  EOQ

  param "kms_key_ring_names" {}
}

edge "bigquery_dataset_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      d.id as from_id,
      k.name as to_id
    from
      gcp_kms_key k,
      gcp_bigquery_dataset d
    where
      k.name = split_part(d.kms_key_name, 'cryptoKeys/', 2)
      and d.id = any($1);
  EOQ

  param "bigquery_dataset_ids" {}
}

edge "bigquery_table_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      t.id as from_id,
      k.name as to_id
    from
      gcp_kms_key k,
      gcp_bigquery_table t
    where
      k.name = split_part(t.kms_key_name, 'cryptoKeys/', 2)
      and t.id = $1;
  EOQ

  param "bigquery_table_ids" {}
}

edge "kms_key_from_sql_backup" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      b.id::text as from_id,
      k.name as to_id
    from
      gcp_kms_key k,
      gcp_sql_backup b
    where
      split_part(b.disk_encryption_configuration ->> 'kmsKeyName','cryptoKeys/',2) = $1;
  EOQ

  param "key_name" {}
}
