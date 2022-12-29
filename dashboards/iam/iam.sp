locals {
  iam_common_tags = {
    service = "GCP/IAM"
  }
}

category "iam_role" {
  color = local.iam_color
  icon  = "engineering"
  title = "IAM Role"
}

category "iam_service_account" {
  color = local.iam_color
  icon  = "settings_account_box"
  title = "IAM Service Account"
}
