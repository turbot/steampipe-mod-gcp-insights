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

      with "compute_backend_services" {
        sql = <<-EOQ
          select
            bs.id::text as service_id
          from
            gcp_compute_backend_service bs,
            gcp_compute_network n
          where
            bs.network = n.self_link
            and n.name = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      with "compute_firewalls" {
        sql = <<-EOQ
          select
            f.id::text as firewall_id
          from
            gcp_compute_firewall f,
            gcp_compute_network n
          where
            f.network = n.self_link
            and n.name = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      with "compute_forwarding_rules" {
        sql = <<-EOQ
          select
            fr.id::text as rule_id
          from
            gcp_compute_forwarding_rule fr,
            gcp_compute_network n
          where
            split_part(fr.network, 'networks/', 2) = $1

          union

          select
            fr.id::text as rule_id
          from
            gcp_compute_global_forwarding_rule fr,
            gcp_compute_network n
          where
            split_part(fr.network, 'networks/', 2) = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      with "compute_instances" {
        sql = <<-EOQ
          select
            i.id::text as instance_id
          from
            gcp_compute_instance i,
            gcp_compute_network n,
            jsonb_array_elements(network_interfaces) as ni
          where
            n.self_link = ni ->> 'network'
            and n.name = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      with "compute_routers" {
        sql = <<-EOQ
          select
            r.id::text as router_id
          from
            gcp_compute_router r,
            gcp_compute_network n
          where
            r.network = n.self_link
            and n.name = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      with "compute_subnetworks" {
        sql = <<-EOQ
          select
            s.id as subnetwork_id
          from
            gcp_compute_subnetwork s,
            gcp_compute_network n
          where
            s.network = n.self_link
            and n.name = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      with "compute_vpn_gateways" {
        sql = <<-EOQ
          select
            g.id::text as gateway_id
          from
            gcp_compute_vpn_gateway g,
            gcp_compute_network n
          where
            g.network = n.self_link
            and n.name = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      with "dns_policies" {
        sql = <<-EOQ
          select
            p.id::text as policy_id
          from
            gcp_dns_policy p,
            jsonb_array_elements(p.networks) pn,
            gcp_compute_network n
          where
            pn ->> 'networkUrl' = n.self_link
            and n.name = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      with "kubernetes_clusters" {
        sql = <<-EOQ
          select
            c.name as cluster_name
          from
            gcp_kubernetes_cluster c
          where
            c.network = $1;
            
        EOQ

        args = [self.input.network_name.value]
      }

      with "sql_database_instances" {
        sql = <<-EOQ
          select
            i.name as instance_id
          from
            gcp_sql_database_instance i,
            gcp_compute_network n
          where
            n.self_link like '%' || (i.ip_configuration ->> 'privateNetwork') || '%'
            and n.name = $1;
        EOQ

        args = [self.input.network_name.value]
      }

      nodes = [
        node.compute_backend_service,
        node.compute_firewall,
        node.compute_forwarding_rule,
        node.compute_instance,
        node.compute_network,
        node.compute_router,
        node.compute_subnetwork,
        node.compute_vpn_gateway,
        node.dns_policy,
        node.kubernetes_cluster,
        node.sql_database_instance
      ]

      edges = [
        edge.compute_network_to_compute_backend_service,
        edge.compute_network_to_compute_firewall,
        edge.compute_network_to_compute_forwarding_rule,
        edge.compute_network_to_compute_instance,
        edge.compute_network_to_compute_router,
        edge.compute_network_to_compute_subnetwork,
        edge.compute_network_to_dns_policy,
        edge.compute_network_to_kubernetes_cluster,
        edge.compute_vpn_gateway_to_compute_network,
        edge.compute_network_to_sql_database_instance
      ]

      args = {
        compute_network_names       = [self.input.network_name.value]
        compute_backend_service_id  = with.compute_backend_services.rows[*].service_id
        compute_firewall_ids        = with.compute_firewalls.rows[*].firewall_id
        compute_forwarding_rule_ids = with.compute_forwarding_rules.rows[*].rule_id
        compute_instance_ids        = with.compute_instances.rows[*].instance_id
        compute_router_ids          = with.compute_routers.rows[*].router_id
        compute_subnetwork_ids      = with.compute_subnetworks.rows[*].subnetwork_id
        compute_vpn_gateway_ids     = with.compute_vpn_gateways.rows[*].gateway_id
        kubernetes_cluster_names    = with.kubernetes_clusters.rows[*].cluster_name
        sql_database_instance_ids   = with.sql_database_instances.rows[*].instance_id
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
