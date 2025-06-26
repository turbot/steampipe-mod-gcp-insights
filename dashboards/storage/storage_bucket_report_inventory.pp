dashboard "storage_bucket_inventory_report" {

  title         = "GCP Storage Bucket Inventory Report"
  documentation = file("./dashboards/storage/docs/storage_bucket_report_inventory.md")

  tags = merge(local.storage_common_tags, {
    type     = "Report"
    category = "Inventory"
  })

  container {

    card {
      query = query.storage_bucket_count
      width = 2
    }

  }

  table {
    column "Name" {
      href = "${dashboard.storage_bucket_detail.url_path}?input.bucket_id={{.ID | @uri}}/{{.Project | @uri}}"
    }

    query = query.storage_bucket_inventory_table
  }

}

query "storage_bucket_inventory_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      b.time_created as "Time Created",
      b.storage_class as "Storage Class",
      b.versioning_enabled as "Versioning Enabled",
      b.default_kms_key_name as "Default KMS Key Name",
      b.iam_configuration_uniform_bucket_level_access_enabled as "IAM Configuration Uniform Bucket Level Access Enabled",
      b.iam_configuration_public_access_prevention as "IAM Configuration Public Access Prevention",
      b.lifecycle_rules as "Lifecycle Rules",
      b.labels as "Labels",
      b.id as "ID",
      p.name as "Project",
      b.location as "Location"
    from
      gcp_storage_bucket as b,
      gcp_project as p
    where
      p.project_id = b.project
    order by
      b.name;
  EOQ
} 