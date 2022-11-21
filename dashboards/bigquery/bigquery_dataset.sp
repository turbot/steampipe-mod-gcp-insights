dashboard "gcp_bigquery_dataset_detail" {

  title         = "GCP BigQuery Dataset"
  documentation = file("./dashboards/sql/docs/gcp_sql_database_instance_detail.md")

  tags = merge(local.bigquery_common_tags, {
    type = "Detail"
  })

  input "bigquery_dataset_id" {
    title = "Select a BigQuery Dataset ID:"
    query = query.gcp_bigquery_dataset_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_bigquery_dataset_partition_expiration_in_days
      args = {
        id = self.input.bigquery_dataset_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_bigquery_dataset_table_expiration_in_days
      args = {
        id = self.input.bigquery_dataset_id.value
      }
    }

    card {
      width = 2
      query = query.gcp_bigquery_dataset_encryption_status
      args = {
        id = self.input.bigquery_dataset_id.value
      }
    }

  }

  container {
    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      nodes = [
        node.gcp_bigquery_dataset_node,
        node.gcp_bigquery_dataset_to_kms_key_node
      ]

      edges = [
        edge.gcp_bigquery_dataset_to_kms_key_edge
      ]

      args = {
        id = self.input.bigquery_dataset_id.value
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
        query = query.gcp_bigquery_dataset_input_overview
        args = {
          id = self.input.bigquery_dataset_id.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_bigquery_dataset_tags
        args = {
          id = self.input.bigquery_dataset_id.value
        }
      }
    }

    container {
      width = 6

      table {
        title = "Dataset Access"
        query = query.gcp_bigquery_dataset_access
        args = {
          id = self.input.bigquery_dataset_id.value
        }
      }
    }
  }
}

query "gcp_bigquery_dataset_input" {
  sql = <<-EOQ
    select
      title as label,
      id as value,
      json_build_object(
        'location', location,
        'project', project
      ) as tags
    from
      gcp_bigquery_dataset
    order by
      title;
  EOQ
}

query "gcp_bigquery_dataset_partition_expiration_in_days" {
  sql = <<-EOQ
    select
      'Default Partition Expiration (Days)' as label,
      default_partition_expiration_ms/(1000*60*60*24) as value
    from
      gcp_bigquery_dataset
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_bigquery_dataset_table_expiration_in_days" {
  sql = <<-EOQ
    select
      'Default Table Expiration (Days)' as label,
      default_table_expiration_ms/(1000*60*60*24) as value
    from
      gcp_bigquery_dataset
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_bigquery_dataset_encryption_status" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when kms_key_name is null then 'Disabled' else 'Enabled' end as value,
      case when kms_key_name is null then 'alert' else 'ok' end as type
    from
      gcp_bigquery_dataset
    where
      id = $1;
  EOQ

  param "id" {}
}

node "gcp_bigquery_dataset_node" {
  category = category.gcp_bigquery_dataset

  sql = <<-EOQ
    select
      id::text,
      title,
      jsonb_build_object(
        'ID', id,
        'Name', title,
        'Created Time', creation_time,
        'Last Modified Time', last_modified_time,
        'Encryption Key', kms_key_name
      ) as properties
    from
      gcp_bigquery_dataset
    where
      id = $1;
  EOQ

  param "id" {}
}

node "gcp_bigquery_dataset_to_kms_key_node" {
  category = category.gcp_kms_key

  sql = <<-EOQ
    select
      d.kms_key_name as id,
      k.title,
      jsonb_build_object(
        'Name', k.name,
        'Created Time', k.create_time,
        'Key Ring Name', k.key_ring_name,
        'Purpose', k.purpose,
        'Location', k.location
      ) as properties
    from
      gcp_bigquery_dataset d,
      gcp_kms_key k
    where
      d.id = $1
      and d.kms_key_name is not null
      and split_part(d.kms_key_name, '/', 8) = k.name;
  EOQ

  param "id" {}
}

edge "gcp_bigquery_dataset_to_kms_key_edge" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      kms_key_name as to_id,
      id as from_id
    from
      gcp_bigquery_dataset
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_bigquery_dataset_input_overview" {
  sql = <<-EOQ
    select
      title as "Name",
      id as "ID",
      description as "Description",
      creation_time as "Creation Time",
      last_modified_time as "Last Modified Time",
      self_link as "Self Link",
      location as "Location",
      project as "Project ID"
    from
      gcp_bigquery_dataset
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_bigquery_dataset_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_bigquery_dataset
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

query "gcp_bigquery_dataset_access" {
  sql = <<-EOQ
    select
      a ->> 'role' as "Role",
      a ->> 'userByEmail' as "User by Email",
      a ->> 'groupByEmail' as "Group by Email",
      a ->> 'domain' as "Domain",
      a ->> 'specialGroup' as "Special Group",
      a ->> 'iamMember' as "IAM Member",
      a -> 'view' as "Table",
      a -> 'routine' as "Routine",
      a -> 'dataset' as "Dataset"
    from
      gcp_bigquery_dataset,
      jsonb_array_elements(access) as a
    where
      id = $1;
  EOQ

  param "id" {}
}
