dashboard "gcp_kubernetes_cluster_dashboard" {

  title         = "GCP Kubernetes Cluster Dashboard"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_cluster_dashboard.md")

  tags = merge(local.kubernetes_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.gcp_kubernetes_cluster_count
      width = 2
    }

    card {
      query = query.gcp_kubernetes_cluster_node_count
      width = 2
    }

    card {
      query = query.gcp_kubernetes_cluster_database_encryption_count
      width = 2
    }

    card {
      query = query.gcp_kubernetes_cluster_degraded_count
      width = 2
    }

    card {
      query = query.gcp_kubernetes_cluster_shielded_nodes_disabled_count
      width = 2
    }

    card {
      query = query.gcp_kubernetes_cluster_auto_repair_disabled_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Cluster Status"
      query = query.gcp_kubernetes_cluster_status
      type  = "donut"
      width = 3

      series "count" {
        point "ok" {
          color = "ok"
        }
        point "degraded" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Database Encryption Status"
      query = query.gcp_kubernetes_cluster_encryption_status
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
      title = "Shielded Nodes Status"
      query = query.gcp_kubernetes_cluster_shielded_nodes_status
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
      title = "Node Auto-Repair Status"
      query = query.gcp_kubernetes_cluster_auto_repair_status
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
      title = "Clusters by Project"
      query = query.gcp_kubernetes_cluster_by_project
      type  = "column"
      width = 3
    }

    chart {
      title = "Clusters by Location"
      query = query.gcp_kubernetes_cluster_by_location
      type  = "column"
      width = 3
    }

    chart {
      title = "Clusters by State"
      query = query.gcp_kubernetes_cluster_by_state
      type  = "column"
      width = 3
    }

    chart {
      title = "Clusters by Age"
      query = query.gcp_kubernetes_cluster_by_creation_month
      type  = "column"
      width = 3
    }

  }

}

# Card Queries

query "gcp_kubernetes_cluster_count" {
  sql = <<-EOQ
    select count(*) as "Clusters" from gcp_kubernetes_cluster;
  EOQ
}

query "gcp_kubernetes_cluster_node_count" {
  sql = <<-EOQ
    select
      sum (current_node_count) as "Total Nodes"
    from
      gcp_kubernetes_cluster;
  EOQ
}

query "gcp_kubernetes_cluster_database_encryption_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Database Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_kubernetes_cluster
    where
      database_encryption_key_name = '';
  EOQ
}

query "gcp_kubernetes_cluster_degraded_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Degraded' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_kubernetes_cluster
    where
      status = 'DEGRADED';
  EOQ
}

query "gcp_kubernetes_cluster_shielded_nodes_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Shielded Nodes Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_kubernetes_cluster
    where
      not shielded_nodes_enabled;
  EOQ
}

query "gcp_kubernetes_cluster_auto_repair_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Node Auto-Repair Disabled' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_kubernetes_cluster,
      jsonb_array_elements(node_pools) as np
    where
      np -> 'management' -> 'autoRepair' <> 'true';
  EOQ
}

# Assessment Queries

query "gcp_kubernetes_cluster_encryption_status" {
  sql = <<-EOQ
    select
      encryption_status,
      count(*)
    from (
      select name,
        case when database_encryption_key_name = '' then
          'disabled'
        else
          'enabled'
        end encryption_status
      from
        gcp_kubernetes_cluster) as c
    group by
      encryption_status
    order by
      encryption_status;
  EOQ
}

query "gcp_kubernetes_cluster_status" {
  sql = <<-EOQ
    select
      status,
      count(*)
    from (
      select name,
        case when status = 'DEGRADED' then
          'degraded'
        else
          'ok'
        end status
      from
        gcp_kubernetes_cluster) as c
    group by
      status
    order by
      status;
  EOQ
}

query "gcp_kubernetes_cluster_shielded_nodes_status" {
  sql = <<-EOQ
    select
      status,
      count(*)
    from (
      select name,
        case when shielded_nodes_enabled then
          'enabled'
        else
          'disabled'
        end status
      from
        gcp_kubernetes_cluster) as c
    group by
      status
    order by
      status;
  EOQ
}

query "gcp_kubernetes_cluster_auto_repair_status" {
  sql = <<-EOQ
    select
      status,
      count(*)
    from (
      select name,
        case when np -> 'management' -> 'autoRepair' = 'true' then
          'enabled'
        else
          'disabled'
        end status
      from
        gcp_kubernetes_cluster,
        jsonb_array_elements(node_pools) as np) as c
    group by
      status
    order by
      status;
  EOQ
}

# Analysis Queries

query "gcp_kubernetes_cluster_by_project" {
  sql = <<-EOQ
    select
      p.title as "project",
      count(i.*) as "total"
    from
      gcp_kubernetes_cluster as i,
      gcp_project as p
    where
      p.project_id = i.project
    group by
      p.title
    order by count(i.*) desc;
  EOQ
}

query "gcp_kubernetes_cluster_by_location" {
  sql = <<-EOQ
    select
      location,
      count(i.*) as total
    from
      gcp_kubernetes_cluster as i
    group by
      location;
  EOQ
}

query "gcp_kubernetes_cluster_by_state" {
  sql = <<-EOQ
    select
      status,
      count(status)
    from
      gcp_kubernetes_cluster
    group by
      status;
  EOQ
}

query "gcp_kubernetes_cluster_by_creation_month" {
  sql = <<-EOQ
    with clusters as (
      select
        title,
        create_time,
        to_char(create_time,
          'YYYY-MM') as creation_month
      from
        gcp_kubernetes_cluster
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
        (
        select
          min(create_time)
        from clusters)),
        date_trunc('month',
          current_date),
        interval '1 month') as d
    ),
    clusters_by_month as (
      select
        creation_month,
        count(*)
      from
        clusters
      group by
        creation_month
    )
    select
      months.month,
      clusters_by_month.count
    from
      months
      left join clusters_by_month on months.month = clusters_by_month.creation_month
    order by
      months.month;
  EOQ
}
