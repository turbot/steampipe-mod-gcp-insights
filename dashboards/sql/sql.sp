locals {
  sql_common_tags = {
    service = "GCP/SQL"
  }
}

category "sql_backup" {
  title = "GCP SQL Backup"
  color = local.database_color
  icon  = "add_a_photo"
}

category "sql_database" {
  title = "GCP SQL Database"
  color = local.database_color
  icon  = "database"
}

category "sql_database_instance" {
  title = "SQL Database Instance"
  color = local.database_color
  href  = "/gcp_insights.dashboard.sql_database_instance_detail?input.database_instance_self_link={{.properties.'Self Link' | @uri}}"
  icon  = "storage"
}
