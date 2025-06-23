dashboard "compute_disk_inventory_report" {

  title         = "GCP Compute Disk Inventory Report"
  documentation = file("./dashboards/compute/docs/compute_disk_report_inventory.md")

  tags = merge(local.compute_common_tags, {
    type     = "Report"
    category = "Inventory"
  })

  container {

    card {
      query = query.compute_disk_count
      width = 2
    }

  }

  table {
    column "Name" {
      href = "${dashboard.compute_disk_detail.url_path}?input.disk_id={{.ID}}/{{.Project}}"
    }

    query = query.compute_disk_inventory_table
  }

}

query "compute_disk_inventory_table" {
  sql = <<-EOQ
    select
      d.name as "Name",
      d.creation_timestamp as "Creation Timestamp",
      d.status as "Status",
      d.size_gb as "Size GB",
      d.type_name as "Type Name",
      d.disk_encryption_key_type as "Disk Encryption Key Type",
      d.source_image as "Source Image",
      d.source_snapshot as "Source Snapshot",
      d.labels as "Labels",
      d.id::text as "ID",
      p.name as "Project",
      d.location as "Location"
    from
      gcp_compute_disk as d,
      gcp_project as p
    where
      p.project_id = d.project
    order by
      d.name;
  EOQ
} 