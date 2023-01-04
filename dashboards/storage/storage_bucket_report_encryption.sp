dashboard "storage_bucket_encryption_report" {

  title         = "GCP Storage Bucket Encryption Report"
  documentation = file("./dashboards/storage/docs/storage_bucket_report_encryption.md")

  tags = merge(local.storage_common_tags, {
    type     = "Report"
    category = "Encryption"
  })

  container {

    card {
      query = query.storage_bucket_count
      width = 2
    }

    card {
      query = query.storage_bucket_google_managed_encryption
      width = 2
    }

    card {
      query = query.storage_bucket_customer_managed_encryption
      width = 2
    }
  }

  table {
    column "Project ID" {
      display = "none"
    }

    column "Self-Link" {
      display = "none"
    }

    column "ID" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.storage_bucket_detail.url_path}?input.bucket_id={{.ID | @uri}}"
    }

    query = query.storage_bucket_encryption_table
  }

}

query "storage_bucket_google_managed_encryption" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Google Managed Encryption' as label
    from
      gcp_storage_bucket
    where
      default_kms_key_name is null;
  EOQ
}

query "storage_bucket_customer_managed_encryption" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Customer Managed Encryption' as label
    from
      gcp_storage_bucket
    where
      default_kms_key_name is not null;
  EOQ
}

query "storage_bucket_encryption_table" {
  sql = <<-EOQ
    select
      b.name as "Name",
      b.id as "ID",
      case
        when default_kms_key_name is null then 'Google Managed'
        else 'Customer Managed'
      end as "Encryption Type",
      b.default_kms_key_name as "KMS Key",
      p.name as "Project",
      p.project_id as "Project ID",
      b.location as "Location",
      b.self_link as "Self-Link"
    from
      gcp_storage_bucket as b,
      gcp_project as p
    where
      p.project_id = b.project
    order by
      b.name;
  EOQ
}
