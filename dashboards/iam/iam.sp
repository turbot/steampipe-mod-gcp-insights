locals {
  iam_common_tags = {
    service = "GCP/IAM"
  }
}

category "iam_role" {
  color = local.iam_color
  icon  = "user-plus"
  title = "IAM Role"
}

category "service_account" {
  color = local.iam_color
  icon  = "text:SA"
  title = "Service Account"
}