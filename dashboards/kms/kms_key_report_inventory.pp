dashboard "kms_key_inventory_report" {

  title         = "GCP KMS Key Inventory Report"
  documentation = file("./dashboards/kms/docs/kms_key_report_inventory.md")

  tags = merge(local.kms_common_tags, {
    type     = "Report"
    category = "Inventory"
  })

  container {

    card {
      query = query.kms_key_count
      width = 2
    }

  }

  table {
    column "Name" {
      href = "${dashboard.kms_key_detail.url_path}?input.key_name={{.Name}}"
    }

    query = query.kms_key_inventory_table
  }

}

query "kms_key_inventory_table" {
  sql = <<-EOQ
    select
      k.name as "Name",
      k.create_time as "Creation Time",
      k.purpose as "Purpose",
      k.key_ring_name as "Key Ring",
      k.rotation_period as "Rotation Period",
      k.next_rotation_time as "Next Rotation Time",
      k.labels as "Labels",
      p.name as "Project",
      k.location as "Location"
    from
      gcp_kms_key as k,
      gcp_project as p
    where
      p.project_id = k.project
    order by
      k.name;
  EOQ
} 