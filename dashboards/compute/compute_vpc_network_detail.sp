dashboard "gcp_compute_vpc_network_detail" {

  title         = "GCP Compute VPC Network Detail"
  documentation = file("./dashboards/compute/docs/compute_vpc_network_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "vpc_name" {
    title = "Select a VPC Network:"
    query = query.gcp_compute_vpc_network_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_compute_vpc_network_mtu
      args = {
        name = self.input.vpc_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_vpc_network_subnet_count
      args = {
        name = self.input.vpc_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_vpc_network_is_default
      args = {
        name = self.input.vpc_name.value
      }
    }

  }

  container {

    container {

      table {
        title = "Overview"
        width = 4
        type  = "line"
        query = query.gcp_compute_vpc_network_overview
        args = {
          name = self.input.vpc_name.value
        }
      }

      table {
        title = "Peering Details"
        width = 8
        query = query.gcp_compute_vpc_network_peering
        args = {
          name = self.input.vpc_name.value
        }
      }

    }

    container {

      table {
        title = "Subnet Details"
        query = query.gcp_compute_vpc_network_subnet
        args = {
          name = self.input.vpc_name.value
        }
      }

    }

  }

}

query "gcp_compute_vpc_network_input" {
  sql = <<-EOQ
    select
      name as label,
      name as value,
      json_build_object(
        'project', project,
        'id', id
      ) as tags
    from
      gcp_compute_network
    order by
      title;
  EOQ
}

query "gcp_compute_vpc_network_mtu" {
  sql = <<-EOQ
    select
      'MTU (Bytes)' as label,
      mtu as value
    from
      gcp_compute_network
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_compute_vpc_network_subnet_count" {
  sql = <<-EOQ
    select
      'Subnets' as label,
      count(*) as value,
      case when count(*) > 0 then 'ok' else 'alert' end as type
    from
      gcp_compute_subnetwork
    where
      network_name = $1;
  EOQ

  param "name" {}
}

query "gcp_compute_vpc_network_is_default" {
  sql = <<-EOQ
    select
      'Default VPC' as label,
      case when name <> 'default' then 'ok' else 'Default VPC' end as value,
      case when name <> 'default' then 'ok' else 'alert' end as type
    from
      gcp_compute_network
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_compute_vpc_network_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      creation_timestamp as "Creation Time",
      mtu as "MTU",
      routing_mode as "Routing Mode",
      location as "Location",
      project as "Project"
    from
      gcp_compute_network
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_compute_vpc_network_peering" {
  sql = <<-EOQ
    select
      p ->> 'name' as "Name",
      p ->> 'state' as "State",
      p ->> 'stateDetails' as "State Details",
      p ->> 'autoCreateRoutes' as "Auto Create Routes",
      p ->> 'exchangeSubnetRoutes' as "Exchange Subnet Routes",
      p ->> 'exportSubnetRoutesWithPublicIp' as "Export Subnet Routes With Public IP"
    from
      gcp_compute_network,
      jsonb_array_elements(peerings) as p
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_compute_vpc_network_subnet" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      creation_timestamp as "Creation Time",
      enable_flow_logs as "Enable Flow Logs",
      log_config_enable as "Log Config Enabled",
      gateway_address as "Gateway Address",
      ip_cidr_range as "IPv4 CIDR Range",
      ipv6_cidr_range as "IPv6 CIDR Range",
      private_ip_google_access as "Private IPv4 Google Access",
      private_ipv6_google_access as "Private IPv6 Google Access"
    from
      gcp_compute_subnetwork
    where
      network_name = $1;
  EOQ

  param "name" {}
}
