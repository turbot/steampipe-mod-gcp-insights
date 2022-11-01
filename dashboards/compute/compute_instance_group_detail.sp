dashboard "gcp_compute_group_instance_detail" {

  title         = "GCP Compute Instance Group Detail"
  documentation = file("./dashboards/compute/docs/compute_instance_group_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "group_id" {
    title = "Select an instance group:"
    query = query.gcp_compute_instance_group_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_compute_instance_group_size
      args = {
        id = self.input.group_id.value
      }
    }

  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"


      nodes = [
        node.gcp_compute_instance_group_node,
        node.gcp_compute_instance_group_to_compute_instance_node,
        node.gcp_compute_instance_group_to_compute_network_node,
        node.gcp_compute_instance_group_compute_network_to_compute_subnetwork_node,
        node.gcp_compute_instance_group_to_compute_autoscaler_node,
        node.gcp_compute_instance_group_to_compute_firewall_node,
        node.gcp_compute_instance_group_to_compute_backend_service_node,
        node.gcp_compute_instance_group_backend_to_health_check_node,
        node.gcp_compute_instance_group_backend_to_forwarding_rule_node
      ]

      edges = [
        edge.gcp_compute_instance_group_to_compute_instance_edge,
        edge.gcp_compute_instance_group_to_compute_network_edge,
        edge.gcp_compute_instance_group_compute_network_to_compute_subnetwork_edge,
        edge.gcp_compute_instance_group_to_compute_autoscaler_edge,
        edge.gcp_compute_instance_group_to_compute_firewall_edge,
        edge.gcp_compute_instance_group_to_compute_backend_service_edge,
        edge.gcp_compute_instance_group_backend_to_health_check_edge,
        edge.gcp_compute_instance_group_backend_to_forwarding_rule_edge
      ]

      args = {
        id = self.input.group_id.value
      }
    }
  }

  container {

    container {
      width = 4

      table {
        title = "Overview"
        type  = "line"
        query = query.gcp_compute_instance_group_overview
        args = {
          id = self.input.group_id.value
        }

      }
    }

    container {
      width = 8

      table {
        title = "Attached Instances"
        query = query.gcp_compute_instance_group_attached_instances
        args = {
          id = self.input.group_id.value
        }
      }
    }

  }

  # container {
  #   width = 12

  #   table {
  #     title = "Network Interfaces"
  #     query = query.gcp_compute_instance_group_network_interfaces
  #     args = {
  #       id = self.input.group_id.value
  #     }
  #   }

  # }

  # container {
  #   width = 6

  #   table {
  #     title = "Shielded VM Configuration"
  #     query = query.gcp_compute_instance_group_shielded_vm
  #     args = {
  #       id = self.input.group_id.value
  #     }
  #   }

  # }

}

query "gcp_compute_instance_group_input" {
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
      gcp_compute_instance_group
    order by
      name;
  EOQ
}

query "gcp_compute_instance_group_size" {
  sql = <<-EOQ
    select
      'Size' as label,
      size as value
    from
      gcp_compute_instance_group
    where
      id = $1;
  EOQ

  param "id" {}

}

## Graph

category "gcp_compute_instance_group_no_link" {
}

node "gcp_compute_instance_group_node" {
  category = category.gcp_compute_instance_group_no_link

  sql = <<-EOQ
    select
      id::text,
      title,
      jsonb_build_object(
        'ID', g.id,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Instance Count', g.size,
        'Named Ports', g.named_ports
      ) as properties
    from
      gcp_compute_instance_group g
    where
      id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_to_compute_instance_node" {
  category = category.gcp_compute_instance

  sql = <<-EOQ
    select
      i.id::text as id,
      i.title,
      jsonb_build_object(
        'ID', i.id,
        'Name', i.name,
        'Created Time', i.creation_timestamp,
        'CPU Platform', i.cpu_platform,
        'Status', i.status
      ) as properties
    from
      gcp_compute_instance as i,
      gcp_compute_instance_group as g,
      jsonb_array_elements(instances) as ins
    where
      g.id = $1
      and (ins ->> 'instance') = i.self_link;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_group_to_compute_instance_edge" {
  title = "instance"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      i.id::text as to_id
    from
      gcp_compute_instance as i,
      gcp_compute_instance_group as g,
      jsonb_array_elements(instances) as ins
    where
      g.id = $1
      and (ins ->> 'instance') = i.self_link;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_to_compute_network_node" {
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
      gcp_compute_instance_group g,
      gcp_compute_network n
    where
      g.network = n.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_group_to_compute_network_edge" {
  title = "network"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      n.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_network n
    where
      g.network = n.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_compute_network_to_compute_subnetwork_node" {
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
      gcp_compute_instance_group g,
      gcp_compute_subnetwork s
    where
      g.subnetwork = s.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_group_compute_network_to_compute_subnetwork_edge" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      n.id::text as from_id,
      s.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_network n,
      gcp_compute_subnetwork s
    where
      g.network = n.self_link
      and g.subnetwork = s.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_to_compute_autoscaler_node" {
  category = category.gcp_compute_autoscaler

  sql = <<-EOQ
    select
      a.id::text,
      a.title,
      jsonb_build_object(
        'ID', a.id,
        'Name', a.name,
        'Created Time', a.creation_timestamp,
        'Status', a.status,
        'Location', a.location
      ) as properties
    from
      gcp_compute_instance_group g,
      gcp_compute_autoscaler a
    where
      g.name = split_part(a.target, 'instanceGroupManagers/', 2)
      and g.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_group_to_compute_autoscaler_edge" {
  title = "autoscaler"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      a.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_autoscaler a
    where
      g.name = split_part(a.target, 'instanceGroupManagers/', 2)
      and g.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_to_compute_firewall_node" {
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
      gcp_compute_instance_group g,
      gcp_compute_firewall f
    where
      g.network = f.network
      and g.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_group_to_compute_firewall_edge" {
  title = "firewall"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      f.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_firewall f
    where
      g.network = f.network
      and g.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_to_compute_backend_service_node" {
  category = category.gcp_compute_backend_service

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
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b
    where
      b ->> 'group' = g.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_group_to_compute_backend_service_edge" {
  title = "backend"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      bs.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b
    where
      b ->> 'group' = g.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_backend_to_health_check_node" {
  category = category.gcp_compute_health_check

  sql = <<-EOQ
    select
      hc.id::text,
      hc.title,
      jsonb_build_object(
        'ID', hc.id,
        'Name', hc.name,
        'Type', hc.type,
        'Check Interval(Sec)', hc.check_interval_sec,
        'Healthy Threshold', hc.healthy_threshold,
        'Unhealthy Threshold', hc.unhealthy_threshold,
        'Timeout(Sec)', hc.timeout_sec
      ) as properties
    from
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b,
      jsonb_array_elements_text(bs.health_checks) bhc,
      gcp_compute_health_check hc
    where
      b ->> 'group' = g.self_link
      and bhc = hc.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_group_backend_to_health_check_edge" {
  title = "health check"

  sql = <<-EOQ
    select
      bs.id::text as from_id,
      hc.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b,
      jsonb_array_elements_text(bs.health_checks) bhc,
      gcp_compute_health_check hc
    where
      b ->> 'group' = g.self_link
      and bhc = hc.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_backend_to_forwarding_rule_node" {
  category = category.gcp_compute_forwarding_rule

  sql = <<-EOQ
    select
      fr.id::text,
      fr.title,
      jsonb_build_object(
        'ID', fr.id,
        'IP Address', fr.ip_address,
        'Global Access', fr.allow_global_access,
        'Created Time', fr.creation_timestamp
      ) as properties
    from
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b,
      gcp_compute_forwarding_rule fr
    where
      b ->> 'group' = g.self_link
      and split_part(bs.self_link, 'backendServices/', 2) = split_part(fr.backend_service, 'backendServices/', 2)
      and g.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_group_backend_to_forwarding_rule_edge" {
  title = "forwarding rule"

  sql = <<-EOQ
    select
      bs.id::text as from_id,
      fr.id::text as to_id
    from
      gcp_compute_instance_group g,
      gcp_compute_backend_service bs,
      jsonb_array_elements(bs.backends) b,
      gcp_compute_forwarding_rule fr
    where
      b ->> 'group' = g.self_link
      and split_part(bs.self_link, 'backendServices/', 2) = split_part(fr.backend_service, 'backendServices/', 2)
      and g.id = $1;
  EOQ

  param "id" {}
}


# node "gcp_compute_instance_group_to_compute_disk_node" {
#   category = category.gcp_compute_disk

#   sql = <<-EOQ
#     select
#       d.id::text,
#       disk ->> 'deviceName' as title,
#       jsonb_build_object(
#         'Name', disk ->> 'deviceName',
#         'Auto Delete', disk ->> 'autoDelete',
#         'Created Time', d.creation_timestamp,
#         'Size(GB)', disk ->> 'diskSizeGb',
#         'Mode', disk ->> 'mode'
#       ) as properties
#     from
#       gcp_compute_instance_group i,
#       gcp_compute_disk d,
#       jsonb_array_elements(disks) as disk
#     where
#       i.id = $1
#       and d.name = (disk ->> 'deviceName');
#   EOQ

#   param "id" {}
# }

# edge "gcp_compute_instance_group_to_compute_disk_edge" {
#   title = "attached"

#   sql = <<-EOQ
#     select
#       i.id::text as from_id,
#       d.id::text as to_id
#     from
#       gcp_compute_instance_group i,
#       gcp_compute_disk d,
#       jsonb_array_elements(disks) as disk
#     where
#       i.id = $1
#       and d.name = (disk ->> 'deviceName');
#   EOQ

#   param "id" {}
# }




# node "gcp_compute_instance_group_to_compute_machine_type_node" {
#   category = category.gcp_compute_machine_type

#   sql = <<-EOQ
#     select
#       m.id::text as id,
#       m.name as title,
#       jsonb_build_object(
#         'ID', m.id,
#         'Name', m.name,
#         'Created Time', m.creation_timestamp,
#         'Description', m.description
#       ) as properties
#     from
#       gcp_compute_instance_group as i,
#       gcp_compute_machine_type as m
#     where
#       m.name = i.machine_type_name
#       and i.id = $1;
#   EOQ

#   param "id" {}
# }

# edge "gcp_compute_instance_group_to_compute_machine_type_edge" {
#   title = "machine type"

#   sql = <<-EOQ
#     select
#       i.id::text as from_id,
#       m.id::text as to_id
#     from
#       gcp_compute_instance_group as i,
#       gcp_compute_machine_type as m
#     where
#       m.name = i.machine_type_name
#       and i.id = $1;
#   EOQ

#   param "id" {}
# }

query "gcp_compute_instance_group_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
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

  param "id" {}
}

query "gcp_compute_instance_group_attached_instances" {
  sql = <<-EOQ
    select
      i.id as "ID",
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

  param "id" {}
}
