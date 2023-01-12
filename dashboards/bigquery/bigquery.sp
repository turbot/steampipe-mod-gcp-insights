locals {
  bigquery_common_tags = {
    service = "GCP/BigQuery"
  }
}

category "bigquery_dataset" {
  title = "BigQuery Dataset"
  color = local.database_color
  icon  = "speed"
}

category "bigquery_table" {
  title = "BigQuery Table"
  color = local.database_color
  icon  = "table"
}
