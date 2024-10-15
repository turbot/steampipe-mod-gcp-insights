edge "pubsub_topic_to_iam_role" {
  title = "assumes"

  sql = <<-EOQ
    select
      t.self_link as from_id,
      i.name as to_id
    from
      gcp_iam_role i,
      gcp_pubsub_topic t
      join unnest($1::text[]) as a on t.self_link = a and t.project = split_part(a, '/', 6),
      jsonb_array_elements(t.iam_policy->'bindings') as roles
    where
      roles ->> 'role' = i.name;
  EOQ

  param "pubsub_topic_self_links" {}
}

edge "pubsub_topic_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      p.self_link as from_id,
      k.self_link as to_id
    from
      gcp_pubsub_topic p
      join unnest($1::text[]) as a on p.self_link = a and p.project = split_part(a, '/', 6),
      gcp_kms_key k
    where
      k.self_link like '%' || kms_key_name;
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
      join unnest($1::text[]) as a on t.self_link = a and t.project = split_part(a, '/', 6)
    where
      s.topic_name = t.name;
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
      join unnest($1::text[]) as a on t.self_link = a and t.project = split_part(a, '/', 6)
    where
      s.topic_name = t.name;
  EOQ

  param "pubsub_topic_self_links" {}
}