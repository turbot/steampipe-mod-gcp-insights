dashboard "gcp_pubsub_topic_detail" {

  title         = "GCP Pub/Sub Topic Detail"
  documentation = file("./dashboards/pubsub/docs/pubsub_topic_detail.md")

  tags = merge(local.pubsub_common_tags, {
    type = "Detail"
  })

  input "name" {
    title = "Select a topic:"
    query = query.gcp_pubsub_topic_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_pubsub_topic_encryption
      args = {
        name = self.input.name.value
      }
    }

    card {
      width = 2
      query = query.gcp_pubsub_topic_labeled
      args = {
        name = self.input.name.value
      }
    }
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"


      nodes = [
        node.gcp_pubsub_topic_node
        // node.gcp_storage_bucket_to_kms_key_node,
        // node.gcp_storage_bucket_to_logging_bucket_node,
        // node.gcp_storage_bucket_from_compute_backend_bucket_node
      ]

      edges = [
        // edge.gcp_storage_bucket_to_kms_key_edge,
        // edge.gcp_storage_bucket_to_logging_bucket_edge,
        // edge.gcp_storage_bucket_from_compute_backend_bucket_edge
      ]

      args = {
        name = self.input.name.value
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
        query = query.gcp_pubsub_topic_overview
        args = {
          name = self.input.name.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_pubsub_topic_tags
        param "arn" {}
        args = {
          name = self.input.name.value
        }
      }
    }

  }

}

query "gcp_pubsub_topic_input" {
  sql = <<-EOQ
    select
      title as label,
      name as value,
      json_build_object(
          'project', project
      ) as tags
    from
      gcp_pubsub_topic
    order by
      title;
  EOQ
}

query "gcp_pubsub_topic_encryption" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when kms_key_name = '' then 'Disabled' else 'Enabled' end as value,
      case when kms_key_name = '' then 'Alarm' else 'Ok' end as type
    from
      gcp_pubsub_topic
    where
      name = $1;
  EOQ

  param "name" {}

}

query "gcp_pubsub_topic_labeled" {
  sql = <<-EOQ
    select
      'Topic' as label,
      case when labels is not null then 'Labeled' else 'Unlabeled' end as value,
      case when labels is not null then 'Ok' else 'Alarm' end as type
    from
      gcp_pubsub_topic
    where
      name = $1;
  EOQ

  param "name" {}

}

query "gcp_pubsub_topic_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      title as "Title",
      location as "Location",
      self_link as "Self-Link"
    from
      gcp_pubsub_topic
    where
      name = $1;
  EOQ

  param "name" {}
}

query "gcp_pubsub_topic_tags" {
  sql = <<-EOQ
    select
    jsonb_object_keys(tags) as "Key",
    tags ->> jsonb_object_keys(tags) as "Value"
  from
    gcp_pubsub_topic
  where
    name = $1;
  EOQ

  param "name" {}
}

node "gcp_pubsub_topic_node" {
  category = category.gcp_pubsub_topic

  sql = <<-EOQ
    select
      name as id,
      title as title,
      jsonb_build_object(
        'Name', name,
        'Location', location,
        'Project', project,
        'Self Link', self_link
      ) as properties
    from
      gcp_pubsub_topic
    where
      name = $1;
  EOQ

param "name" {}
}