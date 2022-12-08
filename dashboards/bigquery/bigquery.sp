locals {
  bigquery_common_tags = {
    service = "GCP/BigQuery"
  }
}

category "bigquery_dataset" {
  color = local.sql_color
  icon  = "heroicons-outline:square-3-stack-3d"
  title = "BigQuery Dataset"
}

category "bigquery_table" {
  color = local.sql_color
  icon  = "heroicons-outline:circle-stack"
  title = "BigQuery Table"
}