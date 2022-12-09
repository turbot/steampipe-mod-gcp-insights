locals {
  kms_common_tags = {
    service = "GCP/KMS"
  }
}

category "kms_key" {
  color = local.security_color
  href  = "/gcp_insights.dashboard.kms_key_detail?input.key_name={{.properties.'Name' | @uri}}"
  icon  = "heroicons-outline:key"
  title = "KMS Key"
}

category "kms_key_ring" {
  color = local.security_color
  icon  = "heroicons-outline:key"
  title = "KMS Key Ring"
}

category "kms_key_version" {
  color = local.security_color
  icon  = "heroicons-outline:key"
  title = "KMS Key Version"
}
