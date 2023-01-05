edge "pubsub_topic_to_iam_role" {
  title = "assumes"

  sql = <<-EOQ
    select
      t.self_link as from_id,
      i.name as to_id
    from
      gcp_iam_role i,
      gcp_pubsub_topic t,
      jsonb_array_elements(t.iam_policy->'bindings') as roles
    where
      roles ->> 'role' = i.name
      and t.self_link = any($1);
  EOQ

  param "pubsub_topic_self_links" {}
}

edge "pubsub_topic_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      p.self_link as from_id,
      concat(k.name, '_key') as to_id
    from
      gcp_pubsub_topic p,
      gcp_kms_key k
    where
      k.name = split_part(p.kms_key_name, 'cryptoKeys/', 2)
      and p.self_link = any($1);
  EOQ

  param "pubsub_topic_self_links" {}
}

edge "pubsub_topic_to_pubsub_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      s.self_link as from_id,
      t.self_link as to_id
    from
      gcp_pubsub_snapshot s,
      gcp_pubsub_topic t
    where
      s.topic_name = t.name
      and t.self_link = any($1);
  EOQ

  param "pubsub_topic_self_links" {}
}

edge "pubsub_topic_to_pubsub_subscription" {
  title = "subscribed to"

  sql = <<-EOQ
    select
      t.self_link as from_id,
      s.self_link as to_id
    from
      gcp_pubsub_subscription s,
      gcp_pubsub_topic t
    where
      s.topic_name = t.name
      and t.self_link = any($1);
  EOQ

  param "pubsub_topic_self_links" {}
}