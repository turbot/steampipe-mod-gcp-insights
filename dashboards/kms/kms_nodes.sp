node "kms_key" {
  category = category.kms_key

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Created Time', create_time,
        'Location', location
      ) as properties
    from
      gcp_kms_key
    where
      name = any($1);
  EOQ

  param "kms_key_names" {}
}

node "kms_key_ring" {
  category = category.kms_key_ring

  sql = <<-EOQ
    select
      concat(p.name, '_key_ring') as id,
      p.title,
      jsonb_build_object(
        'Name', p.name,
        'Location', p.location,
        'Project', p.project,
        'Create Time', p.create_time
      ) as properties
    from
      gcp_kms_key_ring p
    where
      p.name = any($1);
  EOQ

  param "kms_key_ring_names" {}
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
        'Location', t.location
      ) as properties
    from
      gcp_bigquery_table t
    where
      t.id = any($1);
  EOQ

  param "bigquery_table_ids" {}
}

node "kms_key_version" {
  category = category.kms_key_version

  sql = <<-EOQ
    select
      v.name || '_' || v.crypto_key_version as id,
      v.title,
      jsonb_build_object(
        'Created Time', v.create_time,
        'Destroy Time', v.destroy_time,
        'Algorithm', v.algorithm,
        'Crypto Key Version', v.crypto_key_version,
        'Protection Level', v.protection_level,
        'State', v.state,
        'Location', v.location
      ) as properties
    from
      gcp_kms_key_version v
    where
      v.name = any($1);
  EOQ

  param "kms_key_ring_names" {}
}

node "kms_key_from_sql_backup" {
  category = category.sql_backup

  sql = <<-EOQ
    select
      b.id::text,
      b.title,
      jsonb_build_object(
        'ID', b.id,
        'Created Time', b.end_time,
        'Instance Name', b.instance_name,
        'Type', b.type,
        'Status', b.status,
        'Location', b.location
      ) as properties
    from
      gcp_kms_key k,
      gcp_sql_backup b
    where
      split_part(b.disk_encryption_configuration ->> 'kmsKeyName','cryptoKeys/',2) = $1;
  EOQ

  param "key_name" {}
}