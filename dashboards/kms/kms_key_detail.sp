dashboard "kms_key_detail" {

  title         = "GCP KMS Key Detail"
  documentation = file("./dashboards/kms/docs/kms_key_detail.md")

  tags = merge(local.kms_common_tags, {
    type = "Detail"
  })

  input "key_self_link" {
    title = "Select a key:"
    query = query.kms_key_name_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.kms_key_purpose
      args  = [self.input.key_self_link.value]
    }

    card {
      width = 2
      query = query.kms_key_rotation_period
      args  = [self.input.key_self_link.value]
    }

    card {
      width = 2
      query = query.kms_key_key_ring_name
      args  = [self.input.key_self_link.value]
    }

    card {
      width = 2
      query = query.kms_key_protection_level
      args  = [self.input.key_self_link.value]
    }

    card {
      width = 2
      query = query.kms_key_algorithm
      args  = [self.input.key_self_link.value]
    }
  }

  with "bigquery_datasets_from_kms_key_self_link" {
    query = query.bigquery_datasets_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "bigquery_tables_from_kms_key_self_link" {
    query = query.bigquery_tables_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "compute_disks_from_kms_key_self_link" {
    query = query.compute_disks_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "compute_images_from_kms_key_self_link" {
    query = query.compute_images_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "compute_snapshots_from_kms_key_self_link" {
    query = query.compute_snapshots_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "kms_key_rings_from_kms_key_self_link" {
    query = query.kms_key_rings_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "kubernetes_clusters_from_kms_key_self_link" {
    query = query.kubernetes_clusters_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "pubsub_topics_from_kms_key_self_link" {
    query = query.pubsub_topics_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "sql_backups_from_kms_key_self_link" {
    query = query.sql_backups_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "sql_database_instances_from_kms_key_self_link" {
    query = query.sql_database_instances_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  with "storage_buckets_from_kms_key_self_link" {
    query = query.storage_buckets_from_kms_key_self_link
    args  = [self.input.key_self_link.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.bigquery_dataset
        args = {
          bigquery_dataset_ids = with.bigquery_datasets_from_kms_key_self_link.rows[*].dataset_id
        }
      }

      node {
        base = node.bigquery_table
        args = {
          bigquery_table_ids = with.bigquery_tables_from_kms_key_self_link.rows[*].table_id
        }
      }

      node {
        base = node.compute_disk
        args = {
          compute_disk_ids = with.compute_disks_from_kms_key_self_link.rows[*].disk_id
        }
      }

      node {
        base = node.compute_image
        args = {
          compute_image_ids = with.compute_images_from_kms_key_self_link.rows[*].image_id
        }
      }

      node {
        base = node.compute_snapshot
        args = {
          compute_snapshot_names = with.compute_snapshots_from_kms_key_self_link.rows[*].snapshot_name
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = [self.input.key_self_link.value]
        }
      }

      node {
        base = node.kms_key_ring
        args = {
          kms_key_ring_names = with.kms_key_rings_from_kms_key_self_link.rows[*].akas
        }
      }

      node {
        base = node.kms_key_version
        args = {
          kms_key_self_links = [self.input.key_self_link.value]
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters_from_kms_key_self_link.rows[*].cluster_id
        }
      }

      node {
        base = node.pubsub_topic
        args = {
          pubsub_topic_self_links = with.pubsub_topics_from_kms_key_self_link.rows[*].self_link
        }
      }

      node {
        base = node.sql_backup
        args = {
          sql_backup_ids = with.sql_backups_from_kms_key_self_link.rows[*].backup_id
        }
      }

      node {
        base = node.sql_database_instance
        args = {
          database_instance_self_links = with.sql_database_instances_from_kms_key_self_link.rows[*].self_link
        }
      }

      node {
        base = node.storage_bucket
        args = {
          storage_bucket_ids = with.storage_buckets_from_kms_key_self_link.rows[*].bucket_id
        }
      }

      edge {
        base = edge.bigquery_dataset_to_kms_key
        args = {
          bigquery_dataset_ids = with.bigquery_datasets_from_kms_key_self_link.rows[*].dataset_id
        }
      }

      edge {
        base = edge.bigquery_table_to_kms_key
        args = {
          bigquery_table_ids = with.bigquery_tables_from_kms_key_self_link.rows[*].table_id
        }
      }

      edge {
        base = edge.compute_disk_to_kms_key_version
        args = {
          compute_disk_ids = with.compute_disks_from_kms_key_self_link.rows[*].disk_id
        }
      }

      edge {
        base = edge.compute_image_to_kms_key_version
        args = {
          compute_image_ids = with.compute_images_from_kms_key_self_link.rows[*].image_id
        }
      }

      edge {
        base = edge.compute_snapshot_to_kms_key_version
        args = {
          compute_snapshot_names = with.compute_snapshots_from_kms_key_self_link.rows[*].snapshot_name
        }
      }

      edge {
        base = edge.kms_key_ring_to_kms_key
        args = {
          kms_key_ring_names = with.kms_key_rings_from_kms_key_self_link.rows[*].akas
        }
      }

      edge {
        base = edge.kms_key_to_kms_key_version
        args = {
          kms_key_self_links = [self.input.key_self_link.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_kms_key
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters_from_kms_key_self_link.rows[*].cluster_id
        }
      }

      edge {
        base = edge.pubsub_topic_to_kms_key
        args = {
          pubsub_topic_self_links = with.pubsub_topics_from_kms_key_self_link.rows[*].self_link
        }
      }

      edge {
        base = edge.sql_backup_to_kms_key
        args = {
          sql_backup_ids = with.sql_backups_from_kms_key_self_link.rows[*].backup_id
        }
      }

      edge {
        base = edge.sql_database_instance_to_kms_key
        args = {
          database_instance_self_links = with.sql_database_instances_from_kms_key_self_link.rows[*].self_link
        }
      }

      edge {
        base = edge.storage_bucket_to_kms_key
        args = {
          storage_bucket_ids = with.storage_buckets_from_kms_key_self_link.rows[*].bucket_id
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
        args  = [self.input.key_self_link.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.kms_key_name_tags
        args  = [self.input.key_self_link.value]
      }

    }
  }
}

# Input queries

query "kms_key_name_input" {
  sql = <<-EOQ
    select
      title as label,
      self_link as value,
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
        self_link = $1;
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
        self_link = $1;
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
      self_link = $1;
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
      self_link = $1;
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
      self_link = $1;
  EOQ
}

# With queries

query "bigquery_datasets_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      d.id as dataset_id
    from
      gcp_bigquery_dataset d
    where
      $1 like '%' || d.kms_key_name || '%';
  EOQ
}

query "bigquery_tables_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      t.id as table_id
    from
      gcp_bigquery_table t
    where
      $1 like '%' || t.kms_key_name || '%';
  EOQ
}

query "compute_disks_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      d.id::text as disk_id
    from
      gcp_compute_disk d,
      gcp_kms_key_version k
    where
      d.disk_encryption_key is not null
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/cryptoKeyVersions/', 2) = k.crypto_key_version::text
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/', 8) = k.key_name
      and $1 like '%' || split_part(d.disk_encryption_key ->> 'kmsKeyName', '/cryptoKeyVersions/', 1);
  EOQ
}

query "compute_images_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      i.id::text as image_id
    from
      gcp_compute_image as i
    where
      i.image_encryption_key is not null
      and $1 like '%' || split_part(i.image_encryption_key->>'kmsKeyName', '/cryptoKeyVersions/', 1);
  EOQ
}

query "compute_snapshots_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      s.name as snapshot_name
    from
      gcp_compute_snapshot s,
      gcp_kms_key_version v
    where
      v.crypto_key_version::text = split_part(s.kms_key_name, 'cryptoKeyVersions/', 2)
      and split_part(s.kms_key_name, '/', 8) = v.key_name
      and v.self_link like $1 || '%';
  EOQ
}

query "kms_key_rings_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      p.akas::text
    from
      gcp_kms_key_ring p,
      gcp_kms_key k
    where
      k.key_ring_name = p.name
      and k.self_link = $1;
  EOQ
}

query "kubernetes_clusters_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      c.id::text as cluster_id
    from
      gcp_kubernetes_cluster c
    where
      c.database_encryption_key_name is not null
      and database_encryption_key_name <> ''
      and $1 like '%' || database_encryption_key_name;
  EOQ
}

query "pubsub_topics_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      p.self_link
    from
      gcp_pubsub_topic p
    where
      kms_key_name is not null
      and kms_key_name <> ''
      and $1 like '%' || kms_key_name;
  EOQ
}

query "sql_backups_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      b.id::text as backup_id
    from
      gcp_sql_backup b
    where
      $1 like '%' || (disk_encryption_configuration ->> 'kmsKeyName');
  EOQ
}

query "sql_database_instances_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      i.self_link
    from
      gcp_sql_database_instance as i
    where
      $1 like '%' || kms_key_name;
  EOQ
}

query "storage_buckets_from_kms_key_self_link" {
  sql = <<-EOQ
    select
      b.id as bucket_id
    from
      gcp_storage_bucket b
    where
      b.default_kms_key_name is not null
      and $1 like '%' || default_kms_key_name;
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
      self_link = $1;
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
    self_link = $1;
  EOQ

}
