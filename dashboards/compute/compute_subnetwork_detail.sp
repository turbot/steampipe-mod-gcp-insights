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
        node.gcp_compute_subnetwork_from_compute_network_node,
        node.gcp_compute_subnetwork_node_from_compute_instance_node,
        node.gcp_compute_subnetwork_node_from_compute_instance_group_node,
        node.gcp_compute_subnetwork_node_from_compute_instance_template_node,
        node.gcp_compute_subnetwork_node_from_kubernetes_cluster_node,
        node.gcp_compute_subnetwork_node_from_compute_address_node,
        node.gcp_compute_subnetwork_node_from_compute_forwarding_rule_node,
      ]

      edges = [
        edge.gcp_compute_subnetwork_from_compute_network_edge,
        edge.gcp_compute_subnetwork_node_from_compute_instance_edge,
        edge.gcp_compute_subnetwork_node_from_compute_instance_group_edge,
        edge.gcp_compute_subnetwork_node_from_compute_instance_template_edge,
        edge.gcp_compute_subnetwork_node_from_kubernetes_cluster_edge,
        edge.gcp_compute_subnetwork_node_from_compute_address_edge,
        edge.gcp_compute_subnetwork_node_from_compute_forwarding_rule_edge
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

    }

    container {

      table {
        title = "Network Details"
        query = query.gcp_compute_subnetwork_network
        args = {
          id = self.input.subnetwork_id.value
        }
      }

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

category "gcp_compute_subnetwork" {
  color = "orange"
  icon  = "heroicons-solid:share"
}

node "gcp_compute_subnetwork_node" {
  category = category.gcp_compute_subnetwork

  sql = <<-EOQ
    select
      s.id::text as id,
      s.title,
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

node "gcp_compute_subnetwork_from_compute_network_node" {
  category = category.gcp_compute_network

  sql = <<-EOQ
    select
      n.id::text,
      n.title,
      jsonb_build_object(
        'ID', n.id,
        'Name', n.name,
        'Created Time', n.creation_timestamp
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

edge "gcp_compute_subnetwork_from_compute_network_edge" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      s.id::text as to_id
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
        'ID', i.id::text,
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
  title = "compute instance"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      i.id::text as to_id
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

node "gcp_compute_subnetwork_node_from_compute_instance_group_node" {
  category = category.gcp_compute_instance_group

  sql = <<-EOQ
    select
      g.id::text,
      g.title,
      jsonb_build_object(
        'ID', g.id::text,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Instance Count', g.size,
        'Named Ports', g.named_ports
      ) as properties
    from
      gcp_compute_instance_group g,
      gcp_compute_subnetwork s
    where
      g.subnetwork = s.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_subnetwork_node_from_compute_instance_group_edge" {
  title = "compute instance group"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      g.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_subnetwork s
    where
      g.subnetwork = s.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_subnetwork_node_from_compute_instance_template_node" {
  category = category.gcp_compute_instance_template

  sql = <<-EOQ
    select
      t.id::text,
      t.title,
      jsonb_build_object(
        'ID', t.id,
        'Name', t.name,
        'Created Time', t.creation_timestamp,
        'Location', t.location
      ) as properties
    from
      gcp_compute_instance_template t,
      jsonb_array_elements(instance_network_interfaces) ni,
      gcp_compute_subnetwork s
    where
      ni ->> 'subnetwork' = s.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_subnetwork_node_from_compute_instance_template_edge" {
  title = "compute instance template"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      t.id::text as to_id
    from
      gcp_compute_instance_template t,
      jsonb_array_elements(instance_network_interfaces) ni,
      gcp_compute_subnetwork s
    where
      ni ->> 'subnetwork' = s.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_subnetwork_node_from_kubernetes_cluster_node" {
  category = category.gcp_kubernetes_cluster

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
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ

  param "id" {}
}

edge "gcp_compute_subnetwork_node_from_kubernetes_cluster_edge" {
  title = "kubernetes cluster"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      c.name as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ

  param "id" {}
}

node "gcp_compute_subnetwork_node_from_compute_address_node" {
  category = category.gcp_compute_address

  sql = <<-EOQ
    select
      a.id::text,
      a.title,
      jsonb_build_object(
        'ID', a.id,
        'Created Time', a.creation_timestamp,
        'Address', a.address,
        'Address Type', a.address_type,
        'Purpose', a.purpose,
        'Status', a.status
      ) as properties
    from
      gcp_compute_address a,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link = a.subnetwork
    
    union

    select
      a.id::text,
      a.title,
      jsonb_build_object(
        'ID', a.id,
        'Created Time', a.creation_timestamp,
        'Address', a.address,
        'Address Type', a.address_type,
        'Purpose', a.purpose,
        'Status', a.status
      ) as properties
    from
      gcp_compute_global_address a,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link = a.subnetwork;
  EOQ

  param "id" {}
}

edge "gcp_compute_subnetwork_node_from_compute_address_edge" {
  title = "compute address"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      a.id::text as to_id
    from
      gcp_compute_address a,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link = a.subnetwork

    union

    select
      s.id::text as from_id,
      a.id::text as to_id
    from
      gcp_compute_global_address a,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link = a.subnetwork;
  EOQ

  param "id" {}
}

node "gcp_compute_subnetwork_node_from_compute_forwarding_rule_node" {
  category = category.gcp_compute_forwarding_rule

  sql = <<-EOQ
    select
      r.id::text,
      r.title,
      jsonb_build_object(
        'ID', r.id::text,
        'Created Time', r.creation_timestamp,
        'IP Address', r.ip_address,
        'Global Access', r.allow_global_access,
        'Load Balancing Scheme', r.load_balancing_scheme,
        'Network Tier', r.network_tier
      ) as properties
    from
      gcp_compute_forwarding_rule r,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and split_part(r.subnetwork, 'subnetworks/', 2) = s.name

    union

    select
      r.id::text,
      r.title,
      jsonb_build_object(
        'ID', r.id::text,
        'Created Time', r.creation_timestamp,
        'IP Address', r.ip_address,
        'Global Access', r.allow_global_access,
        'Load Balancing Scheme', r.load_balancing_scheme,
        'Network Tier', r.network_tier
      ) as properties
    from
      gcp_compute_global_forwarding_rule r,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and split_part(r.subnetwork, 'subnetworks/', 2) = s.name;
  EOQ

  param "id" {}
}

edge "gcp_compute_subnetwork_node_from_compute_forwarding_rule_edge" {
  title = "forwarding rule"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      r.id::text as to_id
    from
      gcp_compute_forwarding_rule r,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and split_part(r.subnetwork, 'subnetworks/', 2) = s.name

    union

    select
      s.id::text as from_id,
      r.id::text as to_id
    from
      gcp_compute_global_forwarding_rule r,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and split_part(r.subnetwork, 'subnetworks/', 2) = s.name;
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

query "gcp_compute_subnetwork_network" {
  sql = <<-EOQ
    select
      n.name as "Name",
      n.id as "ID",
      n.creation_timestamp as "Creation Time",
      n.description as "Description",
      n.auto_create_subnetworks as "Auto Create Subnetworks",
      n.ipv4_range as "IPv4 Range",
      n.mtu as "MTU (Bytes)",
      n.routing_mode as "Routing Mode"
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and s.id = $1;
  EOQ

  param "id" {}
}
