dashboard "gcp_compute_network_detail" {

  title         = "GCP Compute Network Detail"
  documentation = file("./dashboards/compute/docs/compute_network_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "network_name" {
    title = "Select a network:"
    query = query.gcp_compute_network_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_compute_network_mtu
      args = {
        name = self.input.network_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_network_subnet_count
      args = {
        name = self.input.network_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_network_is_default
      args = {
        name = self.input.network_name.value
      }
    }

  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"


      nodes = [
        node.gcp_compute_network_node,
        node.gcp_compute_network_from_compute_subnetwork_node,
        node.gcp_compute_network_to_compute_firewall_node,
        node.gcp_compute_network_to_compute_backend_service_node,
        node.gcp_compute_network_to_compute_router_node,
        node.gcp_compute_network_to_sql_database_instance_node
      ]

      edges = [
        edge.gcp_compute_network_from_compute_subnetwork_edge,
        edge.gcp_compute_network_to_compute_firewall_edge,
        edge.gcp_compute_network_to_compute_backend_service_edge,
        edge.gcp_compute_network_to_compute_router_edge,
        edge.gcp_compute_network_to_sql_database_instance_edge
      ]

      args = {
        name = self.input.network_name.value
      }
    }
  }

  container {

    container {

      table {
        title = "Overview"
        width = 4
        type  = "line"
        query = query.gcp_compute_network_overview
        args = {
          name = self.input.network_name.value
        }
      }

      table {
        title = "Peering Details"
        width = 8
        query = query.gcp_compute_network_peering
        args = {
          name = self.input.network_name.value
        }
      }

    }

    container {

      table {
        title = "Subnet Details"
        query = query.gcp_compute_network_subnet
        args = {
          name = self.input.network_name.value
        }
      }

    }

  }

}

query "gcp_compute_network_input" {
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

query "gcp_compute_network_mtu" {
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

query "gcp_compute_network_subnet_count" {
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

query "gcp_compute_network_is_default" {
  sql = <<-EOQ
    select
      'Default Network' as label,
      case when name <> 'default' then 'ok' else 'Default network' end as value,
      case when name <> 'default' then 'ok' else 'alert' end as type
    from
      gcp_compute_network
    where
      name = $1;
  EOQ

  param "name" {}
}

category "gcp_compute_network_no_link" {
  icon = local.gcp_compute_network
}

node "gcp_compute_network_node" {
  category = category.gcp_compute_network_no_link

  sql = <<-EOQ
    select
      n.name as id,
      n.title,
      jsonb_build_object(
        'ID', n.id,
        'Name', n.name,
        'Created Time', n.creation_timestamp,
        'Location', n.location
      ) as properties
    from
      gcp_compute_network n
    where
      n.name = $1;
  EOQ

  param "name" {}
}

node "gcp_compute_network_from_compute_subnetwork_node" {
  category = category.gcp_compute_subnetwork

  sql = <<-EOQ
    select
      s.id::text as id,
      s.name as title,
      jsonb_build_object(
        'ID', s.id,
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Location', s.location,
        'IP Cidr Range', s.ip_cidr_range
      ) as properties
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

edge "gcp_compute_network_from_compute_subnetwork_edge" {
  title = "network"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      n.name as to_id
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

node "gcp_compute_network_to_compute_firewall_node" {
  category = category.gcp_compute_firewall

  sql = <<-EOQ
    select
      f.id::text,
      f.title,
      jsonb_build_object(
        'ID', f.id,
        'Direction', f.direction,
        'Enabled', not f.disabled,
        'Action', f.action,
        'Priority', f.priority
      ) as properties
    from
      gcp_compute_firewall f,
      gcp_compute_network n
    where
      f.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

edge "gcp_compute_network_to_compute_firewall_edge" {
  title = "firewall"

  sql = <<-EOQ
    select
      n.name as from_id,
      f.id::text as to_id
    from
      gcp_compute_firewall f,
      gcp_compute_network n
    where
      f.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

node "gcp_compute_network_to_compute_backend_service_node" {
  category = category.gcp_compute_firewall

  sql = <<-EOQ
    select
      bs.id::text,
      bs.title,
      jsonb_build_object(
        'ID', bs.id,
        'Name', bs.name,
        'Enable CDN', bs.enable_cdn,
        'Protocol', bs.protocol,
        'Location', bs.location
      ) as properties
    from
      gcp_compute_backend_service bs,
      gcp_compute_network n
    where
      bs.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

edge "gcp_compute_network_to_compute_backend_service_edge" {
  title = "backend service"

  sql = <<-EOQ
    select
      n.name as from_id,
      bs.id::text as to_id
    from
      gcp_compute_backend_service bs,
      gcp_compute_network n
    where
      bs.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

node "gcp_compute_network_to_compute_router_node" {
  category = category.gcp_compute_router

  sql = <<-EOQ
    select
      r.id::text,
      r.title,
      jsonb_build_object(
        'ID', r.id,
        'Name', r.name,
        'Created Time', r.creation_timestamp,
        'Location', r.location
      ) as properties
    from
      gcp_compute_router r,
      gcp_compute_network n
    where
      r.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

edge "gcp_compute_network_to_compute_router_edge" {
  title = "router"

  sql = <<-EOQ
    select
      n.name as from_id,
      r.id::text as to_id
    from
      gcp_compute_router r,
      gcp_compute_network n
    where
      r.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

node "gcp_compute_network_to_sql_database_instance_node" {
  category = category.gcp_sql_database_instance

  sql = <<-EOQ
    select
      i.name as id,
      i.title,
      jsonb_build_object(
        'Name', i.name,
        'State', i.state,
        'Instance Type', i.instance_type,
        'Database Version', i.database_version,
        'KMS Key Name', i.kms_key_name,
        'Location', i.location
      ) as properties
    from
      gcp_sql_database_instance i,
      gcp_compute_network n
    where
      n.self_link like '%' || (i.ip_configuration ->> 'privateNetwork') || '%'
      and n.name = $1;
  EOQ

  param "name" {}
}

edge "gcp_compute_network_to_sql_database_instance_edge" {
  title = "database instance"

  sql = <<-EOQ
    select
      n.name as from_id,
      i.name as to_id
    from
      gcp_sql_database_instance i,
      gcp_compute_network n
    where
      n.self_link like '%' || (i.ip_configuration ->> 'privateNetwork') || '%'
      and n.name = $1;
  EOQ

  param "name" {}
}

query "gcp_compute_network_overview" {
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

query "gcp_compute_network_peering" {
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

query "gcp_compute_network_subnet" {
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
