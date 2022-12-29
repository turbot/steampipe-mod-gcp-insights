locals {
  bigquery_common_tags = {
    service = "GCP/BigQuery"
  }
}

category "bigquery_dataset" {
  color = local.database_color
  icon  = "speed"
  title = "BigQuery Dataset"
}

category "bigquery_table" {
  color = local.database_color
  icon  = "table"
  title = "BigQuery Table"
}
