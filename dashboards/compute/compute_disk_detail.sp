dashboard "compute_disk_detail" {

  title         = "GCP Compute Disk Detail"
  documentation = file("./dashboards/compute/docs/compute_disk_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "disk_id" {
    title = "Select a disk:"
    query = query.compute_disk_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.compute_disk_storage
      args = {
        id = self.input.disk_id.value
      }
    }

    card {
      width = 2
      query = query.compute_disk_status
      args = {
        id = self.input.disk_id.value
      }
    }

    card {
      width = 2
      query = query.compute_disk_type
      args = {
        id = self.input.disk_id.value
      }
    }

    card {
      width = 2
      query = query.compute_disk_encryption
      args = {
        id = self.input.disk_id.value
      }
    }

    card {
      width = 2
      query = query.compute_disk_attached_instances_count
      args = {
        id = self.input.disk_id.value
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
            gcp_compute_disk d,
            gcp_compute_instance i,
            jsonb_array_elements(disks) as disk
          where
            d.self_link = (disk ->> 'source')
            and d.id = $1;
        EOQ

        args = [self.input.disk_id.value]
      }

      with "compute_resource_policies" {
        sql = <<-EOQ
          select
            r.id as policy_id
          from
            gcp_compute_disk d,
            jsonb_array_elements_text(resource_policies) as rp,
            gcp_compute_resource_policy r
          where
            d.id = $1
            and rp = r.self_link;
        EOQ

        args = [self.input.disk_id.value]
      }

      with "kms_keys" {
        sql = <<-EOQ
          select
            k.name as key_name
          from
            gcp_compute_disk d,
            gcp_kms_key k
          where
            d.disk_encryption_key is not null
            and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/', 8) = k.name
            and d.id = $1;
        EOQ

        args = [self.input.disk_id.value]
      }

      with "to_disks" {
        sql = <<-EOQ
          select
            d.id::text as disk_id
          from
            gcp_compute_disk d
          where
            d.source_disk_id = $1;
        EOQ

        args = [self.input.disk_id.value]
      }

      with "from_disks" {
        sql = <<-EOQ
          select
            d.source_disk_id::text as disk_id
          from
            gcp_compute_disk d
          where
            d.id = $1;
        EOQ

        args = [self.input.disk_id.value]
      }

      nodes = [
        node.compute_disk,
        node.compute_disk_from_compute_disk,
        node.compute_disk_from_compute_image,
        node.compute_disk_from_compute_snapshot,
        node.compute_disk_to_compute_disk,
        node.compute_disk_to_compute_image,
        node.compute_disk_to_compute_snapshot,
        node.compute_instance,
        node.compute_resource_policy,
        node.kms_key
      ]

      edges = [
        edge.compute_disk_from_compute_disk,
        edge.compute_disk_from_compute_image,
        edge.compute_disk_from_compute_snapshot,
        edge.compute_disk_to_compute_disk,
        edge.compute_disk_to_compute_image,
        edge.compute_disk_to_compute_resource_policy,
        edge.compute_disk_to_compute_snapshot,
        edge.compute_disk_to_kms_key,
        edge.compute_instance_to_compute_disk
      ]

      args = {
        compute_disk_ids            = [self.input.disk_id.value]
        compute_instance_ids        = with.compute_instances.rows[*].instance_id
        compute_resource_policy_ids = with.compute_resource_policies.rows[*].policy_id
        from_disk_ids               = with.from_disks.rows[*].disk_id
        kms_key_names               = with.kms_keys.rows[*].key_name
        to_disk_ids                 = with.to_disks.rows[*].disk_id
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
        query = query.compute_disk_overview
        args = {
          id = self.input.disk_id.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.compute_disk_tags
        args = {
          id = self.input.disk_id.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Attached To"
        query = query.compute_disk_attached_instances
        args = {
          id = self.input.disk_id.value
        }

        column "Name" {
          href = "${dashboard.compute_instance_detail.url_path}?input.instance_id={{.'Instance ID' | @uri}}"
        }
      }

      table {
        title = "Encryption Details"
        query = query.compute_disk_encryption_status
        args = {
          id = self.input.disk_id.value
        }
      }
    }
  }

  container {

    width = 12

    chart {
      title = "Read Throughput (IOPS) - Last 7 Days"
      type  = "line"
      width = 6
      query = query.compute_disk_read_throughput
      args = {
        id = self.input.disk_id.value
      }
    }

    chart {
      title = "Write Throughput (IOPS) - Last 7 Days"
      type  = "line"
      width = 6
      query = query.compute_disk_write_throughput
      args = {
        id = self.input.disk_id.value
      }
    }

  }

}

query "compute_disk_input" {
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
      gcp_compute_disk
    order by
      title;
  EOQ
}

query "compute_disk_storage" {
  sql = <<-EOQ
    select
      'Storage (GB)' as label,
      sum(size_gb) as value
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

query "compute_disk_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(status) as value
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

query "compute_disk_type" {
  sql = <<-EOQ
    select
      'Type' as label,
      type_name as value
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

query "compute_disk_attached_instances_count" {
  sql = <<-EOQ
    select
      'Attached Instances' as label,
      case
        when users is null then 0
        else jsonb_array_length(users)
      end as value,
      case
        when jsonb_array_length(users) > 0 then 'ok'
        else 'alert'
      end as "type"
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

query "compute_disk_encryption" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      disk_encryption_key_type as value
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

query "compute_disk_attached_instances" {
  sql = <<-EOQ
    with disks as (
      select
        instance_selflink
      from
        gcp_compute_disk, jsonb_array_elements_text(users) as instance_selflink
      where
        id =$1
    )
    select
      i.name as "Name",
      i.id::text as "Instance ID",
      i.status as "Instance State"
    from
      disks as d
      left join gcp_compute_instance as i on i.self_link = d.instance_selflink;
  EOQ

  param "id" {}
}

query "compute_disk_encryption_status" {
  sql = <<-EOQ
    select
      case
        when disk_encryption_key_type = 'Google managed' then 'Google Managed'
        when disk_encryption_key_type = 'Customer managed' then 'Customer Managed'
        else 'Customer Supplied'
      end as "Encryption Type",
      disk_encryption_key ->> 'kmsKeyName' as "KMS Key"
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

## Graph - start

### Nodes -



### Edges -



## Graph - end

query "compute_disk_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      creation_timestamp as "Create Time",
      title as "Title",
      location as "Location",
      project as "Project ID"
    from
      gcp_compute_disk
    where
      id = $1
  EOQ

  param "id" {}
}

query "compute_disk_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_compute_disk
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

query "compute_disk_read_throughput" {
  sql = <<-EOQ
    select
      timestamp,
      (sum / 3600) as read_throughput_ops
    from
      gcp_compute_disk_metric_read_ops_hourly
    where
      timestamp >= current_date - interval '7 day'
      and name in (select name from gcp_compute_disk where id = $1)
    order by
      timestamp;
  EOQ

  param "id" {}
}

query "compute_disk_write_throughput" {
  sql = <<-EOQ
    select
      timestamp,
      (sum / 300) as write_throughput_ops
    from
      gcp_compute_disk_metric_write_ops
    where
      timestamp >= current_date - interval '7 day'
      and name in (select name from gcp_compute_disk where id = $1)
    order by
      timestamp;
  EOQ

  param "id" {}
}
