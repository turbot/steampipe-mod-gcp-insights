dashboard "gcp_pubsub_topic_dashboard" {

  title         = "GCP Pub/Sub Topic Dashboard"
  documentation = file("./dashboards/pubsub/docs/pubsub_topic_dashboard.md")

  tags = merge(local.pubsub_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.gcp_pubsub_topic_count
      width = 2
    }

    card {
      query = query.gcp_pubsub_topic_encryption_count
      width = 2
    }

    card {
      query = query.gcp_pubsub_topic_labeled_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Encryption Status"
      query = query.gcp_pubsub_topic_encryption_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Labeling Status"
      query = query.gcp_pubsub_topic_labeled_status
      type  = "donut"
      width = 3

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Topic by Project"
      query = query.gcp_pubsub_topic_by_project
      type  = "column"
      width = 3
    }

    chart {
      title = "Topic by Location"
      query = query.gcp_pubsub_topic_by_location
      type  = "column"
      width = 3
    }
    
    chart {
      title = "Topic by Subscription"
      query = query.gcp_pubsub_topic_by_subscription
      type  = "column"
      width = 3
    }

    // chart {
    //   title = "Topic by Public Access Role"
    //   query = query.gcp_pubsub_topic_by_public_access_role
    //   type  = "column"
    //   width = 3
    // }
  }

}

# Card Queries

query "gcp_pubsub_topic_count" {
  sql = <<-EOQ
    select count(*) as "Topics" from gcp_pubsub_topic;
  EOQ
}

query "gcp_pubsub_topic_encryption_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Unencrypted' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
      gcp_pubsub_topic
    where
      kms_key_name = '';
  EOQ
}

query "gcp_pubsub_topic_labeled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Labeling Disabled' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_pubsub_topic
    where
      labels is not null;
  EOQ
}

# Assessment Queries

query "gcp_pubsub_topic_encryption_status" {
  sql = <<-EOQ
    select
      encryption_status,
      count(*)
    from (
      select name,
        case when kms_key_name = '' then
          'disabled'
        else
          'enabled'
        end encryption_status
      from
        gcp_pubsub_topic) as c
    group by
      encryption_status
    order by
      encryption_status;
  EOQ
}

query "gcp_pubsub_topic_labeled_status" {
  sql = <<-EOQ
    select
      label_status,
      count(*)
    from (
      select name,
        case when labels is not null then
          'enabled'
        else
          'disabled'
        end label_status
      from
        gcp_pubsub_topic) as c
    group by
      label_status
    order by
      label_status;
  EOQ
}

# Analysis Queries

query "gcp_pubsub_topic_by_project" {
  sql = <<-EOQ
    select
      p.title as "project",
      count(i.*) as "total"
    from
      gcp_pubsub_topic as i,
      gcp_project as p
    where
      p.project_id = i.project
    group by
      p.title
    order by count(i.*) desc;
  EOQ
}

query "gcp_pubsub_topic_by_location" {
  sql = <<-EOQ
    select
      location,
      count(i.*) as total
    from
      gcp_pubsub_topic as i
    group by
      location;
  EOQ
}

query "gcp_pubsub_topic_by_subscription" {
  sql = <<-EOQ
    select
      k.topic_name,
      count(k.*) as subscription_count
    from
      gcp_pubsub_subscription k
    group by
      k.topic_name having topic_name != '_deleted-topic_';
  EOQ
}

query "gcp_pubsub_topic_by_public_access_role" {
  sql = <<-EOQ
    select
      name,
      count(*) as public_access_role_count
    from
      gcp_pubsub_topic,
      jsonb_array_elements(iam_policy -> 'bindings') as s,
      jsonb_array_elements_text(s -> 'members') as entity
    where
      entity = 'allUsers'
      or entity = 'allAuthenticatedUsers' 
    group by 
      name;
  EOQ
}
