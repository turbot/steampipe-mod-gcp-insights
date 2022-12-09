locals {
  sql_common_tags = {
    service = "GCP/SQL"
  }
}

category "sql_backup" {
  color = local.database_color
  icon  = "heroicons-outline:arrow-down-on-square-stack"
  title = "GCP SQL Backup"
}

category "sql_database" {
  color = local.database_color
  icon  = "heroicons-outline:square-3-stack-3d"
  title = "GCP SQL Database"
}

category "sql_database_instance" {
  color = local.database_color
  href  = "/gcp_insights.dashboard.sql_database_instance_detail?input.database_instance_name={{.properties.'Name' | @uri}}"
  icon  = "heroicons-outline:circle-stack"
  title = "SQL Database Instance"
}
