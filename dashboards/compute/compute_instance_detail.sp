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
      args  = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_instance_type
      args  = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_instance_deletion_protection
      args  = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_instance_public_access
      args  = {
        id = self.input.instance_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_instance_confidential_vm_service
      args  = {
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
        args  = {
          id = self.input.instance_id.value
        }
      }
    }
    container {
      width = 6

      table {
        title = "Attached Disks"
        query = query.gcp_compute_instance_attached_disks
        args  = {
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
      args  = {
        id = self.input.instance_id.value
      }
    }

  }

  container {
    width = 6

    table {
      title = "Shielded VM Configuration"
      query = query.gcp_compute_instance_shielded_vm
      args  = {
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
