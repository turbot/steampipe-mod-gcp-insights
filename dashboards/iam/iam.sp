locals {
  iam_common_tags = {
    service = "GCP/IAM"
  }
}

category "gcp_iam_role" {
  color = local.iam_color
  icon  = "user-plus"
  title = "IAM Role"
}
