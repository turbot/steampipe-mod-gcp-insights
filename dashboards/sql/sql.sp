locals {
  sql_common_tags = {
    service = "GCP/SQL"
  }
}

category "gcp_sql_backup" {
  color = local.sql_color
  icon  = "arrow-down-on-square-stack"
  title = "GCP SQL Backup"
}

category "gcp_sql_database_instance" {
  color = local.sql_color
  href  = "/gcp_insights.dashboard.gcp_sql_database_instance_detail?input.database_instance_name={{.properties.'Name' | @uri}}"
  icon  = "circle-stack"
  title = "SQL Database Instance"
}

category "gcp_sql_database" {
  color = local.sql_color
  icon  = "square-3-stack-3d"
  title = "GCP SQL Database"
}
