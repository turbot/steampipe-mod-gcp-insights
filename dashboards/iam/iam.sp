locals {
  iam_common_tags = {
    service = "GCP/IAM"
  }
}

category "iam_member" {
  title = "IAM Member"
  color = local.iam_color
  icon  = "component_exchange"
}

category "iam_policy" {
  title = "IAM Policy"
  color = local.iam_color
  icon  = "rule_folder"
}

category "iam_role" {
  title = "IAM Role"
  color = local.iam_color
  icon  = "engineering"
}

category "iam_service_account" {
  title = "IAM Service Account"
  color = local.iam_color
  href  = "/gcp_insights.dashboard.iam_service_account_detail?input.service_account_name={{.properties.'Name' | @uri}}"
  icon  = "settings_account_box"
}

category "iam_service_account_key" {
  title = "IAM Service Account Key"
  color = local.iam_color
  icon  = "key"
}
