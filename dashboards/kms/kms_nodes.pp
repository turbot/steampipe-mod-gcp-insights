node "kms_key" {
  category = category.kms_key

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Created Time', create_time,
        'Location', location,
        'Project', project,
        'Self Link', self_link
      ) as properties
    from
      gcp_kms_key
    where
      self_link = any($1);
  EOQ

  param "kms_key_self_links" {}
}

node "kms_key_ring" {
  category = category.kms_key_ring

  sql = <<-EOQ
    select
      akas::text as id,
      p.title,
      jsonb_build_object(
        'Name', p.name,
        'Location', p.location,
        'Project', p.project,
        'Create Time', p.create_time,
        'Project', project
      ) as properties
    from
      gcp_kms_key_ring p
    where
      p.akas::text = any($1);
  EOQ

  param "kms_key_ring_names" {}
}

node "kms_key_version" {
  category = category.kms_key_version

  sql = <<-EOQ
    select
      v.self_link as id,
      v.title,
      jsonb_build_object(
        'Key Name', v.key_name,
        'Created Time', v.create_time,
        'Destroy Time', v.destroy_time,
        'Algorithm', v.algorithm,
        'Crypto Key Version', v.crypto_key_version,
        'Protection Level', v.protection_level,
        'State', v.state,
        'Location', v.location,
        'Project', project
      ) as properties
    from
      gcp_kms_key_version v,
      jsonb_array_elements_text($1) as key
    where
      v.self_link like key || '%';
  EOQ

  param "kms_key_self_links" {}
}
