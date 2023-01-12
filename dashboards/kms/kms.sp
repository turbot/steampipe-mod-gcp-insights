locals {
  kms_common_tags = {
    service = "GCP/KMS"
  }
}

category "kms_key" {
  title = "KMS Key"
  color = local.security_color
  href  = "/gcp_insights.dashboard.kms_key_detail?input.key_name={{.properties.'Name' | @uri}}"
  icon  = "key"
}

category "kms_key_ring" {
  title = "KMS Key Ring"
  color = local.security_color
  icon  = "lock_reset"
}

category "kms_key_version" {
  title = "KMS Key Version"
  color = local.security_color
  icon  = "difference"
}
