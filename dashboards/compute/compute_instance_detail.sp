dashboard "gcp_compute_instance_detail" {

  title         = "GCP Compute Instance Detail"
  documentation = file("./dashboards/compute/docs/compute_instance_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "instance_id" {
    title = "Select an instance:"
    query = query.gcp_compute_instance_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_compute_instance_status
      args = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_instance_type
      args = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_instance_deletion_protection
      args = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_instance_public_access
      args = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_instance_confidential_vm_service
      args = {
        id = self.input.instance_id.value
      }
    }
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"


      nodes = [
        node.gcp_compute_instance_node,
        node.gcp_compute_instance_to_compute_disk_node,
        node.gcp_compute_instance_subnetwork_to_compute_network_node,
        node.gcp_compute_instance_to_compute_subnetwork_node,
        node.gcp_compute_instance_from_compute_instance_group_node,
        node.gcp_compute_instance_to_compute_firewall_node
      ]

      edges = [
        edge.gcp_compute_instance_to_compute_disk_edge,
        edge.gcp_compute_instance_subnetwork_to_compute_network_edge,
        edge.gcp_compute_instance_to_compute_subnetwork_edge,
        edge.gcp_compute_instance_from_compute_instance_group_edge,
        edge.gcp_compute_instance_to_compute_firewall_edge
      ]

      args = {
        id = self.input.instance_id.value
      }
    }
  }

  container {

    container {
      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.gcp_compute_instance_overview
        args = {
          id = self.input.instance_id.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_compute_instance_tags
        args = {
          id = self.input.instance_id.value
        }
      }
    }
    container {
      width = 6

      table {
        title = "Attached Disks"
        query = query.gcp_compute_instance_attached_disks
        args = {
          id = self.input.instance_id.value
        }
      }
    }

  }

  container {
    width = 12

    table {
      title = "Network Interfaces"
      query = query.gcp_compute_instance_network_interfaces
      args = {
        id = self.input.instance_id.value
      }
    }

  }

  container {
    width = 6

    table {
      title = "Shielded VM Configuration"
      query = query.gcp_compute_instance_shielded_vm
      args = {
        id = self.input.instance_id.value
      }
    }

  }

}

query "gcp_compute_instance_input" {
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
      gcp_compute_instance
    order by
      name;
  EOQ
}

query "gcp_compute_instance_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(status) as value
    from
      gcp_compute_instance
    where
      id = $1;
  EOQ

  param "id" {}

}

query "gcp_compute_instance_type" {
  sql = <<-EOQ
    select
      'Type' as label,
      machine_type_name as value
    from
      gcp_compute_instance
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_instance_deletion_protection" {
  sql = <<-EOQ
    select
      'Deletion Protection' as label,
      case when deletion_protection then 'Enabled' else 'Disabled' end as value,
      case when deletion_protection then 'ok' else 'alert' end as type
    from
      gcp_compute_instance
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_instance_public_access" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case
        when d ->> 'natIP' is not null then 'Enabled'
        else 'Disabled'
      end as value,
      case 
        when d ->> 'natIP' is not null then 'alert'
        else 'ok'
      end as type
    from
      gcp_compute_instance,
      jsonb_array_elements(network_interfaces) nic,
      jsonb_array_elements(nic -> 'accessConfigs') d
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_instance_confidential_vm_service" {
  sql = <<-EOQ
    select
      'Confidential VM' as label,
      case when confidential_instance_config <> '{}' then 'Enabled' else 'Disabled' end as value,
      case when confidential_instance_config <> '{}' then 'ok' else 'alert' end as type
    from
      gcp_compute_instance
    where
      id = $1;
  EOQ

  param "id" {}
}

## Graph

category "gcp_compute_instance" {
  color = "orange"
  icon  = "heroicons-outline:cpu-chip"
}

node "gcp_compute_instance_node" {
  category = category.gcp_compute_instance

  sql = <<-EOQ
    select
      id::text,
      title,
      jsonb_build_object(
        'ID', id,
        'Name', name,
        'Created Time', creation_timestamp,
        'CPU Platform', cpu_platform,
        'Status', status
      ) as properties
    from
      gcp_compute_instance
    where
      id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_to_compute_disk_node" {
  category = category.gcp_compute_disk

  sql = <<-EOQ
    select
      d.id::text,
      d.title,
      jsonb_build_object(
        'ID', d.id::text,
        'Auto Delete', disk ->> 'autoDelete',
        'Created Time', d.creation_timestamp,
        'Size(GB)', disk ->> 'diskSizeGb',
        'Mode', disk ->> 'mode'
      ) as properties
    from
      gcp_compute_instance i,
      gcp_compute_disk d,
      jsonb_array_elements(disks) as disk
    where
      i.id = $1
      and d.self_link = (disk ->> 'source');
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_to_compute_disk_edge" {
  title = "mounts"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      d.id::text as to_id
    from
      gcp_compute_instance i,
      gcp_compute_disk d,
      jsonb_array_elements(disks) as disk
    where
      i.id = $1
      and d.self_link = (disk ->> 'source');
  EOQ

  param "id" {}
}

node "gcp_compute_instance_subnetwork_to_compute_network_node" {
  category = category.gcp_compute_network

  sql = <<-EOQ
    select
      n.id::text as id,
      n.title,
      jsonb_build_object(
        'ID', n.id,
        'Name', n.name,
        'Created Time', n.creation_timestamp
      ) as properties
    from
      gcp_compute_instance i,
      gcp_compute_network n,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'network' = n.self_link
      and i.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_subnetwork_to_compute_network_edge" {
  title = "network"

  sql = <<-EOQ
    select
      s.id::text as from_id,
      n.id::text as to_id
    from
      gcp_compute_instance i,
      gcp_compute_network n,
      gcp_compute_subnetwork s,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'network' = n.self_link
      and ni ->> 'subnetwork' = s.self_link
      and i.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_to_compute_subnetwork_node" {
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
      gcp_compute_instance i,
      gcp_compute_subnetwork s,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'subnetwork' = s.self_link
      and i.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_to_compute_subnetwork_edge" {
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
      and i.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_from_compute_instance_group_node" {
  category = category.gcp_compute_instance_group

  sql = <<-EOQ
    select
      g.id::text as id,
      g.title,
      jsonb_build_object(
        'ID', g.id::text,
        'Name', g.name,
        'Created Time', g.creation_timestamp,
        'Instance Count', g.size,
        'Named Ports', g.named_ports
      ) as properties
    from
      gcp_compute_instance as ins,
      gcp_compute_instance_group as g,
      jsonb_array_elements(instances) as i
    where
      (i ->> 'instance') = ins.self_link
      and ins.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_from_compute_instance_group_edge" {
  title = "manages"

  sql = <<-EOQ
    select
      g.id::text as from_id,
      ins.id::text as to_id
    from
      gcp_compute_instance as ins,
      gcp_compute_instance_group as g,
      jsonb_array_elements(instances) as i
    where
      (i ->> 'instance') = ins.self_link
      and ins.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_instance_to_compute_firewall_node" {
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
      gcp_compute_instance i,
      gcp_compute_firewall f,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'network' = f.network
      and i.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_instance_to_compute_firewall_edge" {
  title = "firewall"

  sql = <<-EOQ
    select
      i.id::text as from_id,
      f.id::text as to_id
    from
      gcp_compute_instance i,
      gcp_compute_firewall f,
      jsonb_array_elements(network_interfaces) as ni
    where
      ni ->> 'network' = f.network
      and i.id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_instance_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      creation_timestamp as "Create Time",
      title as "Title",
      location as "Location",
      project as "Project"
    from
      gcp_compute_instance
    where
      id = $1
  EOQ

  param "id" {}
}

query "gcp_compute_instance_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_compute_instance
      where
        id = $1
    )
    select
      key as "Key",
      value as "Value"
    from
      jsondata,
      json_each_text(tags)
    order by
      key;
    EOQ

  param "id" {}
}

query "gcp_compute_instance_attached_disks" {
  sql = <<-EOQ
    select
      d ->> 'deviceName' as "Device Name",
      d ->> 'diskSizeGb' as "Disk Size (GB)",
      d ->> 'interface' as "Interface",
      d ->> 'mode' as "Mode",
      d ->> 'boot' as "Boot",
      d ->> 'autoDelete' as "Auto-Delete"
    from
      gcp_compute_instance,
      jsonb_array_elements(disks) as d
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_instance_shielded_vm" {
  sql = <<-EOQ
    select
      case when (shielded_instance_config -> 'enableIntegrityMonitoring')::bool then 'Enabled' else 'Disabled' end as "Integrity Monitoring",
      case when (shielded_instance_config -> 'enableVtpm')::bool then 'Enabled' else 'Disabled' end "vTPM",
      case when (shielded_instance_config -> 'enableSecureBoot')::bool then 'Enabled' else 'Disabled' end "Secure Boot"
    from
      gcp_compute_instance
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_instance_network_interfaces" {
  sql = <<-EOQ
    select
      nic ->> 'name' as "Name",
      nic ->> 'networkIP' as "Internal IP",
      nic ->> 'stackType' as "Stack Type",
      ac ->> 'natIP' as "External IP",
      ac ->> 'networkTier' as "Network Tier",
      can_ip_forward as "IP Forwarding"
    from
      gcp_compute_instance,
      jsonb_array_elements(network_interfaces) as nic,
      jsonb_array_elements(nic -> 'accessConfigs') ac
    where
      id = $1;
  EOQ

  param "id" {}
}
