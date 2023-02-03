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
      width = 3
    }

    card {
      query = query.storage_bucket_google_managed_encryption
      width = 3
    }

    card {
      query = query.storage_bucket_customer_managed_encryption
      width = 3
    }
  }

  table {
    column "Self-Link" {
      display = "none"
    }

    column "ID" {
      display = "none"
    }

    column "KMS Self-Link" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.storage_bucket_detail.url_path}?input.bucket_id={{.ID | @uri}}"
    }

    column "KMS Key" {
      href = "${dashboard.kms_key_detail.url_path}?input.key_self_link={{.'KMS Self-Link' | @uri}}"
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
      b.project as "Project",
      b.location as "Location",
      b.self_link as "Self-Link",
      k.self_link as "KMS Self-Link"
    from
      gcp_storage_bucket as b
      left join gcp_kms_key as k
        on k.self_link like '%' || b.default_kms_key_name
    order by
      b.name;
  EOQ
}
