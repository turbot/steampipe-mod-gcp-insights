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
      v.key_name as from_id,
      v.key_name || '_' || v.crypto_key_version as to_id
    from
      gcp_kms_key_version v
    where
      v.key_name = any($1);
  EOQ

  param "kms_key_names" {}
}