locals {
  pubsub_common_tags = {
    service = "GCP/PubSub"
  }
}

category "gcp_pubsub_subscription" {
  color = local.pubsub_color
  icon  = "rss"
  title = "Pub/Sub Subscription"
}

category "gcp_pubsub_topic" {
  color = local.pubsub_color
  href  = "/gcp_insights.dashboard.gcp_pubsub_topic_detail?input.name={{.properties.'Name' | @uri}}"
  icon  = "text:topic"
  title = "Pubsub Topic"
}
