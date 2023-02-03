dashboard "compute_instance_group_detail" {

  title         = "GCP Compute Instance Group Detail"
  documentation = file("./dashboards/compute/docs/compute_instance_group_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "group_id" {
    title = "Select an instance group:"
    query = query.compute_instance_group_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.compute_instance_group_size
      args  = [self.input.group_id.value]
    }

  }

  with "compute_backend_services_for_compute_instance_group" {
    query = query.compute_backend_services_for_compute_instance_group
    args  = [self.input.group_id.value]
  }

  with "kubernetes_clusters_for_compute_instance_group" {
    query = query.kubernetes_clusters_for_compute_instance_group
    args  = [self.input.group_id.value]
  }

  with "compute_autoscalers_for_compute_instance_group" {
    query = query.compute_autoscalers_for_compute_instance_group
    args  = [self.input.group_id.value]
  }

  with "compute_firewalls_for_compute_instance_group" {
    query = query.compute_firewalls_for_compute_instance_group
    args  = [self.input.group_id.value]
  }

  with "compute_instances_for_compute_instance_group" {
    query = query.compute_instances_for_compute_instance_group
    args  = [self.input.group_id.value]
  }

  with "compute_networks_for_compute_instance_group" {
    query = query.compute_networks_for_compute_instance_group
    args  = [self.input.group_id.value]
  }

  with "compute_subnets_for_compute_instance_group" {
    query = query.compute_subnets_for_compute_instance_group
    args  = [self.input.group_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.compute_autoscaler
        args = {
          compute_autoscaler_ids = with.compute_autoscalers_for_compute_instance_group.rows[*].autoscaler_id
        }
      }

      node {
        base = node.compute_backend_service
        args = {
          compute_backend_service_ids = with.compute_backend_services_for_compute_instance_group.rows[*].service_id
        }
      }

      node {
        base = node.compute_firewall
        args = {
          compute_firewall_ids = with.compute_firewalls_for_compute_instance_group.rows[*].firewall_id
        }
      }

      node {
        base = node.compute_instance
        args = {
          compute_instance_ids = with.compute_instances_for_compute_instance_group.rows[*].instance_id
        }
      }

      node {
        base = node.compute_instance_group
        args = {
          compute_instance_group_ids = [self.input.group_id.value]
        }
      }

      node {
        base = node.compute_network
        args = {
          compute_network_ids = with.compute_networks_for_compute_instance_group.rows[*].network_id
        }
      }

      node {
        base = node.compute_subnetwork
        args = {
          compute_subnetwork_ids = with.compute_subnets_for_compute_instance_group.rows[*].subnetwork_id
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters_for_compute_instance_group.rows[*].cluster_id
        }
      }

      edge {
        base = edge.compute_backend_service_to_compute_instance_group
        args = {
          compute_backend_service_ids = with.compute_backend_services_for_compute_instance_group.rows[*].service_id
        }
      }

      edge {
        base = edge.compute_instance_group_to_compute_autoscaler
        args = {
          compute_instance_group_ids = [self.input.group_id.value]
        }
      }

      edge {
        base = edge.compute_instance_group_to_compute_firewall
        args = {
          compute_instance_group_ids = [self.input.group_id.value]
        }
      }

      edge {
        base = edge.compute_instance_group_to_compute_instance
        args = {
          compute_instance_group_ids = [self.input.group_id.value]
        }
      }

      edge {
        base = edge.compute_instance_group_to_compute_network
        args = {
          compute_instance_group_ids = [self.input.group_id.value]
        }
      }

      edge {
        base = edge.compute_instance_group_to_compute_subnetwork
        args = {
          compute_instance_group_ids = [self.input.group_id.value]
        }
      }

      edge {
        base = edge.compute_subnetwork_to_compute_network
        args = {
          compute_subnetwork_ids = with.compute_subnets_for_compute_instance_group.rows[*].subnetwork_id
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_compute_instance_group
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters_for_compute_instance_group.rows[*].cluster_id
        }
      }
    }
  }

  container {

    container {
      width = 4

      table {
        title = "Overview"
        type  = "line"
        query = query.compute_instance_group_overview
        args  = [self.input.group_id.value]

      }
    }

    container {
      width = 8

      table {
        title = "Attached Instances"
        query = query.compute_instance_group_attached_instances
        args  = [self.input.group_id.value]
      }
    }

  }

  container {

    container {
      width = 4

      table {
        title = "Network Detail"
        query = query.compute_instance_group_network_detail
        args  = [self.input.group_id.value]
      }

    }

    container {
      width = 8

      table {
        title = "Firewall Details"
        query = query.compute_instance_firewall_detail
        args  = [self.input.group_id.value]
      }

    }
  }

}

# Input queries

query "compute_instance_group_input" {
  sql = <<-EOQ
    select
      name as label,
      id::text as value,
      json_build_object(
        'location', location,
        'project', project,
        'id', id::text
      ) as tags
    from
      gcp_compute_instance_group
    order by
      name;
  EOQ
}

# Card queries

query "compute_instance_group_size" {
  sql = <<-EOQ
    select
      'Size' as label,
      size as value
    from
      gcp_compute_instance_group
    where
      id = $1;
  EOQ
}

# With queries

query "compute_backend_services_for_compute_instance_group" {
  sql = <<-EOQ
    select
      bs.id::text as service_id
    from
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b
    where
      b ->> 'group' = g.self_link
      and g.id = $1;
  EOQ
}

query "kubernetes_clusters_for_compute_instance_group" {
  sql = <<-EOQ
    select
      c.id::text as cluster_id
    from
      gcp_kubernetes_cluster c,
      gcp_compute_instance_group g,
      jsonb_array_elements_text(instance_group_urls) ig
    where
      split_part(ig, 'instanceGroupManagers/', 2) = g.name
      and g.id = $1;
  EOQ
}

query "compute_autoscalers_for_compute_instance_group" {
  sql = <<-EOQ
    select
      a.id::text as autoscaler_id
    from
      gcp_compute_instance_group g,
      gcp_compute_autoscaler a
    where
      g.name = split_part(a.target, 'instanceGroupManagers/', 2)
      and g.id = $1;
  EOQ
}

query "compute_firewalls_for_compute_instance_group" {
  sql = <<-EOQ
    select
      f.id::text as firewall_id
    from
      gcp_compute_instance_group g,
      gcp_compute_firewall f
    where
      g.network = f.network
      and g.id = $1;
  EOQ
}

query "compute_instances_for_compute_instance_group" {
  sql = <<-EOQ
    select
      i.id::text as instance_id
    from
      gcp_compute_instance as i,
      gcp_compute_instance_group as g,
      jsonb_array_elements(instances) as ins
    where
      g.id = $1
      and (ins ->> 'instance') = i.self_link;
  EOQ
}

query "compute_networks_for_compute_instance_group" {
  sql = <<-EOQ
    select
      n.id::text as network_id
    from
      gcp_compute_instance_group g
        left join gcp_compute_subnetwork s
        on g.subnetwork = s.self_link,
      gcp_compute_network n
    where
      g.network = n.self_link
      and g.id = $1;
  EOQ
}

query "compute_subnets_for_compute_instance_group" {
  sql = <<-EOQ
    select
      s.id::text as subnetwork_id
    from
      gcp_compute_instance_group g,
      gcp_compute_subnetwork s
    where
      g.subnetwork = s.self_link
      and g.id = $1;
  EOQ
}

# Other queries
query "compute_instance_group_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id::text as "ID",
      creation_timestamp as "Create Time",
      description as "Description",
      title as "Title",
      location as "Location",
      project as "Project"
    from
      gcp_compute_instance_group
    where
      id = $1;
  EOQ
}

query "compute_instance_group_attached_instances" {
  sql = <<-EOQ
    select
      i.id::text as "ID",
      i.name as "Name",
      i.creation_timestamp as "Create Time",
      i.cpu_platform as "CPU Platform",
      i.status as "Status"
    from
      gcp_compute_instance_group g,
      jsonb_array_elements(instances) as ins,
      gcp_compute_instance i
    where
      g.id = $1
      and i.self_link = ins ->> 'instance';
  EOQ
}

query "compute_instance_group_network_detail" {
  sql = <<-EOQ
    select
      n.name as "Network",
      s.name as "Subnetwork",
      s.gateway_address as "Subnet Gateway",
      s.ip_cidr_range::text as "IP CIDR Range"
    from
      gcp_compute_instance_group g,
      gcp_compute_network n,
      gcp_compute_subnetwork s
    where
      g.network = n.self_link
      and g.subnetwork = s.self_link
      and g.id = $1;
  EOQ
}

query "compute_instance_firewall_detail" {
  sql = <<-EOQ
    select
      f.id::text as "ID",
      f.name as "Name",
      f.direction as "Direction",
      not f.disabled as "Enabled",
      f.action as "Action",
      f.priority as "Priority"
    from
      gcp_compute_instance_group g,
      gcp_compute_firewall f
    where
      g.network = f.network
      and g.id = $1;
  EOQ
}
