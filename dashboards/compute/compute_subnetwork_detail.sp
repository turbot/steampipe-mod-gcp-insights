dashboard "gcp_compute_subnetwork_detail" {

  title         = "GCP Compute Subnetwork Detail"
  documentation = file("./dashboards/compute/docs/compute_subnetwork_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "subnetwork_id" {
    title = "Select a subnetwork:"
    query = query.gcp_compute_subnetwork_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_compute_subnetwork_cidr_range
      args = {
        id = self.input.subnetwork_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_subnetwork_purpose
      args = {
        id = self.input.subnetwork_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_subnetwork_is_default
      args = {
        id = self.input.subnetwork_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_subnetwork_flow_logs
      args = {
        id = self.input.subnetwork_id.value
      }
    }

  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"


      nodes = [
        node.gcp_compute_subnetwork_node,
        node.gcp_compute_subnetwork_to_compute_network_node,
        node.gcp_compute_subnetwork_node_from_compute_instance_node
      ]

      edges = [
        edge.gcp_compute_subnetwork_to_compute_network_edge,
        edge.gcp_compute_subnetwork_node_from_compute_instance_edge
      ]

      args = {
        id = self.input.subnetwork_id.value
      }
    }
  }

  container {

    container {

      table {
        title = "Overview"
        width = 4
        type  = "line"
        query = query.gcp_compute_subnetwork_overview
        args = {
          id = self.input.subnetwork_id.value
        }
      }

      # table {
      #   title = "Peering Details"
      #   width = 8
      #   query = query.gcp_compute_subnetwork_peering
      #   args = {
      #     id = self.input.subnetwork_id.value
      #   }
      # }

    }

    container {

      # table {
      #   title = "Subnet Details"
      #   query = query.gcp_compute_subnetwork_subnet
      #   args = {
      #     id = self.input.subnetwork_id.value
      #   }
      # }

    }

  }

}

query "gcp_compute_subnetwork_input" {
  sql = <<-EOQ
    select
      name as label,
      id::text as value,
      json_build_object(
        'location', location,
        'project', project,
        'id', id
      ) as tags
    from
      gcp_compute_subnetwork
    order by
      title;
  EOQ
}

query "gcp_compute_subnetwork_purpose" {
  sql = <<-EOQ
    select
      purpose as "Purpose"
    from
      gcp_compute_subnetwork
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_subnetwork_cidr_range" {
  sql = <<-EOQ
    select
      ip_cidr_range::text as "CIDR Range"
    from
      gcp_compute_subnetwork
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_subnetwork_is_default" {
  sql = <<-EOQ
    select
      'Default Subnetwork' as label,
      case when name <> 'default' then 'Disabled' else 'Enabled' end as value,
      case when name <> 'default' then 'ok' else 'alert' end as type
    from
      gcp_compute_subnetwork
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_subnetwork_flow_logs" {
  sql = <<-EOQ
    select
      'Flow Logs' as label,
      case when enable_flow_logs then 'Enabled' else 'Disabled' end as value,
      case when enable_flow_logs then 'ok' else 'alert' end as type
    from
      gcp_compute_subnetwork
    where
      id = $1;
  EOQ

  param "id" {}
}

category "gcp_compute_subnetwork_no_link" {}

node "gcp_compute_subnetwork_node" {
  category = category.gcp_compute_subnetwork_no_link

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
      gcp_compute_subnetwork s
    where
      s.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_subnetwork_to_compute_network_node" {
  category = category.gcp_compute_network

  sql = <<-EOQ
    select
      n.id::text as id,
      n.name as title,
      jsonb_build_object(
        'ID', n.id,
        'Name', n.name,
        'Created Time', n.creation_timestamp,
        'Location', n.location
      ) as properties
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_subnetwork_to_compute_network_edge" {
  title = "network"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      n.id::text as to_id
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_subnetwork_node_from_compute_instance_node" {
  category = category.gcp_compute_instance

  sql = <<-EOQ
    select
      i.id::text,
      i.title,
      jsonb_build_object(
        'ID', i.id,
        'Name', i.name,
        'Created Time', i.creation_timestamp,
        'CPU Platform', cpu_platform
      ) as properties
    from
      gcp_compute_instance i,
      gcp_compute_subnetwork s,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'subnetwork' = s.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_subnetwork_node_from_compute_instance_edge" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      s.id::text as to_id
    from
      gcp_compute_instance i,
      gcp_compute_subnetwork s,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'subnetwork' = s.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_subnetwork_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      creation_timestamp as "Creation Time",
      network_name as "Network",
      location as "Location",
      project as "Project"
    from
      gcp_compute_subnetwork
    where
      id = $1;
  EOQ

  param "id" {}
}

# query "gcp_compute_subnetwork_subnet" {
#   sql = <<-EOQ
#     select
#       name as "Name",
#       id as "ID",
#       creation_timestamp as "Creation Time",
#       enable_flow_logs as "Enable Flow Logs",
#       log_config_enable as "Log Config Enabled",
#       gateway_address as "Gateway Address",
#       ip_cidr_range as "IPv4 CIDR Range",
#       ipv6_cidr_range as "IPv6 CIDR Range",
#       private_ip_google_access as "Private IPv4 Google Access",
#       private_ipv6_google_access as "Private IPv6 Google Access"
#     from
#       gcp_compute_subnetwork
#     where
#       subnetwork_id = $1;
#   EOQ

#   param "id" {}
# }
