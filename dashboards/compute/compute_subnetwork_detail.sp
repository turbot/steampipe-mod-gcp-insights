dashboard "compute_subnetwork_detail" {

  title         = "GCP Compute Subnetwork Detail"
  documentation = file("./dashboards/compute/docs/compute_subnetwork_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "subnetwork_id" {
    title = "Select a subnetwork:"
    query = query.compute_subnetwork_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.compute_subnetwork_cidr_range
      args  = [self.input.subnetwork_id.value]
    }

    card {
      width = 2
      query = query.compute_subnetwork_purpose
      args  = [self.input.subnetwork_id.value]
    }

    card {
      width = 2
      query = query.compute_subnetwork_is_default
      args  = [self.input.subnetwork_id.value]
    }

    card {
      width = 2
      query = query.compute_subnetwork_flow_logs
      args  = [self.input.subnetwork_id.value]
    }

  }

  with "compute_addresses" {
    query = query.compute_subnetwork_compute_addresses
    args  = [self.input.subnetwork_id.value]
  }

  with "compute_forwarding_rules" {
    query = query.compute_subnetwork_compute_forwarding_rules
    args  = [self.input.subnetwork_id.value]
  }

  with "compute_instance_groups" {
    query = query.compute_subnetwork_compute_instance_groups
    args  = [self.input.subnetwork_id.value]
  }

  with "compute_instance_templates" {
    query = query.compute_subnetwork_compute_instance_templates
    args  = [self.input.subnetwork_id.value]
  }

  with "compute_instances" {
    query = query.compute_subnetwork_compute_instances
    args  = [self.input.subnetwork_id.value]
  }

  with "compute_networks" {
    query = query.compute_subnetwork_compute_networks
    args  = [self.input.subnetwork_id.value]
  }

  with "kubernetes_clusters" {
    query = query.compute_subnetwork_kubernetes_clusters
    args  = [self.input.subnetwork_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.compute_address
        args = {
          compute_address_ids = with.compute_addresses.rows[*].address_id
        }
      }

      node {
        base = node.compute_forwarding_rule
        args = {
          compute_forwarding_rule_ids = with.compute_forwarding_rules.rows[*].rule_id
        }
      }

      node {
        base = node.compute_instance
        args = {
          compute_instance_ids = with.compute_instances.rows[*].instance_id
        }
      }

      node {
        base = node.compute_instance_group
        args = {
          compute_instance_group_ids = with.compute_instance_groups.rows[*].group_id
        }
      }

      node {
        base = node.compute_instance_template
        args = {
          compute_instance_template_ids = with.compute_instance_templates.rows[*].template_id
        }
      }

      node {
        base = node.compute_network
        args = {
          compute_network_names = with.compute_networks.rows[*].network_name
        }
      }

      node {
        base = node.compute_subnetwork
        args = {
          compute_subnetwork_ids = [self.input.subnetwork_id.value]
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_names = with.kubernetes_clusters.rows[*].cluster_name
        }
      }

      edge {
        base = edge.compute_network_to_compute_subnetwork
        args = {
          compute_network_names = with.compute_networks.rows[*].network_name
        }
      }

      edge {
        base = edge.compute_subnetwork_to_compute_address
        args = {
          compute_subnetwork_ids = [self.input.subnetwork_id.value]
        }
      }

      edge {
        base = edge.compute_subnetwork_to_compute_forwarding_rule
        args = {
          compute_subnetwork_ids = [self.input.subnetwork_id.value]
        }
      }

      edge {
        base = edge.compute_subnetwork_to_compute_instance
        args = {
          compute_subnetwork_ids = [self.input.subnetwork_id.value]
        }
      }

      edge {
        base = edge.compute_subnetwork_to_compute_instance_group
        args = {
          compute_subnetwork_ids = [self.input.subnetwork_id.value]
        }
      }

      edge {
        base = edge.compute_subnetwork_to_compute_instance_template
        args = {
          compute_subnetwork_ids = [self.input.subnetwork_id.value]
        }
      }

      edge {
        base = edge.compute_subnetwork_to_kubernetes_cluster
        args = {
          compute_subnetwork_ids = [self.input.subnetwork_id.value]
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
        query = query.compute_subnetwork_overview
        args  = [self.input.subnetwork_id.value]
      }

    }

    container {

      table {
        title = "Network Details"
        query = query.compute_subnetwork_network
        args  = [self.input.subnetwork_id.value]
      }

    }

  }

}

# Input queries

query "compute_subnetwork_input" {
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

# Card queries

query "compute_subnetwork_purpose" {
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

query "compute_subnetwork_cidr_range" {
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

query "compute_subnetwork_is_default" {
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

query "compute_subnetwork_flow_logs" {
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

# With queries

query "compute_subnetwork_compute_addresses" {
  sql = <<-EOQ
    select
      a.id::text as address_id
    from
      gcp_compute_address a,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link = a.subnetwork

    union

    select
      a.id::text as address_id
    from
      gcp_compute_global_address a,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link = a.subnetwork;
  EOQ
}

query "compute_subnetwork_compute_forwarding_rules" {
  sql = <<-EOQ
    select
      r.id::text as rule_id
    from
      gcp_compute_forwarding_rule r,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and split_part(r.subnetwork, 'subnetworks/', 2) = s.name

    union

    select
      r.id::text as rule_id
    from
      gcp_compute_global_forwarding_rule r,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and split_part(r.subnetwork, 'subnetworks/', 2) = s.name;
  EOQ
}

query "compute_subnetwork_compute_instance_groups" {
  sql = <<-EOQ
    select
      g.id::text as group_id
    from
      gcp_compute_instance_group g,
      gcp_compute_subnetwork s
    where
      g.subnetwork = s.self_link
      and s.id = $1;
  EOQ
}

query "compute_subnetwork_compute_instance_templates" {
  sql = <<-EOQ
    select
      t.id::text as template_id
    from
      gcp_compute_instance_template t,
      jsonb_array_elements(instance_network_interfaces) ni,
      gcp_compute_subnetwork s
    where
      ni ->> 'subnetwork' = s.self_link
      and s.id = $1;
  EOQ
}

query "compute_subnetwork_compute_instances" {
  sql = <<-EOQ
    select
      i.id::text as instance_id
    from
      gcp_compute_instance i,
      gcp_compute_subnetwork s,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'subnetwork' = s.self_link
      and s.id = $1;
  EOQ
}

query "compute_subnetwork_compute_networks" {
  sql = <<-EOQ
    select
      n.name as network_name
    from
      gcp_compute_subnetwork s,
      gcp_compute_network n
    where
      s.network = n.self_link
      and s.id = $1;
  EOQ
}

query "compute_subnetwork_kubernetes_clusters" {
  sql = <<-EOQ
    select
      c.name as cluster_name
    from
      gcp_kubernetes_cluster c,
      gcp_compute_subnetwork s
    where
      s.id = $1
      and s.self_link like '%' || (c.network_config ->> 'subnetwork') || '%';
  EOQ
}

# Other queries

query "compute_subnetwork_overview" {
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

query "compute_subnetwork_network" {
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
