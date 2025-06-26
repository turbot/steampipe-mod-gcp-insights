dashboard "iam_service_account_inventory_report" {

  title         = "GCP IAM Service Account Inventory Report"
  documentation = file("./dashboards/iam/docs/iam_service_account_report_inventory.md")

  tags = merge(local.iam_common_tags, {
    type     = "Report"
    category = "Inventory"
  })

  container {

    card {
      query = query.iam_service_account_count
      width = 2
    }

  }

  table {
    column "Name" {
      href = "${dashboard.iam_service_account_detail.url_path}?input.service_account_name={{.Name | @uri}}/{{.Project | @uri}}"
    }

    query = query.iam_service_account_inventory_table
  }

}

query "iam_service_account_count" {
  sql = <<-EOQ
    select
      count(*) as "Service Accounts"
    from
      gcp_service_account;
  EOQ
}

query "iam_service_account_inventory_table" {
  sql = <<-EOQ
    select
      sa.name as "Name",
      sa.display_name as "Display Name",
      sa.description as "Description",
      sa.email as "Email",
      sa.disabled as "Disabled",
      sa.oauth2_client_id as "OAuth2 Client ID",
      sa.unique_id as "Unique ID",
      p.name as "Project",
      sa.location as "Location"
    from
      gcp_service_account as sa,
      gcp_project as p
    where
      p.project_id = sa.project
    order by
      sa.name;
  EOQ
} 