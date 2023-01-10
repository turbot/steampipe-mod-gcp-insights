dashboard "compute_network_detail" {

  title         = "GCP Compute Network Detail"
  documentation = file("./dashboards/compute/docs/compute_network_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "network_id" {
    title = "Select a network:"
    query = query.compute_network_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.compute_network_mtu
      args  = [self.input.network_id.value]
    }

    card {
      width = 2
      query = query.compute_network_routing_mode
      args  = [self.input.network_id.value]
    }

    card {
      width = 2
      query = query.compute_network_subnet_count
      args  = [self.input.network_id.value]
    }

    card {
      width = 2
      query = query.compute_network_is_default
      args  = [self.input.network_id.value]
    }

    card {
      width = 2
      query = query.network_firewall_rules_count
      args  = [self.input.network_id.value]
    }

    card {
      width = 2
      query = query.auto_create_subnetwork
      args  = [self.input.network_id.value]
    }
  }

  with "compute_vpn_gateways_from_compute_network_id" {
    query = query.compute_network_from_compute_vpn_gateways
    args  = [self.input.network_id.value]
  }

  with "compute_backend_services_from_compute_network_id" {
    query = query.compute_backend_services_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  with "compute_firewalls_from_compute_network_id" {
    query = query.compute_firewalls_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  with "compute_forwarding_rules_from_compute_network_id" {
    query = query.compute_forwarding_rules_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  with "compute_instances_from_compute_network_id" {
    query = query.compute_instances_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  with "compute_routers_from_compute_network_id" {
    query = query.compute_routers_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  with "compute_subnetworks_from_compute_network_id" {
    query = query.compute_subnetworks_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  with "dns_policies_from_compute_network_id" {
    query = query.dns_policies_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  with "kubernetes_clusters_from_compute_network_id" {
    query = query.kubernetes_clusters_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  with "sql_database_instances_from_compute_network_id" {
    query = query.sql_database_instances_from_compute_network_id
    args  = [self.input.network_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.compute_backend_service
        args = {
          compute_backend_service_ids = with.compute_backend_services_from_compute_network_id.rows[*].service_id
        }
      }

      node {
        base = node.compute_firewall
        args = {
          compute_firewall_ids = with.compute_firewalls_from_compute_network_id.rows[*].firewall_id
        }
      }

      node {
        base = node.compute_forwarding_rule
        args = {
          compute_forwarding_rule_ids = with.compute_forwarding_rules_from_compute_network_id.rows[*].rule_id
        }
      }

      node {
        base = node.compute_instance
        args = {
          compute_instance_ids = with.compute_instances_from_compute_network_id.rows[*].instance_id
        }
      }

      node {
        base = node.compute_network
        args = {
          compute_network_ids = [self.input.network_id.value]
        }
      }

      node {
        base = node.compute_router
        args = {
          compute_router_ids = with.compute_routers_from_compute_network_id.rows[*].router_id
        }
      }

      node {
        base = node.compute_subnetwork
        args = {
          compute_subnetwork_ids = with.compute_subnetworks_from_compute_network_id.rows[*].subnetwork_id
        }
      }

      node {
        base = node.compute_vpn_gateway
        args = {
          compute_vpn_gateway_ids = with.compute_network_from_compute_vpn_gateways.rows[*].gateway_id
        }
      }

      node {
        base = node.dns_policy
        args = {
          dns_policy_ids = with.dns_policies_from_compute_network_id.rows[*].policy_id
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters_from_compute_network_id.rows[*].cluster_id
        }
      }

      node {
        base = node.sql_database_instance
        args = {
          database_instance_self_links = with.sql_database_instances_from_compute_network_id.rows[*].self_link
        }
      }

      edge {
        base = edge.compute_network_to_compute_backend_service
        args = {
          compute_network_ids = [self.input.network_id.value]
        }
      }

      edge {
        base = edge.compute_network_to_compute_firewall
        args = {
          compute_network_ids = [self.input.network_id.value]
        }
      }

      edge {
        base = edge.compute_network_to_compute_forwarding_rule
        args = {
          compute_network_ids = [self.input.network_id.value]
        }
      }

      edge {
        base = edge.compute_subnetwork_to_compute_instance
        args = {
          compute_subnetwork_ids = with.compute_subnetworks_from_compute_network_id.rows[*].subnetwork_id
        }
      }

      edge {
        base = edge.compute_network_to_compute_router
        args = {
          compute_network_ids = [self.input.network_id.value]
        }
      }

      edge {
        base = edge.compute_network_to_compute_subnetwork
        args = {
          compute_network_ids = [self.input.network_id.value]
        }
      }

      edge {
        base = edge.compute_network_to_dns_policy
        args = {
          compute_network_ids = [self.input.network_id.value]
        }
      }

      edge {
        base = edge.compute_subnetwork_to_kubernetes_cluster
        args = {
          compute_subnetwork_ids = with.compute_subnetworks_from_compute_network_id.rows[*].subnetwork_id
        }
      }

      edge {
        base = edge.compute_network_to_sql_database_instance
        args = {
          compute_network_ids = [self.input.network_id.value]
        }
      }

      edge {
        base = edge.compute_vpn_gateway_to_compute_network
        args = {
          compute_vpn_gateway_ids = with.compute_network_from_compute_vpn_gateways.rows[*].gateway_id
        }
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
        args  = [self.input.network_id.value]
      }

      table {
        title = "Peering Details"
        width = 8
        query = query.compute_network_peering
        args  = [self.input.network_id.value]
      }

    }

    container {

      table {
        title = "Subnet Details"
        query = query.compute_network_subnet
        args  = [self.input.network_id.value]
      }

    }

  }
}

# Input queries

query "compute_network_input" {
  sql = <<-EOQ
    select
      name as label,
      id as value,
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

# Card queries

query "compute_network_mtu" {
  sql = <<-EOQ
    select
      'MTU (Bytes)' as label,
      mtu as value
    from
      gcp_compute_network
    where
      id = $1;
  EOQ
}

query "compute_network_subnet_count" {
  sql = <<-EOQ
    select
      'Subnets' as label,
      count(*) as value,
      case when count(*) > 0 then 'ok' else 'alert' end as type
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network_name = n.name
      and s.project = n.project
      and n.id = $1;
  EOQ
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
      id = $1;
  EOQ
}

query "compute_network_routing_mode" {
  sql = <<-EOQ
    select
      'Routing Mode' as label,
      routing_mode as value
    from
      gcp_compute_network
    where
      id = $1;
  EOQ
}

query "network_firewall_rules_count" {
  sql = <<-EOQ
    select
      'Firewall Rules' as label,
      count(f.*) as value,
      case when count(f.*) > 0 then 'ok' else 'alert' end as type
    from
      gcp_compute_firewall f,
      gcp_compute_network n
    where
      split_part(f.network, 'networks/', 2) = n.name
      and f.project = n.project
      and n.id = $1;
  EOQ
}

query "auto_create_subnetwork" {
  sql = <<-EOQ
    select
      'Auto Create Subnetwork' as label,
      case when auto_create_subnetworks then 'Enabled' else 'Disabled' end as value,
      case when auto_create_subnetworks and name = 'default' then 'ok' else 'alert' end as type
    from
      gcp_compute_network
    where
      id = $1;
  EOQ
}
# With queries

query "compute_network_from_compute_vpn_gateways" {
  sql = <<-EOQ
    select
      g.id::text as gateway_id
    from
      gcp_compute_ha_vpn_gateway g,
      gcp_compute_network n
    where
      g.network = n.self_link
      and n.id = $1;
  EOQ
}

query "compute_backend_services_from_compute_network_id" {
  sql = <<-EOQ
    select
      bs.id::text as service_id
    from
      gcp_compute_backend_service bs,
      gcp_compute_network n
    where
      bs.network = n.self_link
      and n.id = $1;
  EOQ
}

query "compute_firewalls_from_compute_network_id" {
  sql = <<-EOQ
    select
      f.id::text as firewall_id
    from
      gcp_compute_firewall f,
      gcp_compute_network n
    where
      f.network = n.self_link
      and n.id = $1;
  EOQ
}

query "compute_forwarding_rules_from_compute_network_id" {
  sql = <<-EOQ
    select
      fr.id::text as rule_id
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_network n
    where
      split_part(fr.network, 'networks/', 2) = n.name
      and fr.project = n.project
      and n.id = $1
    union

    select
      fr.id::text as rule_id
    from
      gcp_compute_global_forwarding_rule fr,
      gcp_compute_network n
    where
      split_part(fr.network, 'networks/', 2) = n.name
      and fr.project = n.project
      and n.id = $1
  EOQ
}

query "compute_instances_from_compute_network_id" {
  sql = <<-EOQ
    select
      i.id::text as instance_id
    from
      gcp_compute_instance i,
      gcp_compute_network n,
      jsonb_array_elements(network_interfaces) as ni
    where
      n.self_link = ni ->> 'network'
      and n.id = $1;
  EOQ
}

query "compute_routers_from_compute_network_id" {
  sql = <<-EOQ
    select
      r.id::text as router_id
    from
      gcp_compute_router r,
      gcp_compute_network n
    where
      r.network = n.self_link
      and n.id = $1;
  EOQ
}

query "compute_subnetworks_from_compute_network_id" {
  sql = <<-EOQ
    select
      s.id::text as subnetwork_id
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and n.id = $1;
  EOQ
}

query "dns_policies_from_compute_network_id" {
  sql = <<-EOQ
    select
      p.id::text as policy_id
    from
      gcp_dns_policy p,
      jsonb_array_elements(p.networks) pn,
      gcp_compute_network n
    where
      pn ->> 'networkUrl' = n.self_link
      and n.id = $1;
  EOQ
}

query "kubernetes_clusters_from_compute_network_id" {
  sql = <<-EOQ
    select
      c.id::text as cluster_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_network n
    where
      c.network = n.name
      and c.project = n.project
      and n.id = $1;
  EOQ
}

query "sql_database_instances_from_compute_network_id" {
  sql = <<-EOQ
    select
      i.self_link as self_link
    from
      gcp_sql_database_instance i,
      gcp_compute_network n
    where
      n.self_link like '%' || (i.ip_configuration ->> 'privateNetwork') || '%'
      and n.id = $1;
  EOQ
}

# Other queries
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
      id = $1;
  EOQ
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
      id = $1;
  EOQ
}

query "compute_network_subnet" {
  sql = <<-EOQ
    select
      s.name as "Name",
      s.id as "ID",
      s.creation_timestamp as "Creation Time",
      s.enable_flow_logs as "Enable Flow Logs",
      s.log_config_enable as "Log Config Enabled",
      s.gateway_address as "Gateway Address",
      s.ip_cidr_range as "IPv4 CIDR Range",
      s.ipv6_cidr_range as "IPv6 CIDR Range",
      s.private_ip_google_access as "Private IPv4 Google Access",
      s.private_ipv6_google_access as "Private IPv6 Google Access"
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network_name = n.name
      and s.project = n.project
      and n.id = $1;
  EOQ
}
