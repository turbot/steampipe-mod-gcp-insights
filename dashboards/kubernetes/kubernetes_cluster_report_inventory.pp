dashboard "kubernetes_cluster_inventory_report" {

  title         = "GCP Kubernetes Cluster Inventory Report"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_cluster_report_inventory.md")

  tags = merge(local.kubernetes_common_tags, {
    type     = "Report"
    category = "Inventory"
  })

  container {

    card {
      query = query.kubernetes_cluster_count
      width = 2
    }

  }

  table {
    column "Name" {
      href = "${dashboard.kubernetes_cluster_detail.url_path}?input.cluster_id={{.ID | @uri}}/{{.Project | @uri}}"
    }

    query = query.kubernetes_cluster_inventory_table
  }

}

query "kubernetes_cluster_inventory_table" {
  sql = <<-EOQ
    select
      c.name as "Name",
      c.create_time as "Create Time",
      c.status as "Status",
      c.current_master_version as "Current Master Version",
      c.current_node_version as "Current Node Version",
      c.current_node_count as "Current Node Count",
      c.autopilot_enabled as "Autopilot Enabled",
      c.shielded_nodes_enabled as "Shielded Nodes Enabled",
      c.database_encryption_key_name as "Database Encryption Key Name",
      c.resource_labels as "Resource Labels",
      c.id as "ID",
      p.name as "Project",
      c.location as "Location"
    from
      gcp_kubernetes_cluster as c,
      gcp_project as p
    where
      p.project_id = c.project
    order by
      c.name;
  EOQ
} 