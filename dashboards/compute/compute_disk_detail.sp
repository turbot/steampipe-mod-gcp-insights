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
      args  = [self.input.disk_id.value]
    }

    card {
      width = 2
      query = query.compute_disk_status
      args  = [self.input.disk_id.value]
    }

    card {
      width = 2
      query = query.compute_disk_type
      args  = [self.input.disk_id.value]
    }

    card {
      width = 2
      query = query.compute_disk_encryption
      args  = [self.input.disk_id.value]
    }

    card {
      width = 2
      query = query.compute_disk_attached_instances_count
      args  = [self.input.disk_id.value]
    }

  }

  with "source_compute_disks_for_compute_disk" {
    query = query.source_compute_disks_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  with "target_compute_disks_for_compute_disk" {
    query = query.target_compute_disks_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  with "source_compute_images_for_compute_disk" {
    query = query.source_compute_images_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  with "target_compute_images_for_compute_disk" {
    query = query.target_compute_images_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  with "compute_instances_for_compute_disk" {
    query = query.compute_instances_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  with "compute_resource_policies_for_compute_disk" {
    query = query.compute_resource_policies_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  with "source_compute_snapshots_for_compute_disk" {
    query = query.source_compute_snapshots_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  with "target_compute_snapshots_for_compute_disk" {
    query = query.target_compute_snapshots_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  with "kms_keys_for_compute_disk" {
    query = query.kms_keys_for_compute_disk
    args  = [self.input.disk_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.compute_disk
        args = {
          compute_disk_ids = [self.input.disk_id.value]
        }
      }

      node {
        base = node.compute_disk
        args = {
          compute_disk_ids = with.source_compute_disks_for_compute_disk.rows[*].disk_id
        }
      }

      node {
        base = node.compute_disk
        args = {
          compute_disk_ids = with.target_compute_disks_for_compute_disk.rows[*].disk_id
        }
      }

      node {
        base = node.compute_image
        args = {
          compute_image_ids = with.source_compute_images_for_compute_disk.rows[*].image_id
        }
      }

      node {
        base = node.compute_image
        args = {
          compute_image_ids = with.target_compute_images_for_compute_disk.rows[*].image_id
        }
      }

      node {
        base = node.compute_instance
        args = {
          compute_instance_ids = with.compute_instances_for_compute_disk.rows[*].instance_id
        }
      }

      node {
        base = node.compute_snapshot
        args = {
          compute_snapshot_names = with.source_compute_snapshots_for_compute_disk.rows[*].snapshot_name
        }
      }

      node {
        base = node.compute_snapshot
        args = {
          compute_snapshot_names = with.target_compute_snapshots_for_compute_disk.rows[*].snapshot_name
        }
      }

      node {
        base = node.compute_resource_policy
        args = {
          compute_resource_policy_ids = with.compute_resource_policies_for_compute_disk.rows[*].policy_id
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = with.kms_keys_for_compute_disk.rows[*].self_link
        }
      }

      edge {
        base = edge.compute_disk_to_compute_disk
        args = {
          compute_disk_ids = with.source_compute_disks_for_compute_disk.rows[*].disk_id
        }
      }

      edge {
        base = edge.compute_disk_to_compute_disk
        args = {
          compute_disk_ids = [self.input.disk_id.value]
        }
      }

      edge {
        base = edge.compute_disk_to_compute_image
        args = {
          compute_disk_ids = [self.input.disk_id.value]
        }
      }

      edge {
        base = edge.compute_disk_to_compute_resource_policy
        args = {
          compute_disk_ids = [self.input.disk_id.value]
        }
      }

      edge {
        base = edge.compute_disk_to_compute_snapshot
        args = {
          compute_disk_ids = [self.input.disk_id.value]
        }
      }

      edge {
        base = edge.compute_disk_to_kms_key
        args = {
          compute_disk_ids = [self.input.disk_id.value]
        }
      }

      edge {
        base = edge.compute_image_to_compute_disk
        args = {
          compute_image_ids = with.source_compute_images_for_compute_disk.rows[*].image_id
        }
      }

      edge {
        base = edge.compute_instance_to_compute_disk
        args = {
          compute_instance_ids = with.compute_instances_for_compute_disk.rows[*].instance_id
        }
      }

      edge {
        base = edge.compute_snapshot_to_compute_disk
        args = {
          compute_snapshot_names = with.source_compute_snapshots_for_compute_disk.rows[*].snapshot_name
        }
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
        args  = [self.input.disk_id.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.compute_disk_tags
        args  = [self.input.disk_id.value]
      }
    }

    container {

      width = 6

      table {
        title = "Attached To"
        query = query.compute_disk_attached_instances
        args  = [self.input.disk_id.value]

        column "Name" {
          href = "${dashboard.compute_instance_detail.url_path}?input.instance_id={{.'Instance ID' | @uri}}"
        }
      }

      table {
        title = "Encryption Details"
        query = query.compute_disk_encryption_status
        args  = [self.input.disk_id.value]
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
      args  = [self.input.disk_id.value]
    }

    chart {
      title = "Write Throughput (IOPS) - Last 7 Days"
      type  = "line"
      width = 6
      query = query.compute_disk_write_throughput
      args  = [self.input.disk_id.value]
    }

  }
}

# Input queries

query "compute_disk_input" {
  sql = <<-EOQ
    select
      name as label,
      id::text || '/' || project as value,
      json_build_object(
        'location', location,
        'project', project,
        'id', id::text
      ) as tags
    from
      gcp_compute_disk
    order by
      title;
  EOQ
}

# Card queries

query "compute_disk_storage" {
  sql = <<-EOQ
    select
      'Storage (GB)' as label,
      sum(size_gb) as value
    from
      gcp_compute_disk
    where
      id = (split_part($1, '/', 1))::bigint
      and project = split_part($1, '/', 2);
  EOQ
}

query "compute_disk_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      initcap(status) as value
    from
      gcp_compute_disk
    where
      id = (split_part($1, '/', 1))::bigint
      and project = split_part($1, '/', 2);
  EOQ
}

query "compute_disk_type" {
  sql = <<-EOQ
    select
      'Type' as label,
      type_name as value
    from
      gcp_compute_disk
    where
      id = (split_part($1, '/', 1))::bigint
      and project = split_part($1, '/', 2);
  EOQ
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
      id = (split_part($1, '/', 1))::bigint
      and project = split_part($1, '/', 2);
  EOQ
}

query "compute_disk_encryption" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      disk_encryption_key_type as value
    from
      gcp_compute_disk
    where
      id = (split_part($1, '/', 1))::bigint
      and project = split_part($1, '/', 2);
  EOQ
}

query "compute_disk_attached_instances" {
  sql = <<-EOQ
    with disks as (
      select
        instance_selflink
      from
        gcp_compute_disk, jsonb_array_elements_text(users) as instance_selflink
      where
        id = (split_part($1, '/', 1))::bigint
        and project = split_part($1, '/', 2)
    )
    select
      i.name as "Name",
      i.id::text as "Instance ID",
      i.status as "Instance State"
    from
      disks as d
      left join gcp_compute_instance as i on i.self_link = d.instance_selflink;
  EOQ
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
      id = (split_part($1, '/', 1))::bigint
      and project = split_part($1, '/', 2);
  EOQ
}

# With queries

query "compute_instances_for_compute_disk" {
  sql = <<-EOQ
    select
      i.id::text || '/' || i.project as instance_id
    from
      gcp_compute_disk d,
      gcp_compute_instance i,
      jsonb_array_elements(disks) as disk
    where
      d.self_link = (disk ->> 'source')
      and d.id = (split_part($1, '/', 1))::bigint
      and d.project = split_part($1, '/', 2);
  EOQ
}

query "compute_resource_policies_for_compute_disk" {
  sql = <<-EOQ
    select
      r.id as policy_id
    from
      gcp_compute_disk d,
      jsonb_array_elements_text(resource_policies) as rp,
      gcp_compute_resource_policy r
    where
      d.id = (split_part($1, '/', 1))::bigint
      and d.project = split_part($1, '/', 2)
      and rp = r.self_link;
  EOQ
}

query "source_compute_disks_for_compute_disk" {
  sql = <<-EOQ
    select
      d.source_disk_id || '/' || d.project as disk_id
    from
      gcp_compute_disk d
    where
      d.source_disk_id != ''
      and d.id = (split_part($1, '/', 1))::bigint
      and d.project = split_part($1, '/', 2);
  EOQ
}

query "source_compute_images_for_compute_disk" {
  sql = <<-EOQ
    select
      i.id::text || '/' || i.project as image_id
    from
      gcp_compute_disk d,
      gcp_compute_image i
    where
      d.source_image = i.self_link
      and d.id = (split_part($1, '/', 1))::bigint
      and d.source_image <> ''
  EOQ
}

query "source_compute_snapshots_for_compute_disk" {
  sql = <<-EOQ
    select
      s.name as snapshot_name
    from
      gcp_compute_disk d,
      gcp_compute_snapshot s
    where
      d.id = (split_part($1, '/', 1))::bigint
      and d.project = split_part($1, '/', 2)
      and d.source_snapshot = s.self_link;
  EOQ
}

query "kms_keys_for_compute_disk" {
  sql = <<-EOQ
    select
      k.self_link
    from
      gcp_compute_disk d,
      gcp_kms_key k
    where
      d.disk_encryption_key is not null
      and k.self_link like '%' || split_part(d.disk_encryption_key ->> 'kmsKeyName', '/cryptoKeyVersions/', 1)
      and d.id = (split_part($1, '/', 1))::bigint
      and d.project = split_part($1, '/', 2);
  EOQ
}

query "target_compute_disks_for_compute_disk" {
  sql = <<-EOQ
    select
      cd.id::text || '/' || cd.project as disk_id
    from
      gcp_compute_disk d,
      gcp_compute_disk cd
    where
      d.id = (split_part($1, '/', 1))::bigint
      and d.project = split_part($1, '/', 2)
      and d.id::text = cd.source_disk_id;
  EOQ
}

query "target_compute_images_for_compute_disk" {
  sql = <<-EOQ
    select
      i.id::text || '/' || i.project as image_id
    from
      gcp_compute_disk d,
      gcp_compute_image i
    where
      d.self_link = i.source_disk
      and d.id = (split_part($1, '/', 1))::bigint
      -- and d.project = split_part($1, '/', 2)
  EOQ
}

query "target_compute_snapshots_for_compute_disk" {
  sql = <<-EOQ
    select
      s.name as snapshot_name
    from
      gcp_compute_disk d,
      gcp_compute_snapshot s
    where
      d.id = (split_part($1, '/', 1))::bigint
      and d.project = split_part($1, '/', 2)
      and d.self_link = s.source_disk;
  EOQ
}

# Other queries

query "compute_disk_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id::text as "ID",
      creation_timestamp as "Create Time",
      title as "Title",
      location as "Location",
      project as "Project ID"
    from
      gcp_compute_disk
    where
      id = (split_part($1, '/', 1))::bigint
      and project = split_part($1, '/', 2)
  EOQ
}

query "compute_disk_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_compute_disk
      where
        id = (split_part($1, '/', 1))::bigint
        and project = split_part($1, '/', 2)
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
      and name in (select name from gcp_compute_disk where id = (split_part($1, '/', 1))::bigint and project = split_part($1, '/', 2))
    order by
      timestamp;
  EOQ
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
      and name in (select name from gcp_compute_disk where id = (split_part($1, '/', 1))::bigint and project = split_part($1, '/', 2))
    order by
      timestamp;
  EOQ
}
