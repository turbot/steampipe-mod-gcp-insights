dashboard "compute_instance_dashboard" {

  title         = "GCP Compute Instance Dashboard"
  documentation = file("./dashboards/compute/docs/compute_instance_dashboard.md")

  tags = merge(local.compute_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.compute_instance_count
      width = 2
    }

    # Assessments
    card {
      query = query.compute_instance_with_public_ip_address_count
      width = 2
    }

    card {
      query = query.compute_instance_deletion_protection_disabled_count
      width = 2
    }

    card {
      query = query.compute_instance_confidential_vm_service_disabled_count
      width = 2
    }

    card {
      query = query.compute_shielded_vm_disabled_count
      width = 2
    }
  }

  container {

    title = "Assessments"

    chart {
      title = "Public/Private"
      query = query.compute_instance_by_public_ip
      type  = "donut"
      width = 3

      series "count" {
        point "private" {
          color = "ok"
        }
        point "public" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Deletion Protection Status"
      query = query.compute_instance_deletion_protection_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Confidential VM Status"
      query = query.compute_instance_confidential_vm_service_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Shielded VM Status"
      query = query.compute_instance_shielded_vm_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Instances by Project"
      query = query.compute_instance_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Location"
      query = query.compute_instance_by_location
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by State"
      query = query.compute_instance_by_state
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Age"
      query = query.compute_instance_by_creation_month
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by Type"
      query = query.compute_instance_by_type
      type  = "column"
      width = 4
    }

    chart {
      title = "Instances by CPU Platform"
      query = query.compute_instance_by_cpu_platform
      type  = "column"
      width = 4
    }

  }

  container {

    title = "Performance & Utilization"

    chart {
      title = "Top 10 CPU - Last 7 days"
      query = query.compute_top10_cpu_past_week
      type  = "line"
      width = 6
    }

    chart {
      title = "Average Max Daily CPU - Last 30 days"
      query = query.compute_instance_by_cpu_utilization_category
      type  = "column"
      width = 6
    }

  }

}

# Card Queries

query "compute_instance_count" {
  sql = <<-EOQ
    select count(*) as "Instances" from gcp_compute_instance;
  EOQ
}

query "compute_instance_with_public_ip_address_count" {
  sql = <<-EOQ
    with instance_with_access_config as (
    select
      name
    from
      gcp_compute_instance,
      jsonb_array_elements(network_interfaces) nic,
      jsonb_array_elements(nic -> 'accessConfigs') d
    where
      d ->> 'natIP' is not null
    )
    select
      count(*) as value,
      'Publicly Accessible' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      instance_with_access_config;
  EOQ
}

query "compute_instance_deletion_protection_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Deletion Protection Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_compute_instance
    where
      not deletion_protection;
  EOQ
}

query "compute_instance_confidential_vm_service_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Confidential VM Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_compute_instance
    where
      confidential_instance_config = '{}';
  EOQ
}

query "compute_shielded_vm_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Shielded VM Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_compute_instance
    where
      not shielded_instance_config @> '{"enableVtpm": true, "enableIntegrityMonitoring": true}';
  EOQ
}

# Assessment Queries

query "compute_instance_by_public_ip" {
  sql = <<-EOQ
    with instance_with_access_config as (
    select
      case
        when d ->> 'natIP' is not null then 'public'
        else 'private'
      end as ip_address
    from
      gcp_compute_instance,
      jsonb_array_elements(network_interfaces) nic,
      jsonb_array_elements(nic -> 'accessConfigs') d
    )
    select
      ip_address,
      count(*)
    from
      instance_with_access_config
    group by
      ip_address;
  EOQ
}

query "compute_instance_deletion_protection_status" {
  sql = <<-EOQ
    with instances as (
      select
        case
          when deletion_protection then 'enabled'
          else 'disabled'
        end as deletion_protection_status
      from
        gcp_compute_instance
    )
    select
      deletion_protection_status,
      count(*)
    from
      instances
    group by
      deletion_protection_status;
  EOQ
}

query "compute_instance_confidential_vm_service_status" {
  sql = <<-EOQ
    with instances as (
      select
        case
          when confidential_instance_config <> '{}' then 'enabled'
          else 'disabled'
        end as confidential_instance_status
      from
        gcp_compute_instance
    )
    select
      confidential_instance_status,
      count(*)
    from
      instances
    group by
      confidential_instance_status;
  EOQ
}

query "compute_instance_shielded_vm_status" {
  sql = <<-EOQ
    with instances as (
      select
        case
          when shielded_instance_config @> '{"enableVtpm": true, "enableIntegrityMonitoring": true}' then 'enabled'
          else 'disabled'
        end as shielded_vm_status
      from
        gcp_compute_instance
    )
    select
      shielded_vm_status,
      count(*)
    from
      instances
    group by
      shielded_vm_status;
  EOQ
}

# Analysis Queries

query "compute_instance_by_project" {
  sql = <<-EOQ
    select
      p.title as "Project",
      count(i.*) as "total"
    from
      gcp_compute_instance as i,
      gcp_project as p
    where
      p.project_id = i.project
    group by
      p.title
    order by count(i.*) desc;
  EOQ
}

query "compute_instance_by_location" {
  sql = <<-EOQ
    select
      location,
      count(i.*) as total
    from
      gcp_compute_instance as i
    group by
      location;
  EOQ
}

query "compute_instance_by_state" {
  sql = <<-EOQ
    select
      status,
      count(status)
    from
      gcp_compute_instance
    group by
      status;
  EOQ
}

query "compute_instance_by_creation_month" {
  sql = <<-EOQ
    with instances as (
      select
        title,
        creation_timestamp,
        to_char(creation_timestamp,
          'YYYY-MM') as creation_month
      from
        gcp_compute_instance
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
        from instances)),
        date_trunc('month',
          current_date),
        interval '1 month') as d
    ),
    instances_by_month as (
      select
        creation_month,
        count(*)
      from
        instances
      group by
        creation_month
    )
    select
      months.month,
      instances_by_month.count
    from
      months
      left join instances_by_month on months.month = instances_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "compute_instance_by_type" {
  sql = <<-EOQ
    select 
      machine_type_name as "Type", 
      count(*) as "instances" 
    from 
      gcp_compute_instance 
    group by 
      machine_type_name 
    order by 
      machine_type_name;
  EOQ
}

query "compute_instance_by_cpu_platform" {
  sql = <<-EOQ
    select 
      cpu_platform as "Type", 
      count(*) as "instances" 
    from 
      gcp_compute_instance 
    group by 
      cpu_platform 
    order by 
      cpu_platform;
  EOQ
}

# Performance Queries

query "compute_top10_cpu_past_week" {
  sql = <<-EOQ
    with top_n as (
    select
      name,
      avg(average)
    from
      gcp_compute_instance_metric_cpu_utilization_daily
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
      gcp_compute_instance_metric_cpu_utilization_hourly
    where
      timestamp  >= CURRENT_DATE - INTERVAL '7 day'
      and name in (select name from top_n)
    order by
      timestamp;
  EOQ
}

# underused if avg CPU < 10% every day for last month
query "compute_instance_by_cpu_utilization_category" {
  sql = <<-EOQ
    with cpu_buckets as (
      select
    unnest(array ['Unused (<1%)','Underutilized (1-10%)','Right-sized (10-90%)', 'Overutilized (>90%)' ]) as cpu_bucket
    ),
    max_averages as (
      select
        name,
        case
          when max(average) <= 1 then 'Unused (<1%)'
          when max(average) between 1 and 10 then 'Underutilized (1-10%)'
          when max(average) between 10 and 90 then 'Right-sized (10-90%)'
          when max(average) > 90 then 'Overutilized (>90%)'
        end as cpu_bucket,
        max(average) as max_avg
      from
        gcp_compute_instance_metric_cpu_utilization_daily
      where
        date_part('day', now() - timestamp) <= 30
      group by
        name
    )
    select
      b.cpu_bucket as "CPU Utilization",
      count(a.*)
    from
      cpu_buckets as b
    left join max_averages as a on b.cpu_bucket = a.cpu_bucket
    group by
      b.cpu_bucket;
  EOQ
}
