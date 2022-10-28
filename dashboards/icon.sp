locals {
  gcp_storage_bucket = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/cloud_storage.svg"))
  gcp_kms_key        = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/key_management_service.svg"))
  gcp_pubsub_topic   = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/pubsub.svg"))
}
