dashboard "gcp_compute_instance_group_detail" {

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
      title = "Relationships"
      type  = "graph"

      with "instances" {
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

        args = [self.input.group_id.value]
      }

      with "networks" {
        sql = <<-EOQ
          select
            n.name as network_name
          from
            gcp_compute_instance_group g
              left join gcp_compute_subnetwork s 
              on g.subnetwork = s.self_link,
            gcp_compute_network n
          where
            g.network = n.self_link
            and g.id = $1;
        EOQ

        args = [self.input.group_id.value]
      }

      with "subnets" {
        sql = <<-EOQ
          select
            s.id::text as subnet_id
          from
            gcp_compute_instance_group g,
            gcp_compute_subnetwork s
          where
            g.subnetwork = s.self_link
            and g.id = $1;
        EOQ

        args = [self.input.group_id.value]
      }

      with "kube_clusters" {
        sql = <<-EOQ
          select
            c.name as cluster_name
          from
            gcp_kubernetes_cluster c,
            gcp_compute_instance_group g,
            jsonb_array_elements_text(instance_group_urls) ig
          where
            split_part(ig, 'instanceGroupManagers/', 2) = g.name
            and g.id = $1;
        EOQ

        args = [self.input.group_id.value]
      }

      nodes = [
        node.gcp_compute_instance_group_nodes,
        node.gcp_compute_instance_nodes,
        node.gcp_compute_subnetwork_nodes,
        node.gcp_compute_network_nodes,
        node.gcp_kubernetes_cluster_nodes,


        node.gcp_compute_instance_group_to_compute_autoscaler_nodes,
        node.gcp_compute_instance_group_to_compute_firewall_nodes,
        node.gcp_compute_instance_group_from_compute_backend_service_nodes
      ]

      edges = [
        edge.gcp_compute_subnetwork_to_compute_network_edges,
        edge.gcp_compute_instance_group_to_compute_instance_edges,
        edge.gcp_compute_instance_group_from_kubernetes_cluster_edges,
        edge.gcp_compute_instance_group_to_compute_subnetwork_edges,

        edge.gcp_compute_instance_group_to_compute_autoscaler_edges,
        edge.gcp_compute_instance_group_to_compute_firewall_edges,
        edge.gcp_compute_instance_group_from_compute_backend_service_edges,
      ]

      args = {
        id                 = self.input.group_id.value
        instance_group_ids = [self.input.group_id.value]
        instance_ids       = with.instances.rows[*].instance_id
        network_names      = with.networks.rows[*].network_name
        cluster_names      = with.kube_clusters.rows[*].cluster_name
        subnet_ids         = with.subnets.rows[*].subnet_id
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

  container {

    container {
      width = 4

      table {
        title = "Network Detail"
        query = query.gcp_compute_instance_group_network_detail
        args = {
          id = self.input.group_id.value
        }
      }

    }

    container {
      width = 8

      table {
        title = "Firewall Details"
        query = query.gcp_compute_instance_firewall_detail
        args = {
          id = self.input.group_id.value
        }
      }

    }
  }


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

## Graph - start

node "gcp_compute_instance_group_nodes" {
  category = category.gcp_compute_instance_group

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
      id = any($1);
  EOQ

  param "instance_group_ids" {}
}

node "gcp_compute_instance_group_compute_network_to_compute_subnetwork_nodes" {
  category = category.gcp_compute_subnetwork

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
      gcp_compute_instance_group g,
      gcp_compute_subnetwork s
    where
      g.subnetwork = s.self_link
      and g.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_group_to_compute_autoscaler_nodes" {
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

node "gcp_compute_instance_group_to_compute_firewall_nodes" {
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

node "gcp_compute_instance_group_from_compute_backend_service_nodes" {
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

// Edges :

edge "gcp_compute_instance_group_to_compute_instance_edges" {
  title = "manages"

  sql = <<-EOQ
    select
      instance_group_ids as from_id,
      instance_ids as to_id
    from
      unnest($1::text[]) as instance_group_ids,
      unnest($2::text[]) as instance_ids;
  EOQ

  param "instance_group_ids" {}
  param "instance_ids" {}
}

// edge "gcp_compute_instance_group_to_compute_network_edges" {
//   title = "network"

//   sql = <<-EOQ
//     select
//       instance_group_id as from_id,
//       network_name as to_id
//     from
//       unnest($1::text[]) as instance_group_id,
//       unnest($2::text[]) as network_name;
//   EOQ

//   param "instance_group_ids" {}
//   param "network_names" {}
// }

edge "gcp_compute_instance_group_to_compute_subnetwork_edges" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      instance_group_ids as from_id,
      subnet_ids as to_id
    from
      unnest($1::text[]) as instance_group_ids,
      unnest($2::text[]) as subnet_ids;
  EOQ

  param "instance_group_ids" {}
  param "subnet_ids" {}
}

edge "gcp_compute_instance_group_from_kubernetes_cluster_edges" {
  title = "instance group"

  sql = <<-EOQ
    select
      cluster_names as from_id,
      instance_group_ids as to_id
    from
      unnest($1::text[]) as cluster_names,
      unnest($2::text[]) as instance_group_ids;
  EOQ

  param "cluster_names" {}
  param "instance_group_ids" {}
}

edge "gcp_compute_instance_group_to_compute_autoscaler_edges" {
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

edge "gcp_compute_instance_group_to_compute_firewall_edges" {
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

edge "gcp_compute_instance_group_from_compute_backend_service_edges" {
  title = "instance group"

  sql = <<-EOQ
    select
      bs.id::text as from_id,
      g.id::text as to_id
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

## Graph - end

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

query "gcp_compute_instance_group_network_detail" {
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

  param "id" {}
}

query "gcp_compute_instance_firewall_detail" {
  sql = <<-EOQ
    select
      f.id as "ID",
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

  param "id" {}
}
