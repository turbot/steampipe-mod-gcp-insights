locals {
  iam_common_tags = {
    service = "GCP/IAM"
  }
}

category "iam_role" {
  title = "IAM Role"
  color = local.iam_color
  icon  = "engineering"
}

category "iam_service_account" {
  title = "IAM Service Account"
  color = local.iam_color
  icon  = "settings_account_box"
}
