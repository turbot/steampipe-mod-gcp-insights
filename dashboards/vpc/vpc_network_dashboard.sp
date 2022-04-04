dashboard "gcp_vpc_network_dashboard" {

  title         = "GCP VPC Network Dashboard"
  documentation = file("./dashboards/vpc/docs/vpc_network_dashboard.md")

  tags = merge(local.vpc_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.gcp_vpc_network_count
      width = 2
    }

    card {
      query = query.gcp_vpc_network_total_mtu
      width = 2
    }

    card {
      query = query.gcp_vpc_network_default_count
      width = 2
    }

    card {
      query = query.gcp_vpc_network_no_subnet_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Default VPC Networks"
      type  = "donut"
      width = 4
      query = query.gcp_vpc_network_default_status

      series "count" {
        point "non default" {
          color = "ok"
        }
        point "default" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Empty VPC Networks (No Subnets)"
      type  = "donut"
      width = 4
      query = query.gcp_vpc_network_subnet_status

      series "count" {
        point "non empty" {
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
      title = "VPC Networks by Project"
      query = query.gcp_vpc_network_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "VPC Networks by Routing Mode"
      query = query.gcp_vpc_network_by_routing_mode
      type  = "column"
      width = 4
    }

    chart {
      title = "VPC Networks by Creation Mode"
      query = query.gcp_vpc_network_by_creation_mode
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "gcp_vpc_network_count" {
  sql = <<-EOQ
    select count(*) as "VPC Networks" from gcp_compute_network;
  EOQ
}

query "gcp_vpc_network_total_mtu" {
  sql = <<-EOQ
    select sum(mtu) as "Total MTU (Bytes)" from gcp_compute_network;
  EOQ
}

query "gcp_vpc_network_default_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Default VPC Networks' as label,
      case count(*) when 0 then 'ok' else 'alert' end as type
    from
      gcp_compute_network
    where
      name = 'default';
  EOQ
}

query "gcp_vpc_network_no_subnet_count" {
  sql = <<-EOQ
    select
       count(*) as value,
       'VPCs Without Subnets' as label,
       case when count(*) = 0 then 'ok' else 'alert' end as type
      from
        gcp_compute_network as n
        left join gcp_compute_subnetwork as s on n.name = s.network_name
      where
        s.id is null;
  EOQ
}

# Assessment Queries

query "gcp_vpc_network_default_status" {
  sql = <<-EOQ
    select
      case
        when name = 'default' then 'default'
        else 'non default'
      end as default_status,
      count(*)
    from
      gcp_compute_network
    group by
      default_status;
  EOQ
}

query "gcp_vpc_network_subnet_status" {
  sql = <<-EOQ
    select
      case when s.id is null then 'empty' else 'non empty' end as status,
      count(distinct n.id)
    from
       gcp_compute_network n
      left join gcp_compute_subnetwork s on s.network_name = n.name
    group by
      status;
  EOQ
}

# Analysis Queries

query "gcp_vpc_network_by_project" {
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

query "gcp_vpc_network_by_routing_mode" {
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

query "gcp_vpc_network_by_creation_mode" {
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
