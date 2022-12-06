locals {
  bigquery_common_tags = {
    service = "GCP/BigQuery"
  }
}

category "bigquery_dataset" {
  color = local.sql_color
  icon  = "square-3-stack-3d"
  title = "BigQuery Dataset"
}

category "bigquery_table" {
  color = local.sql_color
  icon  = "circle-stack"
  title = "BigQuery Table"
}