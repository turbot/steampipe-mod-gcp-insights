edge "pubsub_topic_to_iam_role" {
  title = "assumes"

  sql = <<-EOQ
    select
      t.name as from_id,
      i.role_id as to_id
    from
      gcp_iam_role i,
      gcp_pubsub_topic t,
      jsonb_array_elements(t.iam_policy->'bindings') as roles,
      jsonb_array_elements_text($1) as full_name
    where
      roles ->> 'role' = i.name
      and self_link like '%' || full_name;
  EOQ

  param "pubsub_topic_names" {}
}

edge "pubsub_topic_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      p.name as from_id,
      concat(k.name, '_key') as to_id
    from
      gcp_pubsub_topic p,
      gcp_kms_key k,
      jsonb_array_elements_text($1) as full_name
    where
      k.name = split_part(p.kms_key_name, 'cryptoKeys/', 2)
      and p.self_link like '%' || full_name;
  EOQ

  param "pubsub_topic_names" {}
}

edge "pubsub_topic_to_pubsub_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      s.name as from_id,
      s.topic_name as to_id
    from
      gcp_pubsub_snapshot s
    where
      s.topic = any($1);
  EOQ

  param "pubsub_topic_names" {}
}

edge "pubsub_topic_to_pubsub_subscription" {
  title = "subscribed to"

  sql = <<-EOQ
    select
      s.topic_name as from_id,
      s.name || 'subscription' as to_id
    from
      gcp_pubsub_subscription s
    where
      s.topic = any($1);
  EOQ

  param "pubsub_topic_names" {}
}