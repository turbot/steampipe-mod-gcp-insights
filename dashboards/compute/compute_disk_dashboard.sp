dashboard "compute_disk_dashboard" {

  title         = "GCP Compute Disk Dashboard"
  documentation = file("./dashboards/compute/docs/compute_disk_dashboard.md")

  tags = merge(local.compute_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.compute_disk_count
      width = 3
    }

    card {
      query = query.compute_disk_storage_total
      width = 3
    }

    # Assessments
    card {
      query = query.compute_disk_unattached_count
      width = 3
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Attachment Status"
      query = query.compute_disk_unattached
      type  = "donut"
      width = 3

      series "count" {
        point "in-use" {
          color = "ok"
        }
        point "available" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Disks by Project"
      query = query.compute_disk_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Disks by Location"
      query = query.compute_disk_by_location
      type  = "column"
      width = 4
    }

    chart {
      title = "Disks by State"
      query = query.compute_disk_by_state
      type  = "column"
      width = 4
    }

    chart {
      title = "Disks by Age"
      query = query.compute_disk_by_creation_month
      type  = "column"
      width = 4
    }

    chart {
      title = "Disks by Encryption Type"
      query = query.compute_disk_by_encryption_type
      type  = "column"
      width = 4
    }

    chart {
      title = "Disks by Type"
      query = query.compute_disk_by_type
      type  = "column"
      width = 4
    }

  }

  container {

    chart {
      title = "Storage by Project (GB)"
      query = query.compute_disk_storage_by_project
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Location (GB)"
      query = query.compute_disk_storage_by_location
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by State (GB)"
      query = query.compute_disk_storage_by_state
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Age (GB)"
      query = query.compute_disk_storage_by_creation_month
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Encryption Type (GB)"
      query = query.compute_disk_storage_by_encryption_type
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

    chart {
      title = "Storage by Type (GB)"
      query = query.compute_disk_storage_by_type
      type  = "column"
      width = 4

      series "GB" {
        color = "tan"
      }
    }

  }

  container {

    title = "Performance & Utilization"

    chart {
      title = "Top 10 Average Read IOPS - Last 7 days"
      query = query.compute_disk_top_10_read_ops_avg
      type  = "line"
      width = 6
    }

    chart {
      title = "Top 10 Average Write IOPS - Last 7 days"
      query = query.compute_disk_top_10_write_ops_avg
      type  = "line"
      width = 6
    }

  }

}

# Card Queries

query "compute_disk_count" {
  sql = <<-EOQ
    select count(*) as "Disks" from gcp_compute_disk;
  EOQ
}

query "compute_disk_storage_total" {
  sql = <<-EOQ
    select
      sum(size_gb) as "Total Storage (GB)"
    from
      gcp_compute_disk;
  EOQ
}

query "compute_disk_unattached_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unattached' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_compute_disk
    where
      users is null;
  EOQ
}

# Assessment Queries

query "compute_disk_unattached" {
  sql = <<-EOQ
    with disks as (
      select
        case
          when users is null then 'available'
          else 'in-use'
        end as attachment_status
      from
        gcp_compute_disk
    )
    select
      attachment_status,
      count(*)
    from
      disks
    group by
      attachment_status;
  EOQ
}

# Analysis Queries

query "compute_disk_by_project" {
  sql = <<-EOQ
    select
      p.title as "Project",
      count(d.*) as "total"
    from
      gcp_compute_disk as d,
      gcp_project as p
    where
      p.project_id = d.project
    group by
      p.title
    order by count(d.*) desc;
  EOQ
}

query "compute_disk_by_location" {
  sql = <<-EOQ
    select
      location,
      count(d.*) as total
    from
      gcp_compute_disk as d
    group by
      location;
  EOQ
}

query "compute_disk_by_state" {
  sql = <<-EOQ
    select
      status,
      count(status)
    from
      gcp_compute_disk
    group by
      status;
  EOQ
}

query "compute_disk_by_creation_month" {
  sql = <<-EOQ
    with disks as (
      select
        title,
        creation_timestamp,
        to_char(creation_timestamp,
          'YYYY-MM') as creation_month
      from
        gcp_compute_disk
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
        (
        select
          min(creation_timestamp)
        from disks)),
        date_trunc('month',
          current_date),
        interval '1 month') as d
    ),
    disks_by_month as (
      select
        creation_month,
        count(*)
      from
        disks
      group by
        creation_month
    )
    select
      months.month,
      disks_by_month.count
    from
      months
      left join disks_by_month on months.month = disks_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "compute_disk_by_encryption_type" {
  sql = <<-EOQ
    select
      disk_encryption_key_type as "Encryption Type",
      count(*) as "disks"
    from
      gcp_compute_disk
    group by
      disk_encryption_key_type
    order by
      disk_encryption_key_type;
  EOQ
}

query "compute_disk_by_type" {
  sql = <<-EOQ
    select
      type_name as "Type",
      count(*) as "disks"
    from
      gcp_compute_disk
    group by
      type_name
    order by
      type_name;
  EOQ
}

# Analyis Queries For Storage (Delete me)

query "compute_disk_storage_by_project" {
  sql = <<-EOQ
    select
      p.title as "Project",
      sum(d.size_gb) as "GB"
    from
      gcp_compute_disk as d,
      gcp_project as p
    where
      p.project_id = d.project
    group by
      p.title
    order by count(d.*) desc;
  EOQ
}

query "compute_disk_storage_by_location" {
  sql = <<-EOQ
    select
      location,
      sum(d.size_gb) as "GB"
    from
      gcp_compute_disk as d
    group by
      location;
  EOQ
}

query "compute_disk_storage_by_state" {
  sql = <<-EOQ
    select
      status,
      sum(size_gb) as "GB"
    from
      gcp_compute_disk
    group by
      status;
  EOQ
}

query "compute_disk_storage_by_creation_month" {
  sql = <<-EOQ
    with disks as (
      select
        title,
        creation_timestamp,
        size_gb,
        to_char(creation_timestamp,
          'YYYY-MM') as creation_month
      from
        gcp_compute_disk
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
        (
        select
          min(creation_timestamp)
        from disks)),
        date_trunc('month',
          current_date),
        interval '1 month') as d
    ),
    disks_by_month as (
      select
        creation_month,
        sum(size_gb) as size
      from
        disks
      group by
        creation_month
    )
    select
      months.month,
      disks_by_month.size as "GB"
    from
      months
      left join disks_by_month on months.month = disks_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "compute_disk_storage_by_encryption_type" {
  sql = <<-EOQ
    select
      disk_encryption_key_type as "Encryption Type",
      sum(size_gb) as "GB"
    from
      gcp_compute_disk
    group by
      disk_encryption_key_type
    order by
      disk_encryption_key_type;
  EOQ
}

query "compute_disk_storage_by_type" {
  sql = <<-EOQ
    select
      type_name as "Type",
      sum(size_gb) as "GB"
    from
      gcp_compute_disk
    group by
      type_name
    order by
      type_name;
  EOQ
}

# Performance Queries

query "compute_disk_top_10_read_ops_avg" {
  sql = <<-EOQ
    with top_n as (
      select
        name,
        avg(average)
      from
        gcp_compute_disk_metric_read_ops_daily
      where
        timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      group by
        name
      order by
        avg desc
      limit 10
    )
    select
      timestamp,
      name,
      average
    from
      gcp_compute_disk_metric_read_ops_hourly
    where
      timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      and name in (select name from top_n);
  EOQ
}

query "compute_disk_top_10_write_ops_avg" {
  sql = <<-EOQ
    with top_n as (
      select
        name,
        avg(average)
      from
        gcp_compute_disk_metric_write_ops_daily
      where
        timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      group by
        name
      order by
        avg desc
      limit 10
    )
    select
      timestamp,
      name,
      average
    from
      gcp_compute_disk_metric_write_ops_hourly
    where
      timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      and name in (select name from top_n);
  EOQ
}
