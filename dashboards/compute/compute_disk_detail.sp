dashboard "gcp_compute_disk_detail" {

  title         = "GCP Compute Disk Detail"
  documentation = file("./dashboards/compute/docs/compute_disk_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "disk_id" {
    title = "Select a disk:"
    sql   = query.gcp_compute_disk_input.sql
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_compute_disk_storage
      args  = {
        id = self.input.disk_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_disk_status
      args  = {
        id = self.input.disk_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_disk_type
      args  = {
        id = self.input.disk_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_disk_encryption
      args  = {
        id = self.input.disk_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_disk_attached_instances_count
      args  = {
        id = self.input.disk_id.value
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
        query = query.gcp_compute_disk_overview
        args  = {
          id = self.input.disk_id.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_compute_disk_tags
        args  = {
          id = self.input.disk_id.value
        }
      }
    }

    container {

      width = 6

    #   table {
    #     title = "Attached To"
    #     query = query.gcp_compute_disk_attached_instances
    #     args  = {
    #       id = self.input.disk_id.value
    #     }

    #     column "Instance ARN" {
    #       display = "none"
    #     }

    #     column "Instance ID" {
    #       href = "${dashboard.aws_ec2_instance_detail.url_path}?input.instance_id={{.'Instance ARN' | @uri}}"
    #     }
    #   }

    #   table {
    #     title = "Encryption Details"
    #     column "KMS Key ID" {
    #       href = "${dashboard.aws_kms_key_detail.url_path}?input.key_id={{.'KMS Key ID' | @uri}}"
    #     }
    #     query = query.gcp_compute_disk_encryption_status
    #     args  = {
    #       id = self.input.disk_id.value
    #     }
    #   }
    }
  }

  container {

    width = 12

    chart {
      title = "Read Throughput (IOPS) - Last 7 Days"
      type  = "line"
      width = 6
      query = query.gcp_compute_disk_read_throughput
      args  = {
        id = self.input.disk_id.value
      }
    }

    chart {
      title = "Write Throughput (IOPS) - Last 7 Days"
      type  = "line"
      width = 6
      query = query.gcp_compute_disk_write_throughput
      args  = {
        id = self.input.disk_id.value
      }
    }

  }

}

query "gcp_compute_disk_input" {
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

query "gcp_compute_disk_storage" {
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

query "gcp_compute_disk_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      status as value
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_disk_type" {
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

query "gcp_compute_disk_state" {
  sql = <<-EOQ
    select
      'State' as label,
      state as value
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_disk_attached_instances_count" {
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

query "gcp_compute_disk_encryption" {
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

query "gcp_compute_disk_attached_instances" {
  sql = <<-EOQ
    select
      i.instance_id as "Instance ID",
      i.Tags ->> 'Name' as "Name",
      i.id as "Instance ARN",
      i.instance_state as "Instance State",
      attachment ->> 'AttachTime' as "Attachment Time",
      (attachment ->> 'DeleteOnTermination')::boolean as "Delete on Termination"
    from
      gcp_compute_disk as v,
      jsonb_array_elements(attachments) as attachment,
      aws_ec2_instance as i
    where
      i.instance_id = attachment ->> 'InstanceId'
      and v.id = $1
    order by
      i.instance_id;
  EOQ

  param "id" {}
}

query "gcp_compute_disk_encryption_status" {
  sql = <<-EOQ
    select
      case when encrypted then 'Enabled' else 'Disabled' end as "Encryption",
      kms_key_id as "KMS Key ID"
    from
      gcp_compute_disk
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_disk_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      creation_timestamp as "Creation Timestamp",
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

query "gcp_compute_disk_tags" {
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

query "gcp_compute_disk_read_throughput" {
  sql = <<-EOQ
    select
      timestamp,
      (sum / 3600) as read_throughput_ops
    from
      gcp_compute_disk_metric_read_ops_hourly
    where
      timestamp >= current_date - interval '7 day'
      and id = reverse(split_part(reverse($1), '/', 1))
    order by 
      timestamp;
  EOQ

  param "id" {}
}

query "gcp_compute_disk_write_throughput" {
  sql = <<-EOQ
    select
      timestamp,
      (sum / 300) as write_throughput_ops
    from
      gcp_compute_disk_metric_write_ops
    where
      timestamp >= current_date - interval '7 day'
      and id = reverse(split_part(reverse($1), '/', 1))
    order by 
      timestamp;
  EOQ

  param "id" {}
}