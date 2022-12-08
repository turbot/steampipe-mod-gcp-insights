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