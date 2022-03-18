dashboard "gcp_compute_disk_encryption_report" {
  
  title         = "GCP Compute Disk Encryption Report"
  documentation = file("./dashboards/compute/docs/compute_disk_report_encryption.md")

  tags = merge(local.compute_common_tags, {
    type     = "Report"
    category = "Encryption"
  })

  container {

    card {
      query = query.gcp_compute_disk_count
      width = 2
    }

    card {
      query = query.gcp_compute_disk_google_managed_encryption
      width = 2
    }

    card {
      query = query.gcp_compute_disk_customer_managed_encryption
      width = 2
    }

    card {
      query = query.gcp_compute_disk_customer_supplied_encryption
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
    query = query.gcp_compute_disk_encryption_table
  }

}

query "gcp_compute_disk_google_managed_encryption" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Google Managed Encryption' as label
    from
      gcp_compute_disk
    where
      disk_encryption_key_type = 'Google managed';
  EOQ
}

query "gcp_compute_disk_customer_managed_encryption" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Customer Managed Encryption' as label
    from
      gcp_compute_disk
    where
      disk_encryption_key_type = 'Customer managed';
  EOQ
}

query "gcp_compute_disk_customer_supplied_encryption" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Customer Supplied Encryption' as label
    from
      gcp_compute_disk
    where
      disk_encryption_key_type not in ('Customer managed', 'Google managed');
  EOQ
}

query "gcp_compute_disk_encryption_table" {
  sql = <<-EOQ
    select
      d.name as "Name",
      case
        when disk_encryption_key_type = 'Google managed' then 'Google Managed'
        when disk_encryption_key_type = 'Customer managed' then 'Customer Managed'
        else 'Customer Supplied'
      end as "Encryption Type",
      d.disk_encryption_key ->> 'kmsKeyName' as "KMS Key",
      p.name as "Project",
      p.project_id as "Project ID",
      d.location as "Location",
      d.self_link as "Self-Link"
    from
      gcp_compute_disk as d,
      gcp_project as p
    where
      p.project_id = d.project
    order by
      d.name;
  EOQ
}
