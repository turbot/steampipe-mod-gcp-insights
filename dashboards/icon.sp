locals {
  gcp_bigquery_dataset   = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_bigquery_dataset.svg"))
  gcp_compute_firewall   = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_compute_firewall.svg"))
  gcp_compute_instance   = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_compute_instance.svg"))
  gcp_kms_key            = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_kms_key.svg"))
  gcp_kubernetes_cluster = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_kubernetes_cluster.svg"))
  gcp_compute_network    = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_compute_network.svg"))
  gcp_pubsub_topic       = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_pubsub_topic.svg"))
  gcp_compute_router     = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_compute_router.svg"))
  gcp_storage_bucket     = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_storage_bucket.svg"))
}

