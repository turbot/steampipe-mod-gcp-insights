locals {
  iam_common_tags = {
    service = "GCP/IAM"
  }
}

category "iam_role" {
  color = local.iam_color
  icon  = "heroicons-outline:user-plus"
  title = "IAM Role"
}

category "iam_service_account" {
  color = local.iam_color
  icon  = "text:SA"
  title = "IAM Service Account"
}
