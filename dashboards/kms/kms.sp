locals {
  kms_common_tags = {
    service = "GCP/KMS"
  }
}

category "gcp_kms_key" {
  color = local.kms_color
  href  = "/gcp_insights.dashboard.gcp_kms_key_detail?input.key_name={{.properties.'Name' | @uri}}"
  icon  = "key"
  title = "KMS Key"
}

category "gcp_kms_key_ring" {
  color = local.kms_color
  icon  = "key"
  title = "KMS Key Ring"
}

category "gcp_kms_key_version" {
  color = local.kms_color
  icon  = "key"
  title = "KMS Key Version"
}
