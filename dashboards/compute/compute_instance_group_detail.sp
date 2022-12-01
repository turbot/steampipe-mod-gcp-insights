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
      width = 2
      query = query.compute_instance_group_size
      args = {
        id = self.input.group_id.value
      }
    }

  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      with "compute_instances" {
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

      with "compute_networks" {
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

      with "compute_subnets" {
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

      with "kubernetes_clusters" {
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
        node.compute_instance_group,
        node.compute_instance,
        node.compute_subnetwork,
        node.compute_network,
        node.kubernetes_cluster,


        node.compute_instance_group_to_compute_autoscaler,
        node.compute_instance_group_to_compute_firewall,
        node.compute_instance_group_from_compute_backend_service
      ]

      edges = [
        edge.kubernetes_cluster_to_compute_instance_group,
        edge.compute_subnetwork_to_compute_network,
        edge.compute_instance_group_to_compute_instance,
        edge.compute_instance_group_to_compute_subnetwork,

        edge.compute_instance_group_to_compute_autoscaler,
        edge.compute_instance_group_to_compute_firewall,
        edge.compute_instance_group_from_compute_backend_service,
      ]

      args = {
        id                         = self.input.group_id.value
        compute_instance_group_ids = [self.input.group_id.value]
        compute_instance_ids       = with.compute_instances.rows[*].instance_id
        compute_network_names      = with.compute_networks.rows[*].network_name
        kubernetes_cluster_names   = with.kubernetes_clusters.rows[*].cluster_name
        compute_subnet_ids         = with.compute_subnets.rows[*].subnet_id
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
        args = {
          id = self.input.group_id.value
        }

      }
    }

    container {
      width = 8

      table {
        title = "Attached Instances"
        query = query.compute_instance_group_attached_instances
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
        query = query.compute_instance_group_network_detail
        args = {
          id = self.input.group_id.value
        }
      }

    }

    container {
      width = 8

      table {
        title = "Firewall Details"
        query = query.compute_instance_firewall_detail
        args = {
          id = self.input.group_id.value
        }
      }

    }
  }


}

query "compute_instance_group_input" {
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

  param "id" {}

}

## Graph - start

// Edges :


## Graph - end

query "compute_instance_group_overview" {
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

query "compute_instance_group_attached_instances" {
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

  param "id" {}
}

query "compute_instance_firewall_detail" {
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
