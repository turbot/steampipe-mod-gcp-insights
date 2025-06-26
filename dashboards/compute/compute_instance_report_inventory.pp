dashboard "compute_instance_inventory_report" {

  title         = "GCP Compute Instance Inventory Report"
  documentation = file("./dashboards/compute/docs/compute_instance_report_inventory.md")

  tags = merge(local.compute_common_tags, {
    type     = "Report"
    category = "Inventory"
  })

  container {

    card {
      query = query.compute_instance_count
      width = 2
    }

  }

  table {
    column "Name" {
      href = "${dashboard.compute_instance_detail.url_path}?input.instance_id={{.ID | @uri}}/{{.Project | @uri}}"
    }

    query = query.compute_instance_inventory_table
  }

}

query "compute_instance_inventory_table" {
  sql = <<-EOQ
    select
      i.name as "Name",
      i.creation_timestamp as "Creation Time",
      i.status as "Status",
      i.machine_type_name as "Machine Type",
      i.deletion_protection as "Deletion Protection",
      i.can_ip_forward as "IP Forwarding",
      i.network_tags as "Network Tags",
      i.labels as "Labels",
      i.id::text as "ID",
      p.name as "Project",
      i.location as "Location"
    from
      gcp_compute_instance as i,
      gcp_project as p
    where
      p.project_id = i.project
    order by
      i.name;
  EOQ
} 