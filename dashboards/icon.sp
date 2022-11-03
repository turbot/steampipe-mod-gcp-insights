locals {
  gcp_storage_bucket             = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/cloud_storage.svg"))
  gcp_kms_key                    = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/key_management_service.svg"))
  gcp_compute_forwarding_rule    = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/compute_forwarding_rule.svg"))
  gcp_compute_backend_service    = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/compute_backend_service.svg"))
  gcp_compute_target_pool        = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/compute_target_pool.svg"))
  gcp_compute_target_https_proxy = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/compute_target_https_proxy.svg"))
  gcp_compute_target_ssl_proxy   = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/compute_target_ssl_proxy.svg"))
}
