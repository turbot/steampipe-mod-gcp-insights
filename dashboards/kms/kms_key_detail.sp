dashboard "gcp_kms_key_detail" {

  title         = "GCP KMS Key Detail"
  documentation = file("./dashboards/kms/docs/kms_key_detail.md")

  tags = merge(local.kms_common_tags, {
    type = "Detail"
  })

  input "key_name" {
    title = "Select a key:"
    query = query.gcp_kms_key_name_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_kms_key_purpose
      args = {
        key_name = self.input.key_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_kms_key_rotation_period
      args = {
        key_name = self.input.key_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_kms_key_key_ring_name
      args = {
        key_name = self.input.key_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_kms_key_protection_level
      args = {
        key_name = self.input.key_name.value
      }
    }

    card {
      width = 2
      query = query.gcp_kms_key_algorithm
      args = {
        key_name = self.input.key_name.value
      }
    }
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      nodes = [
        node.gcp_kms_key_nodes,
        node.gcp_kms_key_from_storage_bucket_node,
        node.gcp_kms_key_from_pubsub_topic_node,
        node.gcp_kms_key_from_kms_key_ring_node,
        node.gcp_kms_key_from_compute_disk_node,
        node.gcp_kms_key_from_gcp_compute_image_node,
        node.gcp_kms_key_from_compute_snapshot_node,
        node.gcp_kms_key_from_sql_database_instance_node,
        node.gcp_kms_key_from_bigquery_dataset_node,
        node.gcp_kms_key_from_bigquery_table_node,
        node.gcp_kms_key_to_kms_key_version_node,
        node.gcp_kms_key_from_kubernetes_cluster_node
      ]

      edges = [
        edge.gcp_kms_key_from_storage_bucket_edge,
        edge.gcp_kms_key_from_pubsub_topic_edge,
        edge.gcp_kms_key_from_kms_key_ring_edge,
        edge.gcp_kms_key_from_compute_disk_edge,
        edge.gcp_kms_key_from_gcp_compute_image_edge,
        edge.gcp_kms_key_from_compute_snapshot_edge,
        edge.gcp_kms_key_from_sql_database_instance_edge,
        edge.gcp_kms_key_from_bigquery_dataset_edge,
        edge.gcp_kms_key_from_bigquery_table_edge,
        edge.gcp_kms_key_to_kms_key_version_edge,
        edge.gcp_kms_key_from_kubernetes_cluster_edge
      ]

      args = {
        key_name  = self.input.key_name.value
        key_names = self.input.key_name.value
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
        query = query.gcp_kms_key_name_overview
        args = {
          key_name = self.input.key_name.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_kms_key_name_tags
        args = {
          key_name = self.input.key_name.value
        }
      }

    }
  }
}

query "gcp_kms_key_name_input" {
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

node "gcp_kms_key_nodes" {
  category = category.gcp_kms_key

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Created Time', create_time,
        'Location', location
      ) as properties
    from
      gcp_kms_key
    where
      name = any($1);
  EOQ

  param "key_names" {}
}

node "gcp_kms_key_from_storage_bucket_node" {
  category = category.gcp_storage_bucket

  sql = <<-EOQ
    select
      b.id,
      b.title,
      jsonb_build_object(
        'Name', b.name,
        'Created Time', b.time_created,
        'Storage Class', b.storage_class
      ) as properties
    from
      gcp_storage_bucket b,
      gcp_kms_key k
    where
      k.name = split_part(b.default_kms_key_name, 'cryptoKeys/', 2)
      and k.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_storage_bucket_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      b.id as from_id,
      k.name as to_id
    from
      gcp_storage_bucket b,
      gcp_kms_key k
    where
      k.name = $1
      and b.default_kms_key_name is not null
      and split_part(b.default_kms_key_name, 'cryptoKeys/', 2) = k.name;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_pubsub_topic_node" {
  category = category.gcp_pubsub_topic

  sql = <<-EOQ
    select
      p.name as id,
      p.title,
      jsonb_build_object(
        'Name', p.name,
        'Location', p.location,
        'Project', p.project,
        'Self Link', p.self_link
      ) as properties
    from
      gcp_pubsub_topic p,
      gcp_kms_key k
    where
      k.name = split_part(p.kms_key_name, 'cryptoKeys/', 2)
      and k.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_pubsub_topic_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      p.name as from_id,
      k.name as to_id
    from
      gcp_pubsub_topic p,
      gcp_kms_key k
    where
      k.name = split_part(p.kms_key_name, 'cryptoKeys/', 2)
      and k.name = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_kms_key_ring_node" {
  category = category.gcp_kms_key_ring

  sql = <<-EOQ
    select
      concat(p.name, '_key_ring') as id,
      p.title,
      jsonb_build_object(
        'Name', p.name,
        'Location', p.location,
        'Project', p.project,
        'Create Time', p.create_time
      ) as properties
    from
      gcp_kms_key_ring p,
      gcp_kms_key k
    where
      k.key_ring_name = p.name
      and k.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_kms_key_ring_edge" {
  title = "organizes"

  sql = <<-EOQ
    select
      concat(p.name, '_key_ring') as from_id,
      k.name as to_id
    from
      gcp_kms_key_ring p,
      gcp_kms_key k
    where
      k.key_ring_name = p.name
      and k.name = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_compute_disk_node" {
  category = category.gcp_compute_disk

  sql = <<-EOQ
    select
      d.id::text,
      d.title,
      jsonb_build_object(
        'ID', d.id,
        'Created Time', d.creation_timestamp,
        'Size(GB)', d.size_gb,
        'Status', d.status,
        'Encryption Key Type', d.disk_encryption_key_type
      ) as properties
    from
      gcp_compute_disk d,
      gcp_kms_key k
    where
      k.name = $1
      and d.disk_encryption_key is not null
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/', 8) = k.name;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_compute_disk_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      d.id::text as from_id,
      k.name as to_id
    from
      gcp_compute_disk d,
      gcp_kms_key_version k
    where
      k.name = $1
      and d.disk_encryption_key is not null
      and split_part(d.disk_encryption_key ->> 'kmsKeyName', '/', 8) = k.name;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_sql_database_instance_node" {
  category = category.gcp_sql_database_instance

  sql = <<-EOQ
    select
      i.name as id,
      i.title,
      jsonb_build_object(
        'Name', i.name,
        'State', i.state,
        'Instance Type', i.instance_type,
        'Database Version', i.database_version,
        'KMS Key Name', i.kms_key_name,
        'Location', i.location
      ) as properties
    from
      gcp_sql_database_instance as i,
      gcp_kms_key as k
    where
      split_part(i.kms_key_name, 'cryptoKeys/', 2) = k.name
      and k.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_sql_database_instance_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.name as from_id,
      k.name as to_id
    from
      gcp_sql_database_instance as i,
      gcp_kms_key as k
    where
      split_part(i.kms_key_name, 'cryptoKeys/', 2) = k.name
      and k.name = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_gcp_compute_image_node" {
  category = category.gcp_compute_image

  sql = <<-EOQ
    select
      i.name as id,
      i.title,
      jsonb_build_object(
        'Name', i.name,
        'Status', i.status,
        'KMS Key Name', split_part(i.image_encryption_key->>'kmsKeyName', '/', -3),
        'Location', i.location
      ) as properties
    from
      gcp_compute_image as i,
      gcp_kms_key as k
    where
      split_part(i.image_encryption_key->>'kmsKeyName', '/', -3) = k.name
      and k.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_gcp_compute_image_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.name as from_id,
      k.name as to_id
    from
      gcp_compute_image as i,
      gcp_kms_key as k
    where
      split_part(i.image_encryption_key->>'kmsKeyName', '/', -3) = k.name
      and k.name = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_compute_snapshot_node" {
  category = category.gcp_compute_snapshot

  sql = <<-EOQ
    select
      s.name as id,
      s.title,
      jsonb_build_object(
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Size(GB)', s.disk_size_gb,
        'Status', s.status
      ) as properties
    from
      gcp_compute_snapshot s,
      gcp_kms_key_version v
    where
      v.crypto_key_version::text = split_part(s.kms_key_name, 'cryptoKeyVersions/', 2)
      and split_part(s.kms_key_name, '/', 8) = v.name
      and v.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_compute_snapshot_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      s.name as from_id,
      v.name || '_' || v.crypto_key_version as to_id
    from
      gcp_compute_snapshot s,
      gcp_kms_key_version v
    where
      v.crypto_key_version::text = split_part(s.kms_key_name, 'cryptoKeyVersions/', 2)
      and split_part(s.kms_key_name, '/', 8) = v.name
      and v.name = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_bigquery_dataset_node" {
  category = category.gcp_bigquery_dataset

  sql = <<-EOQ
    select
      d.id,
      d.title,
      jsonb_build_object(
        'ID', d.id,
        'Created Time', d.creation_time,
        'Table Expiration(ms)', d.default_table_expiration_ms,
        'KMS Key', d.kms_key_name,
        'Location', d.location
      ) as properties
    from
      gcp_kms_key k,
      gcp_bigquery_dataset d
    where
      k.name = split_part(d.kms_key_name, 'cryptoKeys/', 2)
      and k.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_bigquery_dataset_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      d.id as from_id,
      k.name as to_id
    from
      gcp_kms_key k,
      gcp_bigquery_dataset d
    where
      k.name = split_part(d.kms_key_name, 'cryptoKeys/', 2)
      and k.name = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_bigquery_table_node" {
  category = category.gcp_bigquery_table

  sql = <<-EOQ
    select
      t.id,
      t.title,
      jsonb_build_object(
        'ID', t.id,
        'Created Time', t.creation_time,
        'Dataset Id', t.dataset_id,
        'Expiration Time', t.expiration_time,
        'KMS Key', t.kms_key_name,
        'Location', t.location
      ) as properties
    from
      gcp_kms_key k,
      gcp_bigquery_table t
    where
      k.name = split_part(t.kms_key_name, 'cryptoKeys/', 2)
      and k.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_bigquery_table_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      t.id as from_id,
      k.name as to_id
    from
      gcp_kms_key k,
      gcp_bigquery_table t
    where
      k.name = split_part(t.kms_key_name, 'cryptoKeys/', 2)
      and k.name = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_sql_backup_node" {
  category = category.gcp_sql_backup

  sql = <<-EOQ
    select
      b.id::text,
      b.title,
      jsonb_build_object(
        'ID', b.id,
        'Created Time', b.end_time,
        'Instance Name', b.instance_name,
        'Type', b.type,
        'Status', b.status,
        'Location', b.location
      ) as properties
    from
      gcp_kms_key k,
      gcp_sql_backup b
    where
      split_part(b.disk_encryption_configuration ->> 'kmsKeyName','cryptoKeys/',2) = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_sql_backup_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      b.id::text as from_id,
      k.name as to_id
    from
      gcp_kms_key k,
      gcp_sql_backup b
    where
      split_part(b.disk_encryption_configuration ->> 'kmsKeyName','cryptoKeys/',2) = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_to_kms_key_version_node" {
  category = category.gcp_kms_key_version

  sql = <<-EOQ
    select
      v.name || '_' || v.crypto_key_version as id,
      v.title,
      jsonb_build_object(
        'Created Time', v.create_time,
        'Destroy Time', v.destroy_time,
        'Algorithm', v.algorithm,
        'Crypto Key Version', v.crypto_key_version,
        'Protection Level', v.protection_level,
        'State', v.state,
        'Location', v.location
      ) as properties
    from
      gcp_kms_key_version v
    where
      v.name = $1;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_to_kms_key_version_edge" {
  title = "version"

  sql = <<-EOQ
    select
      $1 as from_id,
      v.name || '_' || v.crypto_key_version as to_id
    from
      gcp_kms_key_version v
    where
      v.name = $1;
  EOQ

  param "key_name" {}
}

node "gcp_kms_key_from_kubernetes_cluster_node" {
  category = category.gcp_kubernetes_cluster

  sql = <<-EOQ
    select
      c.name as id,
      c.title,
      jsonb_build_object(
        'Name', c.name,
        'Created Time', c.create_time,
        'Endpoint', c.endpoint,
        'Services IPv4 CIDR', c.services_ipv4_cidr,
        'Status', c.status
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_kms_key k
    where
      k.name = $1
      and c.database_encryption_key_name is not null
      and split_part(c.database_encryption_key_name, 'cryptoKeys/', 2) = k.name;
  EOQ

  param "key_name" {}
}

edge "gcp_kms_key_from_kubernetes_cluster_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      c.name as from_id,
      k.name as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_kms_key k
    where
      k.name = $1
      and c.database_encryption_key_name is not null
      and split_part(c.database_encryption_key_name, 'cryptoKeys/', 2) = k.name;
  EOQ

  param "key_name" {}
}

query "gcp_kms_key_purpose" {
  sql = <<-EOQ
    select
      'Purpose' as label,
      purpose as value
    from
      gcp_kms_key
      where
        name = $1;
  EOQ

  param "key_name" {}
}

query "gcp_kms_key_rotation_period" {
  sql = <<-EOQ
  select
      'Rotation Period in days' as label,
      NULLIF(SPLIT_PART(rotation_period, 's', 1), '')::int / ( 60 * 60 * 24) as value
    from
      gcp_kms_key
      where
        name = $1;
  EOQ

  param "key_name" {}
}

query "gcp_kms_key_key_ring_name" {
  sql = <<-EOQ
    select
      'Key Ring Name' as label,
      key_ring_name as value
    from
      gcp_kms_key
    where
      name = $1;
  EOQ

  param "key_name" {}
}

query "gcp_kms_key_protection_level" {
  sql = <<-EOQ
    select
      'Protection Level' as label,
      version_template->>'protectionLevel' as value
    from
      gcp_kms_key
    where
      name = $1;
  EOQ

  param "key_name" {}
}

query "gcp_kms_key_algorithm" {
  sql = <<-EOQ
    select
      'Algorithm' as label,
      version_template->>'algorithm' as value
    from
      gcp_kms_key
    where
      name = $1;
  EOQ

  param "key_name" {}
}

query "gcp_kms_key_name_overview" {
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

  param "key_name" {}
}

query "gcp_kms_key_name_tags" {
  sql = <<-EOQ
  select
    jsonb_object_keys(tags) as "Key",
    tags ->> jsonb_object_keys(tags) as "Value"
  from
    gcp_kms_key
  where
    name = $1;
  EOQ

  param "key_name" {}
}
