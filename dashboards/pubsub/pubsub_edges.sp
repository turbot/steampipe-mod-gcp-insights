edge "pubsub_topic_to_iam_role" {
  title = "assumes"

  sql = <<-EOQ
    select
      topic_name as from_id,
      role_id as to_id
    from
      unnest($1::text[]) as topic_name,
      unnest($2::text[]) as role_id;
  EOQ

  param "pubsub_topic_names" {}
  param "iam_role_ids" {}
}

edge "pubsub_topic_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      topic_name as from_id,
      key_name as to_id
    from
      unnest($1::text[]) as topic_name,
      unnest($2::text[]) as key_name;
  EOQ

  param "pubsub_topic_names" {}
  param "kms_key_names" {}
}

edge "pubsub_topic_to_pubsub_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
    select
      topic_name as from_id,
      snapshot_name || 'snapshot' as to_id
    from
      unnest($1::text[]) as topic_name,
      unnest($2::text[]) as snapshot_name;
  EOQ

  param "pubsub_topic_names" {}
  param "pubsub_snapshot_names" {}
}

edge "pubsub_topic_to_pubsub_subscription" {
  title = "subscribed to"

  sql = <<-EOQ
    select
      topic_name as from_id,
      subscription_name || 'subscription' as to_id
    from
      unnest($1::text[]) as topic_name,
      unnest($2::text[]) as subscription_name;
  EOQ

  param "pubsub_topic_names" {}
  param "pubsub_subscription_names" {}
}