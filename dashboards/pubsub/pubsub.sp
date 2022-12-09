locals {
  pubsub_common_tags = {
    service = "GCP/PubSub"
  }
}

category "pubsub_snapshot" {
  color = local.application_integration_color
  icon  = "heroicons-outline:rss"
  title = "Pub/Sub Snapshot"
}

category "pubsub_subscription" {
  color = local.application_integration_color
  icon  = "heroicons-outline:rss"
  title = "Pub/Sub Subscription"
}

category "pubsub_topic" {
  color = local.application_integration_color
  href  = "/gcp_insights.dashboard.pubsub_topic_detail?input.name={{.properties.'Name' | @uri}}"
  icon  = "text:topic"
  title = "Pub/Sub Topic"
}
