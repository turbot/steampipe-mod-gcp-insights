dashboard "storage_bucket_detail" {

  title         = "GCP Storage Bucket Detail"
  documentation = file("./dashboards/storage/docs/storage_bucket_detail.md")

  tags = merge(local.storage_common_tags, {
    type = "Detail"
  })

  input "bucket_id" {
    title = "Select a bucket:"
    query = query.storage_bucket_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.storage_bucket_class
      args = {
        id = self.input.bucket_id.value
      }
    }

    card {
      width = 2
      query = query.storage_bucket_public_access
      args = {
        id = self.input.bucket_id.value
      }
    }

    card {
      width = 2
      query = query.storage_bucket_versioning_disabled
      args = {
        id = self.input.bucket_id.value
      }
    }

    card {
      width = 2
      query = query.storage_bucket_retention_policy
      args = {
        id = self.input.bucket_id.value
      }
    }

    card {
      width = 2
      query = query.storage_bucket_logging
      args = {
        id = self.input.bucket_id.value
      }
    }

    card {
      width = 2
      query = query.storage_bucket_uniform_bucket_level_access
      args = {
        id = self.input.bucket_id.value
      }
    }

  }

  // container {

  //   graph {
  //     title = "Relationships"
  //     type  = "graph"

  //     with "compute_backend_buckets" {
  //       sql = <<-EOQ
  //         select
  //           c.id::text as bucket_id
  //         from
  //           gcp_storage_bucket b,
  //           gcp_compute_backend_bucket c
  //         where
  //           b.id = $1
  //           and b.name = c.bucket_name;
  //       EOQ

  //       args = [self.input.bucket_id.value]
  //     }

  //     with "kms_keys" {
  //       sql = <<-EOQ
  //         select
  //           split_part(b.default_kms_key_name, 'cryptoKeys/', 2) as key_name
  //         from
  //           gcp_storage_bucket b
  //         where
  //           b.id = $1
  //           and b.default_kms_key_name is not null;
  //       EOQ

  //       args = [self.input.bucket_id.value]
  //     }

  //     with "logging_buckets" {
  //       sql = <<-EOQ
  //         select
  //           l.name as bucket_name
  //         from
  //           gcp_storage_bucket b,
  //           gcp_logging_bucket l
  //         where
  //           b.id = $1
  //           and b.log_bucket is not null
  //           and b.log_bucket = l.name;
  //       EOQ

  //       args = [self.input.bucket_id.value]
  //     }

  //     nodes = [
  //       node.compute_backend_bucket,
  //       node.kms_key,
  //       node.logging_bucket,
  //       node.storage_bucket
  //     ]

  //     edges = [
  //       edge.compute_backend_bucket_to_storage_bucket,
  //       edge.storage_bucket_to_kms_key,
  //       edge.storage_bucket_to_logging_bucket
  //     ]

  //     args = {
  //       compute_backend_bucket_ids = with.compute_backend_buckets.rows[*].bucket_id
  //       kms_key_names              = with.kms_keys.rows[*].key_name
  //       logging_bucket_names       = with.logging_buckets.rows[*].bucket_name
  //       storage_bucket_ids         = [self.input.bucket_id.value]
  //     }
  //   }
  // }

  container {

    container {
      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.storage_bucket_overview
        args = {
          id = self.input.bucket_id.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.storage_bucket_tags_detail
        args = {
          id = self.input.bucket_id.value
        }
      }
    }

    container {
      width = 6

      table {
        title = "Logging Details"
        query = query.storage_bucket_logging_detail
        args = {
          id = self.input.bucket_id.value
        }
      }

      table {
        title = "Compute Backend Bucket"
        query = query.storage_bucket_compute_backend_bucket_detail
        args = {
          id = self.input.bucket_id.value
        }
      }

      table {
        title = "Encryption Details"
        query = query.storage_bucket_encryption_detail
        args = {
          id = self.input.bucket_id.value
        }
      }
    }

  }

}

query "storage_bucket_input" {
  sql = <<-EOQ
    select
      title as label,
      id as value,
      json_build_object(
        'project', project
      ) as tags
    from
      gcp_storage_bucket
    order by
      title;
  EOQ
}

# Card Queries

query "storage_bucket_class" {
  sql = <<-EOQ
    select
      'Storage Class' as label,
      initcap(storage_class) as value
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}

}

query "storage_bucket_public_access" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case when iam_policy ->> 'bindings' like any (array ['%allAuthenticatedUsers%','%allUsers%']) then 'Enabled' else 'Disabled' end as value,
      case when iam_policy ->> 'bindings' like any (array ['%allAuthenticatedUsers%','%allUsers%']) then 'alert' else 'ok' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "storage_bucket_versioning_disabled" {
  sql = <<-EOQ
    select
      'Versioning' as label,
      case when versioning_enabled then 'Enabled' else 'Disabled' end as value,
      case when versioning_enabled then 'ok' else 'alert' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "storage_bucket_retention_policy" {
  sql = <<-EOQ
    select
      'Retention Policy' as label,
      case when retention_policy is not null then 'Enabled' else 'Disabled' end as value,
      case when retention_policy is not null then 'ok' else 'alert' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "storage_bucket_logging" {
  sql = <<-EOQ
    select
      'Logging' as label,
      case when log_bucket is not null then 'Enabled' else 'Disabled' end as value,
      case when log_bucket is not null then 'ok' else 'alert' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "storage_bucket_uniform_bucket_level_access" {
  sql = <<-EOQ
    select
      'Uniform Bucket Level Access' as label,
      case when iam_configuration_uniform_bucket_level_access_enabled then 'Enabled' else 'Disabled' end as value,
      case when iam_configuration_uniform_bucket_level_access_enabled then 'ok' else 'alert' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

# Tables

query "storage_bucket_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      versioning_enabled as "Versioning Enabled",
      storage_class as "Storage Class",
      time_created as "Create Time",
      title as "Title",
      location as "Location",
      project as "Project ID"
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "storage_bucket_tags_detail" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_storage_bucket
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

query "storage_bucket_logging_detail" {
  sql = <<-EOQ
    select
      b.log_bucket as "Log Bucket",
      b.log_object_prefix as "Log Object Prefix",
      l.create_time as "Created Time",
      l.retention_days as "Retention Days",
      l.lifecycle_state as "Lifecycle State"
    from
      gcp_storage_bucket b,
      gcp_logging_bucket l
    where
      b.id = $1
      and b.log_bucket is not null
      and b.log_bucket = l.name;
  EOQ

  param "id" {}
}

query "storage_bucket_compute_backend_bucket_detail" {
  sql = <<-EOQ
    select
      c.id as "Backend Bucket ID",
      c.name as "Backend Bucket Name",
      c.creation_timestamp as "Created Time",
      c.location as "Location"
    from
      gcp_storage_bucket b,
      gcp_compute_backend_bucket c
    where
      b.id = $1
      and b.name = c.bucket_name;
  EOQ

  param "id" {}
}

query "storage_bucket_encryption_detail" {
  sql = <<-EOQ
    select
      case when k.name is not null then 'Customer-managed encryption key (CMEK)' else 'Google-managed encryption key' end as "Encryption Type",
      k.name as "Key Name",
      k.key_ring_name as "Key Ring Name",
      k.create_time as "Created Time",
      k.location as "Location"
    from
      gcp_storage_bucket b
        left join gcp_kms_key k
        on split_part(b.default_kms_key_name, 'cryptoKeys/', 2) = k.name
    where
      b.id = $1;
  EOQ

  param "id" {}
}
