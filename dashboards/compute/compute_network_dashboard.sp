dashboard "gcp_compute_network_dashboard" {

  title         = "GCP Compute Network Dashboard"
  documentation = file("./dashboards/compute/docs/compute_network_dashboard.md")

  tags = merge(local.compute_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.gcp_compute_network_count
      width = 2
    }

    card {
      query = query.gcp_compute_network_total_mtu
      width = 2
    }

    card {
      query = query.gcp_compute_network_peering_disabled
      width = 2
    }

    card {
      query = query.gcp_compute_network_no_subnet_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Empty Networks (No Subnetworks)"
      type  = "donut"
      width = 4
      sql   = query.gcp_compute_network_subnet_status.sql

      series "count" {
        point "non-empty" {
          color = "ok"
        }
        point "empty" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Networks by Project"
      query = query.gcp_compute_network_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Networks by Routing Mode"
      query = query.gcp_compute_network_by_routing_mode
      type  = "column"
      width = 4
    }

    chart {
      title = "Networks by Creation Mode"
      query = query.gcp_compute_network_by_creation_mode
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "gcp_compute_network_count" {
  sql = <<-EOQ
    select count(*) as "Networks" from gcp_compute_network;
  EOQ
}

query "gcp_compute_network_total_mtu" {
  sql = <<-EOQ
    select sum(mtu) as "Total MTU (Bytes)" from gcp_compute_network;
  EOQ
}

query "gcp_compute_network_peering_disabled" {
  sql = <<-EOQ
    select count(name) as "Peering Disabled" from gcp_compute_network where peerings is null;
  EOQ
}

query "gcp_compute_network_no_subnet_count" {
  sql = <<-EOQ
    select
       count(*) as value,
       'Networks Without Subnetworks' as label,
       case when count(*) = 0 then 'ok' else 'alert' end as type
      from
        gcp_compute_network as n
        left join gcp_compute_subnetwork as s on n.name = s.network_name
      where
        s.id is null;
  EOQ
}

# Assessment Queries

query "gcp_compute_network_subnet_status" {
  sql = <<-EOQ
    with subnets as (
      select
        n.id,
        case when s.id is null then 'empty' else 'non-empty' end as status
      from
        gcp_compute_network as n
        left join gcp_compute_subnetwork as s on n.name = s.network_name
    )
    select
      status,
      count(*)
    from
      subnets
    group by
      status;
  EOQ
}

# Analysis Queries

query "gcp_compute_network_by_project" {
  sql = <<-EOQ
    select
      p.title as "project",
      count(n.*) as "total"
    from
      gcp_compute_network as n,
      gcp_project as p
    where
      p.project_id = n.project
    group by
      p.title
    order by count(n.*) desc;
  EOQ
}

query "gcp_compute_network_by_routing_mode" {
  sql = <<-EOQ
    select
      routing_mode as "Routing Mode",
      count(*) as "networks"
    from
      gcp_compute_network
    group by
      routing_mode
    order by
      routing_mode;
  EOQ
}

query "gcp_compute_network_by_creation_mode" {
  sql = <<-EOQ
    select
      case when auto_create_subnetworks then 'auto' else 'custom' end as "Creation Mode",
      count(*) as "networks"
    from
      gcp_compute_network
    group by
      auto_create_subnetworks
    order by
      auto_create_subnetworks;
  EOQ
}
