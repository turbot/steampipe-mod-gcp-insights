dashboard "gcp_project_report" {

  title         = "GCP Project Report"
  documentation = file("./dashboards/gcp/docs/gcp_project_report.md")

  tags = merge(local.gcp_common_tags, {
    type     = "Report"
    category = "Projects"
  })

  container {

    card {
      sql   = query.gcp_project_count.sql
      width = 2
    }

  }

  table {
    sql = query.gcp_project_table.sql
  }

}

query "gcp_project_count" {
  sql = <<-EOQ
    select
      count(*) as "Projects"
    from
      gcp_project;
  EOQ
}

query "gcp_project_table" {
  sql = <<-EOQ
    select
      name as "Name",
      project_id as "Project ID",
      project_number as "Project Number",
      lifecycle_state as "Lifecycle State"
    from
      gcp_project;
  EOQ
}
