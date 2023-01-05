dashboard "kms_key_detail" {

  title         = "GCP KMS Key Detail"
  documentation = file("./dashboards/kms/docs/kms_key_detail.md")

  tags = merge(local.kms_common_tags, {
    type = "Detail"
  })

  input "key_name" {
    title = "Select a key:"
    query = query.kms_key_name_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kms_key_purpose
      args  = [self.input.key_name.value]
    }

    card {
      width = 2
      query = query.kms_key_rotation_period
      args  = [self.input.key_name.value]
    }

    card {
      width = 2
      query = query.kms_key_key_ring_name
      args  = [self.input.key_name.value]
    }

    card {
      width = 2
      query = query.kms_key_protection_level
      args  = [self.input.key_name.value]
    }

    card {
      width = 2
      query = query.kms_key_algorithm
      args  = [self.input.key_name.value]
    }
  }

  with "bigquery_datasets" {
    query = query.kms_key_bigquery_datasets
    args  = [self.input.key_name.value]
  }

  with "bigquery_tables" {
    query = query.kms_key_bigquery_tables
    args  = [self.input.key_name.value]
  }

  with "compute_disks" {
    query = query.kms_key_compute_disks
    args  = [self.input.key_name.value]
  }

  with "compute_images" {
    query = query.kms_key_compute_images
    args  = [self.input.key_name.value]
  }

  with "compute_snapshots" {
    query = query.kms_key_compute_snapshots
    args  = [self.input.key_name.value]
  }

  with "kms_key_rings" {
    query = query.kms_key_kms_key_rings
    args  = [self.input.key_name.value]
  }

  with "kubernetes_clusters" {
    query = query.kms_key_kubernetes_clusters
    args  = [self.input.key_name.value]
  }

  with "pubsub_topics" {
    query = query.kms_key_pubsub_topics
    args  = [self.input.key_name.value]
  }

  with "sql_backups" {
    query = query.kms_key_sql_backups
    args  = [self.input.key_name.value]
  }

  with "sql_database_instances" {
    query = query.kms_key_sql_database_instances
    args  = [self.input.key_name.value]
  }

  with "storage_buckets" {
    query = query.kms_key_storage_buckets
    args  = [self.input.key_name.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.bigquery_dataset
        args = {
          bigquery_dataset_ids = with.bigquery_datasets.rows[*].dataset_id
        }
      }

      node {
        base = node.bigquery_table
        args = {
          bigquery_table_ids = with.bigquery_tables.rows[*].table_id
        }
      }

      node {
        base = node.compute_disk
        args = {
          compute_disk_ids = with.compute_disks.rows[*].disk_id
        }
      }

      node {
        base = node.compute_image
        args = {
          compute_image_ids = with.compute_images.rows[*].image_id
        }
      }

      node {
        base = node.compute_snapshot
        args = {
          compute_snapshot_names = with.compute_snapshots.rows[*].snapshot_name
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_names = [self.input.key_name.value]
        }
      }

      node {
        base = node.kms_key_ring
        args = {
          kms_key_ring_names = with.kms_key_rings.rows[*].ring_name
        }
      }

      node {
        base = node.kms_key_version
        args = {
          kms_key_names = [self.input.key_name.value]
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters.rows[*].cluster_id
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters.rows[*].cluster_id
        }
      }

      node {
        base = node.pubsub_topic
        args = {
          pubsub_topic_names = with.pubsub_topics.rows[*].topic_name
        }
      }

      node {
        base = node.sql_backup
        args = {
          sql_backup_ids = with.sql_backups.rows[*].backup_id
        }
      }

      node {
        base = node.sql_database_instance
        args = {
          database_instance_self_links = with.sql_database_instances.rows[*].self_link
        }
      }

      node {
        base = node.storage_bucket
        args = {
          storage_bucket_ids = with.storage_buckets.rows[*].bucket_id
        }
      }

      edge {
        base = edge.bigquery_dataset_to_kms_key
        args = {
          bigquery_dataset_ids = with.bigquery_datasets.rows[*].dataset_id
        }
      }

      edge {
        base = edge.bigquery_table_to_kms_key
        args = {
          bigquery_table_ids = with.bigquery_tables.rows[*].table_id
        }
      }

      edge {
        base = edge.compute_disk_to_kms_key_version
        args = {
          compute_disk_ids = with.compute_disks.rows[*].disk_id
        }
      }

      edge {
        base = edge.compute_image_to_kms_key_version
        args = {
          compute_image_ids = with.compute_images.rows[*].image_id
        }
      }

      edge {
        base = edge.compute_snapshot_to_kms_key_version
        args = {
          compute_snapshot_names = with.compute_snapshots.rows[*].snapshot_name
        }
      }

      edge {
        base = edge.kms_key_ring_to_kms_key
        args = {
          kms_key_ring_names = with.kms_key_rings.rows[*].ring_name
        }
      }

      edge {
        base = edge.kms_key_to_kms_key_version
        args = {
          kms_key_names = [self.input.key_name.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_kms_key
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters.rows[*].cluster_id
        }
      }

      edge {
        base = edge.pubsub_topic_to_kms_key
        args = {
          pubsub_topic_names = with.pubsub_topics.rows[*].topic_name
        }
      }

      edge {
        base = edge.sql_backup_to_kms_key
        args = {
          sql_backup_ids = with.sql_backups.rows[*].backup_id
        }
      }

      edge {
        base = edge.sql_database_instance_to_kms_key
        args = {
          database_instance_self_links = with.sql_database_instances.rows[*].self_link
        }
      }

      edge {
        base = edge.storage_bucket_to_kms_key
        args = {
          storage_bucket_ids = with.storage_buckets.rows[*].bucket_id
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
        query = query.kms_key_name_overview
        args  = [self.input.key_name.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.kms_key_name_tags
        args  = [self.input.key_name.value]
      }

    }
  }
}

# Input queries

query "kms_key_name_input" {
  sql = <<-EOQ
    select
      title as label,
      name as value,
      json_build_object(
          'project', project
      ) as tags
    from
      gcp_kms_key
    order by
      title;
  EOQ
}

# Card queries

query "kms_key_purpose" {
  sql = <<-EOQ
    select
      'Purpose' as label,
      purpose as value
    from
      gcp_kms_key
      where
        name = $1;
  EOQ
}

query "kms_key_rotation_period" {
  sql = <<-EOQ
  select
      'Rotation Period in days' as label,
      NULLIF(SPLIT_PART(rotation_period, 's', 1), '')::int / ( 60 * 60 * 24) as value
    from
      gcp_kms_key
      where
        name = $1;
  EOQ
}

query "kms_key_key_ring_name" {
  sql = <<-EOQ
    select
      'Key Ring Name' as label,
      key_ring_name as value
    from
      gcp_kms_key
    where
      name = $1;
  EOQ
}

query "kms_key_protection_level" {
  sql = <<-EOQ
    select
      'Protection Level' as label,
      version_template->>'protectionLevel' as value
    from
      gcp_kms_key
    where
      name = $1;
  EOQ
}

query "kms_key_algorithm" {
  sql = <<-EOQ
    select
      'Algorithm' as label,
      version_template->>'algorithm' as value
    from
      gcp_kms_key
    where
      name = $1;
  EOQ
}

# With queries

query "kms_key_bigquery_datasets" {
  sql = <<-EOQ
    select
      d.id as dataset_id
    from
      gcp_bigquery_dataset d
    where
      split_part(d.kms_key_name, 'cryptoKeys/', 2) = $1;
  EOQ
}

query "kms_key_bigquery_tables" {
  sql = <<-EOQ
    select
      t.id as table_id
    from
      gcp_bigquery_table t
    where
      split_part(t.kms_key_name, 'cryptoKeys/', 2) = $1;
  EOQ
}

query "kms_key_compute_disks" {
  sql = <<-EOQ
    select
      d.id::text as disk_id
    from
      gcp_compute_disk d,
      gcp_kms_key_version k
    where
      d.disk_encryption_key is not null
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', 'cryptoKeyVersions/', 2) = k.crypto_key_version::text
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/', 8) = k.key_name
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/', 8) = $1;
  EOQ
}

query "kms_key_compute_images" {
  sql = <<-EOQ
    select
      i.id::text as image_id
    from
      gcp_compute_image as i
    where
      i.image_encryption_key is not null
      and split_part(i.image_encryption_key->>'kmsKeyName', '/', 8) = $1;
  EOQ
}

query "kms_key_compute_snapshots" {
  sql = <<-EOQ
    select
      s.name as snapshot_name
    from
      gcp_compute_snapshot s,
      gcp_kms_key_version v
    where
      v.crypto_key_version::text = split_part(s.kms_key_name, 'cryptoKeyVersions/', 2)
      and split_part(s.kms_key_name, '/', 8) = v.key_name
      and v.key_name = $1;
  EOQ
}

query "kms_key_kms_key_rings" {
  sql = <<-EOQ
    select
      p.name as ring_name
    from
      gcp_kms_key_ring p,
      gcp_kms_key k
    where
      k.key_ring_name = p.name
      and k.name = $1;
  EOQ
}

query "kms_key_kubernetes_clusters" {
  sql = <<-EOQ
    select
      c.id::text as cluster_id
    from
      gcp_kubernetes_cluster c
    where
      c.database_encryption_key_name is not null
      and split_part(c.database_encryption_key_name, 'cryptoKeys/', 2) = $1;
  EOQ
}

query "kms_key_pubsub_topics" {
  sql = <<-EOQ
    select
      'projects/' || p.project || '/topics/' || p.name as topic_name
    from
      gcp_pubsub_topic p,
      gcp_kms_key k
    where
      split_part(p.kms_key_name, 'cryptoKeys/', 2) = $1;
  EOQ
}

query "kms_key_sql_backups" {
  sql = <<-EOQ
    select
      b.id::text as backup_id
    from
      gcp_sql_backup b
    where
      split_part(b.disk_encryption_configuration ->> 'kmsKeyName','cryptoKeys/',2) = $1;
  EOQ
}

query "kms_key_sql_database_instances" {
  sql = <<-EOQ
    select
      i.self_link
    from
      gcp_sql_database_instance as i
    where
      split_part(i.kms_key_name, 'cryptoKeys/', 2) = $1;
  EOQ
}

query "kms_key_storage_buckets" {
  sql = <<-EOQ
    select
      b.id as bucket_id
    from
      gcp_storage_bucket b
    where
      b.default_kms_key_name is not null
      and split_part(b.default_kms_key_name, 'cryptoKeys/', 2) = $1;
  EOQ
}

# Other queries

query "kms_key_name_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      create_time as "Create Time",
      title as "Title",
      location as "Location",
      self_link as "Self-Link"
    from
      gcp_kms_key
    where
      name = $1;
  EOQ

}

query "kms_key_name_tags" {
  sql = <<-EOQ
  select
    jsonb_object_keys(tags) as "Key",
    tags ->> jsonb_object_keys(tags) as "Value"
  from
    gcp_kms_key
  where
    name = $1;
  EOQ

}
