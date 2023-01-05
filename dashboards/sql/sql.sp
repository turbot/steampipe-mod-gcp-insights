locals {
  sql_common_tags = {
    service = "GCP/SQL"
  }
}

category "sql_backup" {
  color = local.database_color
  icon  = "add_a_photo"
  title = "GCP SQL Backup"
}

category "sql_database" {
  color = local.database_color
  icon  = "database"
  title = "GCP SQL Database"
}

category "sql_database_instance" {
  color = local.database_color
  icon  = "storage"
  href  = "/gcp_insights.dashboard.sql_database_instance_detail?input.database_instance_self_link={{.properties.'Self Link' | @uri}}"
  title = "SQL Database Instance"
}
