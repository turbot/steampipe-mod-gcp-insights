node "pubsub_topic" {
  category = category.pubsub_topic

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Location', location,
        'KMS Key', kms_key_name
      ) as properties
    from
      gcp_pubsub_topic
    where
      name = any($1);
  EOQ

  param "pubsub_topic_names" {}
}

node "pubsub_subscription" {
  category = category.pubsub_subscription

  sql = <<-EOQ
  select
      k.name as id,
      k.title,
      jsonb_build_object(
        'Name', k.name,
        'Location', k.location,
        'Project', k.project,
        'Self Link', k.self_link
      ) as properties
    from
      gcp_pubsub_subscription k
    where
      k.name = any($1);
  EOQ

  param "pubsub_subscription_names" {}
}

node "pubsub_snapshot" {
  category = category.pubsub_snapshot

  sql = <<-EOQ
  select
      k.name as id,
      k.title,
      jsonb_build_object(
        'Name', k.name,
        'Location', k.location,
        'Project', k.project,
        'Self Link', k.self_link
      ) as properties
    from
      gcp_pubsub_snapshot k
    where
      k.name = any($1);
  EOQ

  param "pubsub_snapshot_names" {}
}