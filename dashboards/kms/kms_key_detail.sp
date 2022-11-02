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
        node.gcp_kms_key_node,
        node.gcp_kms_key_from_storage_bucket_node,
        node.gcp_kms_key_from_pubsub_topic_node,
        node.gcp_kms_key_from_kms_key_ring_node
      ]

      edges = [
        edge.gcp_kms_key_from_storage_bucket_edge,
        edge.gcp_kms_key_from_pubsub_topic_edge,
        edge.gcp_kms_key_from_kms_key_ring_edge
      ]

      args = {
        key_name = self.input.key_name.value
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

node "gcp_kms_key_node" {
  category = category.gcp_kms_key

  sql = <<-EOQ
    select
      concat(name, '_key') as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'Created Time', create_time,
        'Location', location
      ) as properties
    from
      gcp_kms_key
    where
      name = $1;
  EOQ

  param "key_name" {}
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
      concat(k.name, '_key') as to_id
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
      concat(k.name, '_key') as to_id
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
      concat(k.name, '_key') as to_id
    from
      gcp_kms_key_ring p,
      gcp_kms_key k
    where
      k.key_ring_name = p.name
      and k.name = $1;
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
