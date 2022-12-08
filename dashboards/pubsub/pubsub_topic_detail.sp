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
      title = "Relationships"
      type  = "graph"

      with "iam_roles" {
        sql = <<-EOQ
          select
            i.role_id as role_id
          from
            gcp_iam_role i,
            gcp_pubsub_topic t,
            jsonb_array_elements(t.iam_policy->'bindings') as roles
          where
            roles ->> 'role' = i.name
            and t.name = $1;
        EOQ

        args = [self.input.name.value]
      }

      with "kms_keys" {
        sql = <<-EOQ
          select
            split_part(p.kms_key_name, 'cryptoKeys/', 2) as key_name
          from
            gcp_pubsub_topic p
          where
            p.name = $1;
        EOQ

        args = [self.input.name.value]
      }

      with "kubernetes_clusters" {
        sql = <<-EOQ
          select
            c.name as cluster_name
          from
            gcp_kubernetes_cluster c,
            gcp_pubsub_topic t
          where
            t.name = $1
            and c.notification_config is not null
            and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%';
        EOQ

        args = [self.input.name.value]
      }

      with "pubsub_snapshots" {
        sql = <<-EOQ
          select
            s.name as snapshot_name
          from
            gcp_pubsub_snapshot s
          where
            s.topic_name = $1;
        EOQ

        args = [self.input.name.value]
      }

      with "pubsub_subscriptions" {
        sql = <<-EOQ
          select
            s.name as subscription_name
          from
            gcp_pubsub_subscription s
          where
            s.topic_name = $1;
        EOQ

        args = [self.input.name.value]
      }

      nodes = [
        node.iam_role,
        node.kms_key,
        node.kubernetes_cluster,
        node.pubsub_snapshot,
        node.pubsub_subscription,
        node.pubsub_topic
      ]

      edges = [
        edge.kubernetes_cluster_to_pubsub_topic,
        edge.pubsub_topic_to_iam_role,
        edge.pubsub_topic_to_kms_key,
        edge.pubsub_topic_to_pubsub_snapshot,
        edge.pubsub_topic_to_pubsub_subscription
      ]

      args = {
        iam_role_ids              = with.iam_roles.rows[*].role_id
        kms_key_names             = with.kms_keys.rows[*].key_name
        kubernetes_cluster_names  = with.kubernetes_clusters.rows[*].cluster_name
        pubsub_snapshot_names     = with.pubsub_snapshots.rows[*].snapshot_name
        pubsub_subscription_names = with.pubsub_subscriptions.rows[*].subscription_name
        pubsub_topic_names        = [self.input.name.value]
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