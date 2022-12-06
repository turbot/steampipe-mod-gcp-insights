dashboard "compute_network_detail" {

  title         = "GCP Compute Network Detail"
  documentation = file("./dashboards/compute/docs/compute_network_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "network_name" {
    title = "Select a network:"
    query = query.compute_network_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.compute_network_mtu
      args = {
        name = self.input.network_name.value
      }
    }

    card {
      width = 2
      query = query.compute_network_subnet_count
      args = {
        name = self.input.network_name.value
      }
    }

    card {
      width = 2
      query = query.compute_network_is_default
      args = {
        name = self.input.network_name.value
      }
    }

    card {
      width = 2
      query = query.compute_network_routing_mode
      args = {
        name = self.input.network_name.value
      }
    }

    card {
      width = 2
      query = query.network_firewall_rules_count
      args = {
        name = self.input.network_name.value
      }
    }

    card {
      width = 2
      query = query.auto_create_subnetwork
      args = {
        name = self.input.network_name.value
      }
    }
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      nodes = [
        node.compute_network,
        node.compute_network_from_compute_vpn_gateway,
        node.compute_network_to_compute_subnetwork,
        node.compute_network_to_compute_firewall,
        node.compute_network_to_compute_backend_service,
        node.compute_network_to_compute_router,
        node.compute_network_to_sql_database_instance,
        node.compute_network_to_dns_policy,
        node.compute_network_to_kubernetes_cluster,
        node.compute_network_to_compute_instances,
        node.compute_network_to_compute_forwarding_rule
      ]

      edges = [
        edge.compute_network_from_compute_vpn_gateway,
        edge.compute_network_to_compute_subnetwork,
        edge.compute_network_to_compute_firewall,
        edge.compute_network_to_compute_backend_service,
        edge.compute_network_to_compute_router,
        edge.compute_network_to_sql_database_instance,
        edge.compute_network_to_dns_policy,
        edge.compute_network_to_kubernetes_cluster,
        edge.compute_network_to_compute_instances,
        edge.compute_network_to_compute_forwarding_rule
      ]

      args = {
        name                  = self.input.network_name.value
        compute_network_names = [self.input.network_name.value]
      }
    }
  }

  container {

    container {

      table {
        title = "Overview"
        width = 4
        type  = "line"
        query = query.compute_network_overview
        args = {
          name = self.input.network_name.value
        }
      }

      table {
        title = "Peering Details"
        width = 8
        query = query.compute_network_peering
        args = {
          name = self.input.network_name.value
        }
      }

    }

    container {

      table {
        title = "Subnet Details"
        query = query.compute_network_subnet
        args = {
          name = self.input.network_name.value
        }
      }

    }

  }

}

query "compute_network_input" {
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

query "compute_network_mtu" {
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

query "compute_network_subnet_count" {
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

query "compute_network_is_default" {
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

query "compute_network_routing_mode" {
  sql = <<-EOQ
    select
      'Routing Mode' as label,
      routing_mode as value
    from
      gcp_compute_network
    where
      name = $1;
  EOQ

  param "name" {}
}

query "network_firewall_rules_count" {
  sql = <<-EOQ
    select
      'Firewall Rules' as label,
      count(*) as value,
      case when count(*) > 0 then 'ok' else 'alert' end as type
    from
      gcp_compute_firewall
    where
      split_part(network, 'networks/', 2) = $1;
  EOQ

  param "name" {}
}

query "auto_create_subnetwork" {
  sql = <<-EOQ
    select
      'Auto Create Subnetwork' as label,
      case when auto_create_subnetworks then 'enabled' else 'disabled' end as value,
      case when name <> 'default' then 'ok' else 'alert' end as type
    from
      gcp_compute_network
    where
      name = $1;
  EOQ

  param "name" {}
}

node "compute_network" {
  category = category.compute_network

  sql = <<-EOQ
    select
      n.name as id,
      n.title,
      jsonb_build_object(
        'ID', n.id,
        'Name', n.name,
        'Created Time', n.creation_timestamp
      ) as properties
    from
      gcp_compute_network n
    where
      n.name = any($1);
  EOQ

  param "compute_network_names" {}
}

node "compute_network_to_compute_subnetwork" {
  category = category.compute_subnetwork

  sql = <<-EOQ
    select
      s.id::text as id,
      s.title,
      jsonb_build_object(
        'ID', s.id::text,
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

edge "compute_network_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      n.name as from_id,
      s.id::text as to_id
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

node "compute_network_to_compute_firewall" {
  category = category.compute_firewall

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

edge "compute_network_to_compute_firewall" {
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

node "compute_network_to_compute_backend_service" {
  category = category.compute_backend_service

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

edge "compute_network_to_compute_backend_service" {
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

node "compute_network_to_compute_router" {
  category = category.compute_router

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

edge "compute_network_to_compute_router" {
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

node "compute_network_to_sql_database_instance" {
  category = category.sql_database_instance

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

edge "compute_network_to_sql_database_instance" {
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

node "compute_network_from_compute_vpn_gateway" {
  category = category.compute_vpn_gateway

  sql = <<-EOQ
    select
      g.id::text,
      g.title,
      jsonb_build_object(
        'ID', g.id,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Location', g.location
      ) as properties
    from
      gcp_compute_vpn_gateway g,
      gcp_compute_network n
    where
      g.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

edge "compute_network_from_compute_vpn_gateway" {
  title = "network"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      n.name as to_id
    from
      gcp_compute_vpn_gateway g,
      gcp_compute_network n
    where
      g.network = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

node "compute_network_to_dns_policy" {
  category = category.dns_policy

  sql = <<-EOQ
    select
      p.id::text,
      p.title,
      jsonb_build_object(
        'ID', p.id,
        'Name', p.name,
        'Enable Logging', p.enable_logging,
        'Enable Inbound Forwarding', p.enable_inbound_forwarding,
        'Location', p.location
      ) as properties
    from
      gcp_dns_policy p,
      jsonb_array_elements(p.networks) pn,
      gcp_compute_network n
    where
      pn ->> 'networkUrl' = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

edge "compute_network_to_dns_policy" {
  title = "dns policy"

  sql = <<-EOQ
    select
      n.name as from_id,
      p.id::text as to_id
    from
      gcp_dns_policy p,
      jsonb_array_elements(p.networks) pn,
      gcp_compute_network n
    where
      pn ->> 'networkUrl' = n.self_link
      and n.name = $1;
  EOQ

  param "name" {}
}

node "compute_network_to_compute_instances" {
  category = category.compute_instance

  sql = <<-EOQ
    select
      i.id::text,
      i.title,
      jsonb_build_object(
        'ID', i.id,
        'Name', i.name,
        'Created Time', i.creation_timestamp,
        'CPU Platform', i.cpu_platform,
        'Status', i.status
      ) as properties
    from
      gcp_compute_instance i,
      gcp_compute_network n,
      jsonb_array_elements(network_interfaces) as ni
    where
      n.self_link = ni ->> 'network'
      and n.name = $1;
  EOQ

  param "name" {}
}

edge "compute_network_to_compute_instances" {
  title = "network"

  sql = <<-EOQ
    select
      i.id::text as to_id,
      n.name as from_id
    from
      gcp_compute_instance i,
      gcp_compute_network n,
      jsonb_array_elements(network_interfaces) as ni
    where
      n.self_link = ni ->> 'network'
      and n.name = $1;
  EOQ

  param "name" {}
}
node "compute_network_to_kubernetes_cluster" {
  category = category.kubernetes_cluster

  sql = <<-EOQ
    select
      c.name as id,
      c.title,
      jsonb_build_object(
        'Name', c.name,
        'Created Time', c.create_time,
        'Endpoint', c.endpoint,
        'Services IPv4 CIDR', c.services_ipv4_cidr,
        'Status', c.status
      ) as properties
      from
      gcp_kubernetes_cluster c,
      gcp_compute_network n
    where
      n.name = $1
      and n.name = c.network
  EOQ

  param "name" {}
}

edge "compute_network_to_kubernetes_cluster" {
  title = "network"

  sql = <<-EOQ
    select
      c.name as to_id,
      n.name as from_id
      from
      gcp_kubernetes_cluster c,
      gcp_compute_network n
    where
      n.name = $1
      and n.name = c.network
  EOQ

  param "name" {}
}

node "compute_network_to_compute_forwarding_rule" {
  category = category.compute_forwarding_rule

  sql = <<-EOQ
    select
      fr.id::text,
      fr.title,
      jsonb_build_object(
        'ID', fr.id::text,
        'IP Address', fr.ip_address,
        'Global Access', fr.allow_global_access,
        'Created Time', fr.creation_timestamp
      ) as properties
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_network n
    where
      split_part(fr.network, 'networks/', 2) = $1;
  EOQ

  param "name" {}
}

edge "compute_network_to_compute_forwarding_rule" {
  title = "forwarding rule"

  sql = <<-EOQ
    select
      n.name as from_id,
      fr.id::text as to_id
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_network n
    where
      split_part(fr.network, 'networks/', 2) = $1;
  EOQ

  param "name" {}
}

query "compute_network_overview" {
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

query "compute_network_peering" {
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

query "compute_network_subnet" {
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
