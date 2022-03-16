dashboard "gcp_compute_disk_dashboard" {

  title         = "GCP Compute Disk Dashboard"
  documentation = file("./dashboards/compute/docs/compute_disk_dashboard.md")

  tags = merge(local.compute_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.gcp_compute_disk_count
      width = 2
    }

    card {
      query = query.gcp_compute_disk_storage_total
      width = 2
    }

    # Assessments
    card {
      query = query.gcp_compute_disk_unattached_count
      width = 2
    }

    card {
      query = query.gcp_compute_disk_public_image_count
      width = 2
    }
  }

  container {

    title = "Assessments"

    chart {
      title = "Attachment Status"
      query = query.gcp_compute_disk_unattached
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

    chart {
      title = "Public Disk Image Status"
      query = query.gcp_compute_disk_public_image
      type  = "donut"
      width = 3

      series "count" {
        point "private image" {
          color = "ok"
        }
        point "public image" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Disks by Project"
      query = query.gcp_compute_disk_by_project
      type  = "column"
      width = 3
    }

    chart {
      title = "Disks by Location"
      query = query.gcp_compute_disk_by_location
      type  = "column"
      width = 3
    }

    chart {
      title = "Disks by State"
      query = query.gcp_compute_disk_by_state
      type  = "column"
      width = 3
    }

    chart {
      title = "Disks by Age"
      query = query.gcp_compute_disk_by_creation_month
      type  = "column"
      width = 3
    }

    chart {
      title = "Disks by Encryption Type"
      query = query.gcp_compute_disk_by_encryption_type
      type  = "column"
      width = 3
    }

    chart {
      title = "Disks by Type"
      query = query.gcp_compute_disk_by_type
      type  = "column"
      width = 3
    }

  }

  container {

    title  = "Performance & Utilization"

    chart {
      title = "Top 10 Average Read IOPS - Last 7 days"
      query = query.gcp_compute_disk_top_10_read_ops_avg
      type  = "line"
      width = 6
    }

    chart {
      title = "Top 10 Average Write IOPS - Last 7 days"
      query = query.gcp_compute_disk_top_10_write_ops_avg
      type  = "line"
      width = 6
    }

  }

}

# Card Queries

query "gcp_compute_disk_count" {
  sql = <<-EOQ
    select count(*) as "Disks" from gcp_compute_disk;
  EOQ
}

query "gcp_compute_disk_storage_total" {
  sql = <<-EOQ
    select
      sum(size_gb) as "Total Storage (GB)"
    from
      gcp_compute_disk;
  EOQ
}

query "gcp_compute_disk_unattached_count" {
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

query "gcp_compute_disk_public_image_count" {
  sql = <<-EOQ
    with public_disk_images as (
      select
        distinct source_disk_id
      from
        gcp_compute_image
      where
        iam_policy ->> 'bindings' like any (array ['%allAuthenticatedUsers%','%allUsers%'])
    )
    select
      count(*) as value,
      'Public Disk Image' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type" 
    from
      gcp_compute_disk as d
    where
      id::text in (select source_disk_id from public_disk_images);
  EOQ
}

# Assessment Queries

query "gcp_compute_disk_unattached" {
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

query "gcp_compute_disk_public_image" {
  sql = <<-EOQ
    with public_disk_images as (
      select
        distinct source_disk_id as disk_name
      from
        gcp_compute_image
      where
        iam_policy ->> 'bindings' like any (array ['%allAuthenticatedUsers%','%allUsers%'])
    ),
    disk_image_status as (
      select
        case
          when d.name is not null then 'private image'
          else 'public image' end as disk_image_status
      from
        gcp_compute_disk as d
        left join public_disk_images as i on i.disk_name = d.name
    )
    select
      disk_image_status,
      count(*)
    from
      disk_image_status
    group by
      disk_image_status;
  EOQ
}

# Analysis Queries

query "gcp_compute_disk_by_project" {
  sql = <<-EOQ
    select
      p.title as "project",
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

query "gcp_compute_disk_by_location" {
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

query "gcp_compute_disk_by_state" {
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

query "gcp_compute_disk_by_creation_month" {
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

query "gcp_compute_disk_by_encryption_type" {
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

query "gcp_compute_disk_by_type" {
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

# Performance Queries

query "gcp_compute_disk_top_10_read_ops_avg" {
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

query "gcp_compute_disk_top_10_write_ops_avg" {
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
