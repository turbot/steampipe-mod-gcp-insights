locals {
  pubsub_common_tags = {
    service = "GCP/PubSub"
  }
}

category "pubsub_snapshot" {
  color = local.application_integration_color
  icon  = "add_a_photo"
  title = "Pub/Sub Snapshot"
}

category "pubsub_subscription" {
  color = local.application_integration_color
  icon  = "broadcast_on_personal"
  title = "Pub/Sub Subscription"
}

category "pubsub_topic" {
  color = local.application_integration_color
  href  = "/gcp_insights.dashboard.pubsub_topic_detail?input.self_link={{.properties.'Self Link' | @uri}}"
  icon  = "podcasts"
  title = "Pub/Sub Topic"
}
