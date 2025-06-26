dashboard "sql_database_instance_inventory_report" {

  title         = "GCP SQL Database Instance Inventory Report"
  documentation = file("./dashboards/sql/docs/sql_database_instance_report_inventory.md")

  tags = merge(local.sql_common_tags, {
    type     = "Report"
    category = "Inventory"
  })

  container {

    card {
      query = query.sql_database_instance_count
      width = 2
    }

  }

  table {
    column "Name" {
      href = "${dashboard.sql_database_instance_detail.url_path}?input.instance_name={{.Name | @uri}}"
    }

    query = query.sql_database_instance_inventory_table
  }

}

query "sql_database_instance_inventory_table" {
  sql = <<-EOQ
    select
      i.name as "Name",
      i.create_time as "Create Time",
      i.database_version as "Database Version",
      i.state as "State",
      i.instance_type as "Instance Type",
      i.machine_type as "Machine Type",
      i.availability_type as "Availability Type",
      i.backup_enabled as "Backup Enabled",
      i.kms_key_name as "KMS Key Name",
      i.labels as "Labels",
      i.connection_name as "Connection Name",
      p.name as "Project",
      i.location as "Location"
    from
      gcp_sql_database_instance as i,
      gcp_project as p
    where
      p.project_id = i.project
    order by
      i.name;
  EOQ
} 