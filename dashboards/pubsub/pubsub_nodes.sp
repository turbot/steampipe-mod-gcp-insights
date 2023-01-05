node "pubsub_snapshot" {
  category = category.pubsub_snapshot

  sql = <<-EOQ
  select
      self_link as id,
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
      k.self_link = any($1);
  EOQ

  param "pubsub_snapshot_self_links" {}
}

node "pubsub_subscription" {
  category = category.pubsub_subscription

  sql = <<-EOQ
    select
      self_link as id,
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
      k.self_link = any($1);
  EOQ

  param "pubsub_subscription_self_links" {}
}

node "pubsub_topic" {
  category = category.pubsub_topic

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Location', location,
        'KMS Key', kms_key_name,
        'Project', project,
        'Self Link', self_link
      ) as properties
    from
      gcp_pubsub_topic
    where
      self_link = any($1);
  EOQ

  param "pubsub_topic_self_links" {}
}
