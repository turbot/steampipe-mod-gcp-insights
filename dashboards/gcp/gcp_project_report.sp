dashboard "gcp_project_report" {

  title         = "GCP Project Report"
  documentation = file("./dashboards/gcp/docs/gcp_project_report.md")

  tags = merge(local.gcp_common_tags, {
    type     = "Report"
    category = "Projects"
  })

  container {

    card {
      query = query.gcp_project_count
      width = 2
    }

  }

  table {
    query = query.gcp_project_table
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
      lifecycle_state as "Lifecycle State",
      project_id as "Project ID",
      project_number as "Project Number"
    from
      gcp_project;
  EOQ
}
