edge "kms_key_ring_to_kms_key" {
  title = "organizes"

  sql = <<-EOQ
    select
      p.akas::text as from_id,
      k.self_link as to_id
    from
      gcp_kms_key_ring p,
      gcp_kms_key k
    where
      p.akas::text = any($1)
      and k.key_ring_name = p.name;
  EOQ

  param "kms_key_ring_names" {}
}

edge "kms_key_to_kms_key_version" {
  title = "version"

  sql = <<-EOQ
    select
      split_part(v.self_link, '/cryptoKeyVersions/', 1) as from_id,
      v.self_link as to_id
    from
      gcp_kms_key_version v,
      jsonb_array_elements_text($1) key
    where
      v.self_link like key || '%';
  EOQ

  param "kms_key_self_links" {}
}