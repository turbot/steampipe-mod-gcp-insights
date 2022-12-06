dashboard "compute_instance_detail" {

  title         = "GCP Compute Instance Detail"
  documentation = file("./dashboards/compute/docs/compute_instance_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "instance_id" {
    title = "Select an instance:"
    query = query.compute_instance_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.compute_instance_status
      args = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.compute_instance_type
      args = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.compute_instance_deletion_protection
      args = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.compute_instance_public_access
      args = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.compute_instance_confidential_vm_service
      args = {
        id = self.input.instance_id.value
      }
    }
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      with "compute_instance_groups" {
        sql = <<-EOQ
          select
            g.id::text as group_id
          from
            gcp_compute_instance as ins,
            gcp_compute_instance_group as g,
            jsonb_array_elements(instances) as i
          where
            (i ->> 'instance') = ins.self_link
            and ins.id = $1;
        EOQ

        args = [self.input.instance_id.value]
      }

      with "compute_disks" {
        sql = <<-EOQ
          select
            d.id::text as disk_id
          from
            gcp_compute_instance i,
            gcp_compute_disk d,
            jsonb_array_elements(disks) as disk
          where
            d.self_link = (disk ->> 'source')
            and i.id = $1;
        EOQ

        args = [self.input.instance_id.value]
      }

      with "compute_firewalls" {
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

        args = [self.input.instance_id.value]
      }

      with "compute_subnets" {
        sql = <<-EOQ
          select
            s.id::text as subnet_id
          from
            gcp_compute_instance i,
            gcp_compute_subnetwork s,
            jsonb_array_elements(network_interfaces) as ni
          where
            ni ->> 'subnetwork' = s.self_link
            and i.id = $1;
        EOQ

        args = [self.input.instance_id.value]
      }

      with "compute_networks" {
        sql = <<-EOQ
          select
            n.name as network_name
          from
            gcp_compute_instance i,
            gcp_compute_network n,
            jsonb_array_elements(network_interfaces) as ni
          where
            ni ->> 'network' = n.self_link
            and i.id = $1;
        EOQ

        args = [self.input.instance_id.value]
      }

      with "iam_service_accounts" {
        sql = <<-EOQ
          select
            s.name as account_name
          from
            gcp_compute_instance i,
            gcp_service_account s,
            jsonb_array_elements(service_accounts) as sa
          where
            sa ->> 'email' = s.email
            and i.id = $1;
        EOQ

        args = [self.input.instance_id.value]
      }

      nodes = [
        node.compute_disk,
        node.compute_firewall,
        node.compute_instance,
        node.compute_instance_group,
        node.compute_network,
        node.compute_subnetwork,
        node.service_account
      ]

      edges = [
        edge.compute_instance_group_to_compute_instance,
        edge.compute_subnetwork_to_compute_network,
        edge.compute_instance_to_compute_disk,
        edge.compute_instance_to_compute_subnetwork,
        edge.compute_instance_to_compute_firewall,
        edge.compute_instance_to_service_account
      ]

      args = {
        compute_disk_ids           = with.compute_disks.rows[*].disk_id
        compute_firewall_ids       = with.compute_firewalls.rows[*].firewall_id
        compute_instance_group_ids = with.compute_instance_groups.rows[*].group_id
        compute_instance_ids       = [self.input.instance_id.value]
        compute_network_names      = with.compute_networks.rows[*].network_name
        compute_subnet_ids         = with.compute_subnets.rows[*].subnet_id
        iam_service_account_names  = with.iam_service_accounts.rows[*].account_name
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
        query = query.compute_instance_overview
        args = {
          id = self.input.instance_id.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.compute_instance_tags
        args = {
          id = self.input.instance_id.value
        }
      }
    }
    container {
      width = 6

      table {
        title = "Attached Disks"
        query = query.compute_instance_attached_disks
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
      query = query.compute_instance_network_interfaces
      args = {
        id = self.input.instance_id.value
      }
    }

  }

  container {
    width = 6

    table {
      title = "Shielded VM Configuration"
      query = query.compute_instance_shielded_vm
      args = {
        id = self.input.instance_id.value
      }
    }

  }

}

query "compute_instance_input" {
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

query "compute_instance_status" {
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

query "compute_instance_type" {
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

query "compute_instance_deletion_protection" {
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

query "compute_instance_public_access" {
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

query "compute_instance_confidential_vm_service" {
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

query "compute_instance_overview" {
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

query "compute_instance_tags" {
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

query "compute_instance_attached_disks" {
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

query "compute_instance_shielded_vm" {
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

query "compute_instance_network_interfaces" {
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
