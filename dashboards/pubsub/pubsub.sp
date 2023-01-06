locals {
  pubsub_common_tags = {
    service = "GCP/PubSub"
  }
}

category "pubsub_snapshot" {
  title = "Pub/Sub Snapshot"
  color = local.application_integration_color
  icon  = "add_a_photo"
}

category "pubsub_subscription" {
  title = "Pub/Sub Subscription"
  color = local.application_integration_color
  icon  = "broadcast_on_personal"
}

category "pubsub_topic" {
  title = "Pub/Sub Topic"
  color = local.application_integration_color
  href  = "/gcp_insights.dashboard.pubsub_topic_detail?input.self_link={{.properties.'Self Link' | @uri}}"
  icon  = "podcasts"
}
