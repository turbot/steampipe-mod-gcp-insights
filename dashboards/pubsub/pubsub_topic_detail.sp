dashboard "pubsub_topic_detail" {

  title         = "GCP Pub/Sub Topic Detail"
  documentation = file("./dashboards/pubsub/docs/pubsub_topic_detail.md")

  tags = merge(local.pubsub_common_tags, {
    type = "Detail"
  })

  input "name" {
    title = "Select a topic:"
    query = query.pubsub_topic_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.pubsub_topic_encryption
      args = {
        name = self.input.name.value
      }
    }

    card {
      width = 2
      query = query.pubsub_topic_labeled
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
        node.pubsub_topic,
        node.pubsub_topic_to_kms_key,
        node.pubsub_topic_from_kubernetes_cluster,
        node.pubsub_topic_to_iam_role,
        node.pubsub_topic_to_pubsub_subscription,
        node.pubsub_topic_to_pubsub_snapshot
      ]

      edges = [
        edge.pubsub_topic_to_kms_key,
        edge.pubsub_topic_to_kubernetes_cluster,
        edge.pubsub_topic_to_iam_role,
        edge.pubsub_topic_to_pubsub_subscription,
        edge.pubsub_topic_to_pubsub_snapshot
      ]

      args = {
        name               = self.input.name.value
        pubsub_topic_names = [self.input.name.value]
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
        query = query.pubsub_topic_overview
        args = {
          name = self.input.name.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.pubsub_topic_tags
        param "name" {}
        args = {
          name = self.input.name.value
        }
      }

    }
    container {
      width = 6

      table {
        title = "Subscription Details"
        query = query.pubsub_topic_subscription_details
        param "name" {}
        args = {
          name = self.input.name.value
        }
      }

      table {
        title = "Encryption Details"
        query = query.pubsub_topic_encryption_details
        param "name" {}
        args = {
          name = self.input.name.value
        }
      }
    }

  }

}

query "pubsub_topic_input" {
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

query "pubsub_topic_encryption" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when kms_key_name = '' then 'Disabled' else 'Enabled' end as value,
      case when kms_key_name = '' then 'alert' else 'ok' end as type
    from
      gcp_pubsub_topic
    where
      name = $1;
  EOQ

  param "name" {}

}

query "pubsub_topic_labeled" {
  sql = <<-EOQ
    select
      'Labeling' as label,
      case when labels is not null then 'Enabeled' else 'Disabled' end as value,
      case when labels is not null then 'ok' else 'alert' end as type
    from
      gcp_pubsub_topic
    where
      name = $1;
  EOQ

  param "name" {}

}

query "pubsub_topic_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      location as "Location",
      project as "Project"
    from
      gcp_pubsub_topic
    where
      name = $1;
  EOQ

  param "name" {}
}

query "pubsub_topic_tags" {
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

query "pubsub_topic_encryption_details" {
  sql = <<-EOQ
    select
      k.name as "KMS Key Name",
      k.key_ring_name as "Key Ring Name",
      k.create_time as "Create Time",
      k.title as "Title",
      NULLIF(SPLIT_PART(k.rotation_period, 's', 1), '')::int / ( 60 * 60 * 24) as "Rotation Period",
      k.location as "Location"
    from
      gcp_pubsub_topic p,
      gcp_kms_key k
    where
      split_part(p.kms_key_name, 'cryptoKeys/', 2) = k.name
      and p.name = $1;
  EOQ

  param "name" {}
}

query "pubsub_topic_subscription_details" {
  sql = <<-EOQ
    select
      k.name as "Name",
      topic_name as "Topic Name",
      message_retention_duration as "Message Retention Duration",
      retain_acked_messages as "Retain Acknowledged Messages",
      dead_letter_policy_max_delivery_attempts as "Maximum Number of Delivery Attempts"
    from
      gcp_pubsub_topic p,
      gcp_pubsub_subscription k
    where
      p.name = k.topic_name
      and p.name = $1;
  EOQ

  param "name" {}
}

node "pubsub_topic" {
  category = category.pubsub_topic

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Name', name,
        'Location', location,
        'KMS Key', kms_key_name
      ) as properties
    from
      gcp_pubsub_topic
    where
      name = any($1);
  EOQ

  param "pubsub_topic_names" {}
}

node "pubsub_topic_to_kms_key" {
  category = category.kms_key

  sql = <<-EOQ
    select
      concat(k.name, '_key') as id,
      k.title,
      jsonb_build_object(
        'Name', k.name,
        'Location', k.location,
        'Project', k.project,
        'Self Link', k.self_link
      ) as properties
    from
      gcp_pubsub_topic p,
      gcp_kms_key k
    where
      split_part(p.kms_key_name, 'cryptoKeys/', 2) = k.name
      and p.name = $1;
  EOQ

  param "name" {}
}

edge "pubsub_topic_to_kms_key" {
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
      and p.name = $1;
  EOQ

  param "name" {}
}

node "pubsub_topic_from_kubernetes_cluster" {
  category = category.kubernetes_cluster

  sql = <<-EOQ
    select
      c.name as id,
      c.title,
      jsonb_build_object(
        'Name', c.name,
        'Location', c.location
      ) as properties
    from
      gcp_kubernetes_cluster c,
      gcp_pubsub_topic t
    where
      t.name = $1
      and c.notification_config is not null
      and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%';
  EOQ

  param "name" {}
}

edge "pubsub_topic_to_kubernetes_cluster" {
  title = "notifies"

  sql = <<-EOQ
    select
      c.name as from_id,
      t.name as to_id
    from
      gcp_kubernetes_cluster c,
      gcp_pubsub_topic t
    where
      t.name = $1
      and c.notification_config is not null
      and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%';
  EOQ

  param "name" {}
}

node "pubsub_topic_to_iam_role" {
  category = category.iam_role

  sql = <<-EOQ
  with iam_role as (
    select
      t.name,
      roles->>'role' as role
    from
      gcp_pubsub_topic t,
      jsonb_array_elements(t.iam_policy->'bindings') as roles
  )
    select
      i.role_id as id,
      i.title,
      jsonb_build_object(
        'Name', i.name,
        'Role ID', i.role_id,
        'Location', i.location,
        'Project', i.project,
        'Stage', i.stage,
        'Description', i.description
      ) as properties
    from
      iam_role as t join gcp_iam_role i on t.role = i.name
    where
      t.name = $1;
  EOQ

  param "name" {}
}

edge "pubsub_topic_to_iam_role" {
  title = "assumes"

  sql = <<-EOQ
  with iam_role as (
    select
      t.name,
      roles->>'role' as role
    from
      gcp_pubsub_topic t,
      jsonb_array_elements(t.iam_policy->'bindings') as roles
  )
    select
      t.name as from_id,
      i.role_id as to_id,
      jsonb_build_object(
        'Name', i.name,
        'Role ID', i.role_id,
        'Location', i.location,
        'Project', i.project,
        'Stage', i.stage,
        'Description', i.description
      ) as properties
    from
      iam_role as t join gcp_iam_role i on t.role = i.name
    where
      t.name = $1;
  EOQ

  param "name" {}
}

node "pubsub_topic_to_pubsub_subscription" {
  category = category.pubsub_subscription

  sql = <<-EOQ
  select
      k.name as id,
      k.title,
      jsonb_build_object(
        'Name', k.name,
        'Location', k.location,
        'Project', k.project,
        'Self Link', k.self_link
      ) as properties
    from
      gcp_pubsub_topic p,
      gcp_pubsub_subscription k
    where
      p.name = k.topic_name
      and p.name = $1;
  EOQ

  param "name" {}
}

edge "pubsub_topic_to_pubsub_subscription" {
  title = "subscribed to"

  sql = <<-EOQ
  select
      s.name as to_id,
      t.name as from_id
    from
      gcp_pubsub_topic t,
      gcp_pubsub_subscription s
    where
      t.name = s.topic_name
      and t.name = $1;
  EOQ

  param "name" {}
}

node "pubsub_topic_to_pubsub_snapshot" {
  category = category.pubsub_subscription

  sql = <<-EOQ
  select
      k.name as id,
      k.title,
      jsonb_build_object(
        'Name', k.name,
        'Location', k.location,
        'Project', k.project,
        'Self Link', k.self_link
      ) as properties
    from
      gcp_pubsub_topic p,
      gcp_pubsub_snapshot k
    where
      k.topic_name = $1;
  EOQ

  param "name" {}
}

edge "pubsub_topic_to_pubsub_snapshot" {
  title = "snapshot"

  sql = <<-EOQ
  select
      s.name as from_id,
      k.name as to_id
    from
      gcp_pubsub_topic t,
      gcp_pubsub_snapshot k,
      gcp_pubsub_subscription s
    where
      t.name = $1
      and t.name = $1;
  EOQ

  param "name" {}
}
