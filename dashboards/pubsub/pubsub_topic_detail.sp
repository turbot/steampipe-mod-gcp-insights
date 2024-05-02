dashboard "pubsub_topic_detail" {

  title         = "GCP Pub/Sub Topic Detail"
  documentation = file("./dashboards/pubsub/docs/pubsub_topic_detail.md")

  tags = merge(local.pubsub_common_tags, {
    type = "Detail"
  })

  input "self_link" {
    title = "Select a topic:"
    query = query.pubsub_topic_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.pubsub_topic_encryption
      args  = [self.input.self_link.value]
    }

    card {
      width = 3
      query = query.pubsub_topic_labeled
      args  = [self.input.self_link.value]
    }
  }

  with "kubernetes_clusters_for_pubsub_topic" {
    query = query.kubernetes_clusters_for_pubsub_topic
    args  = [self.input.self_link.value]
  }

  with "iam_roles_for_pubsub_topic" {
    query = query.iam_roles_for_pubsub_topic
    args  = [self.input.self_link.value]
  }

  with "kms_keys_for_pubsub_topic" {
    query = query.kms_keys_for_pubsub_topic
    args  = [self.input.self_link.value]
  }

  with "pubsub_snapshots_for_pubsub_topic" {
    query = query.pubsub_snapshots_for_pubsub_topic
    args  = [self.input.self_link.value]
  }

  with "pubsub_subscriptions_for_pubsub_topic" {
    query = query.pubsub_subscriptions_for_pubsub_topic
    args  = [self.input.self_link.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      # node {
      #   base = node.iam_role
      #   args = {
      #     iam_role_ids = with.iam_roles_for_pubsub_topic.rows[*].role_id
      #   }
      # }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = with.kms_keys_for_pubsub_topic.rows[*].self_link
        }
      }

      node {
        base = node.kubernetes_cluster
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters_for_pubsub_topic.rows[*].cluster_id
        }
      }

      node {
        base = node.pubsub_snapshot
        args = {
          pubsub_snapshot_self_links = with.pubsub_snapshots_for_pubsub_topic.rows[*].snapshot_self_link
        }
      }

      node {
        base = node.pubsub_subscription
        args = {
          pubsub_subscription_self_links = with.pubsub_subscriptions_for_pubsub_topic.rows[*].subscription_self_link
        }
      }

      node {
        base = node.pubsub_topic
        args = {
          pubsub_topic_self_links = [self.input.self_link.value]
        }
      }

      edge {
        base = edge.kubernetes_cluster_to_pubsub_topic
        args = {
          kubernetes_cluster_ids = with.kubernetes_clusters_for_pubsub_topic.rows[*].cluster_id
        }
      }

      # edge {
      #   base = edge.pubsub_topic_to_iam_role
      #   args = {
      #     pubsub_topic_self_links = [self.input.self_link.value]
      #   }
      # }

      edge {
        base = edge.pubsub_topic_to_kms_key
        args = {
          pubsub_topic_self_links = [self.input.self_link.value]
        }
      }

      edge {
        base = edge.pubsub_topic_to_pubsub_snapshot
        args = {
          pubsub_topic_self_links = [self.input.self_link.value]
        }
      }

      edge {
        base = edge.pubsub_topic_to_pubsub_subscription
        args = {
          pubsub_topic_self_links = [self.input.self_link.value]
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
        query = query.pubsub_topic_overview
        args  = [self.input.self_link.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.pubsub_topic_tags
        args  = [self.input.self_link.value]
      }

    }
    container {
      width = 6

      table {
        title = "Subscription Details"
        query = query.pubsub_topic_subscription_details
        args  = [self.input.self_link.value]
      }

      table {
        title = "Encryption Details"
        query = query.pubsub_topic_encryption_details
        args  = [self.input.self_link.value]
      }
    }

  }

}

# Input queries

query "pubsub_topic_input" {
  sql = <<-EOQ
    select
      title as label,
      self_link as value,
      json_build_object(
        'project', project
      ) as tags
    from
      gcp_pubsub_topic
    order by
      title;
  EOQ
}

# Card queries

query "pubsub_topic_encryption" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when kms_key_name = '' then 'Disabled' else 'Enabled' end as value,
      case when kms_key_name = '' then 'alert' else 'ok' end as type
    from
      gcp_pubsub_topic
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
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
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
}

# With queries

query "kubernetes_clusters_for_pubsub_topic" {
  sql = <<-EOQ
    with pubsub_topic as (
      select
        self_link
      from
        gcp_pubsub_topic
      where
        project = split_part($1, '/', 6)
        and self_link = $1
    )
    select
      c.id::text as cluster_id
    from
      gcp_kubernetes_cluster c,
      pubsub_topic t
    where
      c.notification_config is not null
      and t.self_link like '%' || (c.notification_config -> 'pubsub' ->> 'topic') || '%';
  EOQ
}

query "iam_roles_for_pubsub_topic" {
  sql = <<-EOQ
    with iam_role as (
      select
        name
      from
        gcp_iam_role
      where
        project = split_part($1, '/', 6)
    ), pubsub_topic as (
      select
        self_link,
        iam_policy
      from
        gcp_pubsub_topic
      where
        project = split_part($1, '/', 6)
        and self_link = $1
    )
    select
      i.name as role_id
    from
      iam_role i,
      pubsub_topic t,
      jsonb_array_elements(t.iam_policy->'bindings') as roles
    where
      roles ->> 'role' = i.name;
  EOQ
}

query "kms_keys_for_pubsub_topic" {
  sql = <<-EOQ
    with kms_key as (
      select
        self_link
      from
        gcp_kms_key
    ), pubsub_topic as (
      select
        self_link,
        kms_key_name
      from
        gcp_pubsub_topic
      where
        kms_key_name <> ''
        and kms_key_name is not null
        and project = split_part($1, '/', 6)
        and self_link = $1
    )
    select
      k.self_link
    from
      pubsub_topic p,
      kms_key k
    where
      k.self_link like '%' || p.kms_key_name;
  EOQ
}

query "pubsub_snapshots_for_pubsub_topic" {
  sql = <<-EOQ
    with pubsub_snapshot as (
      select
        self_link,
        topic_name
      from
        gcp_pubsub_snapshot
      where
        project = split_part($1, '/', 6)
    ), pubsub_topic as (
      select
        self_link,
        name
      from
        gcp_pubsub_topic
      where
        project = split_part($1, '/', 6)
        and self_link = $1
    )
    select
      s.self_link as snapshot_self_link
    from
      pubsub_snapshot s,
      pubsub_topic t
    where
      s.topic_name = t.name;
  EOQ
}

query "pubsub_subscriptions_for_pubsub_topic" {
  sql = <<-EOQ
    with pubsub_subscription as (
      select
        self_link,
        topic_name
      from
        gcp_pubsub_subscription
      where
        project = split_part($1, '/', 6)
    ), pubsub_topic as (
      select
        self_link,
        name
      from
        gcp_pubsub_topic
      where
        project = split_part($1, '/', 6)
        and self_link = $1
    )
    select
      s.self_link as subscription_self_link
    from
      pubsub_subscription s,
      pubsub_topic t
    where
      s.topic_name = t.name;
  EOQ
}

# Other queries
query "pubsub_topic_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      location as "Location",
      project as "Project"
    from
      gcp_pubsub_topic
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
}

query "pubsub_topic_tags" {
  sql = <<-EOQ
    select
      jsonb_object_keys(tags) as "Key",
      tags ->> jsonb_object_keys(tags) as "Value"
    from
      gcp_pubsub_topic
    where
      project = split_part($1, '/', 6)
      and self_link = $1;
  EOQ
}

query "pubsub_topic_encryption_details" {
  sql = <<-EOQ
    select
      k.name as "KMS Key Name",
      k.key_ring_name as "Key Ring Name",
      k.create_time as "Create Time",
      k.title as "Title",
      nullif(split_part(k.rotation_period, 's', 1), '')::int / ( 60 * 60 * 24) as "Rotation Period",
      k.location as "Location"
    from
      gcp_pubsub_topic p,
      gcp_kms_key k
    where
      split_part(p.kms_key_name, 'cryptoKeys/', 2) = k.name
      and p.self_link = $1;
  EOQ
}

query "pubsub_topic_subscription_details" {
  sql = <<-EOQ
    with pubsub_subscription as (
      select
        name,
        self_link,
        topic_name,
        retain_acked_messages,
        message_retention_duration,
        dead_letter_policy_max_delivery_attempts
      from
        gcp_pubsub_subscription
      where
        project = split_part($1, '/', 6)
    ), pubsub_topic as (
      select
        self_link,
        name
      from
        gcp_pubsub_topic
      where
        project = split_part($1, '/', 6)
        and self_link = $1
    )
    select
      k.name as "Name",
      topic_name as "Topic Name",
      message_retention_duration as "Message Retention Duration",
      retain_acked_messages as "Retain Acknowledged Messages",
      dead_letter_policy_max_delivery_attempts as "Maximum Number of Delivery Attempts"
    from
      pubsub_topic p,
      pubsub_subscription k
    where
      p.name = k.topic_name;
  EOQ
}
