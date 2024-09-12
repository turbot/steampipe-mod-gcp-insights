dashboard "bigquery_table_detail" {

  title         = "GCP BigQuery Table Detail"
  documentation = file("./dashboards/bigquery/docs/bigquery_table_detail.md")

  tags = merge(local.bigquery_common_tags, {
    type = "Detail"
  })

  input "table_id" {
    title = "Select a table:"
    query = query.bigquery_table_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.bigquery_table_size
      args  = [self.input.table_id.value]
    }

    card {
      width = 2
      query = query.bigquery_table_row_count
      args  = [self.input.table_id.value]
    }

    card {
      width = 2
      query = query.bigquery_table_last_modified
      args  = [self.input.table_id.value]
    }

    card {
      width = 2
      query = query.bigquery_table_encryption_enabled
      args  = [self.input.table_id.value]
    }

    card {
      width = 2
      query = query.bigquery_table_expiration_enabled
      args  = [self.input.table_id.value]
    }

  }


  with "bigquery_dataset_for_bigquery_table" {
    query = query.bigquery_dataset_for_bigquery_table
    args  = [self.input.table_id.value]
  }

  with "kms_keys_for_bigquery_table" {
    query = query.kms_keys_for_bigquery_table
    args  = [self.input.table_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.bigquery_table
        args = {
          bigquery_table_ids = [self.input.table_id.value]
        }
      }

      node {
        base = node.bigquery_dataset
        args = {
          bigquery_dataset_ids = with.bigquery_dataset_for_bigquery_table.rows[*].dataset_id
        }
      }

      node {
        base = node.kms_key
        args = {
          kms_key_self_links = with.kms_keys_for_bigquery_table.rows[*].self_link
        }
      }

      edge {
        base = edge.bigquery_table_to_bigquery_dataset
        args = {
          bigquery_table_ids = [self.input.table_id.value]
        }
      }

      edge {
        base = edge.bigquery_table_to_kms_key
        args = {
          bigquery_table_ids = [self.input.table_id.value]
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
        query = query.bigquery_table_overview
        args  = [self.input.table_id.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.bigquery_table_tags
        args  = [self.input.table_id.value]
      }
    }

    container {
      width = 6

      # table {
      #   title = "Labels"
      #   query = query.bigquery_table_labels
      #   args  = [self.input.table_id.value]
      # }

      table {
        title = "Clustering"
        width = 6
        query = query.bigquery_table_partitioning_clustering
        args  = [self.input.table_id.value]
      }

      table {
        title = "Time Partitioning"
        width = 6
        query = query.bigquery_table_time_partitioning
        args  = [self.input.table_id.value]
      }
    }
  }

  container {

    table {
      title = "Schema Details"
      width = 12
      query = query.bigquery_table_schema
      args  = [self.input.table_id.value]
    }

  }

}

# Input queries

query "bigquery_table_input" {
  sql = <<-EOQ
    select
      title as label,
      id::text || '/' || project as value,
      json_build_object(
        'location', location,
        'project', project,
        'id', id::text
      ) as tags
    from
      gcp_bigquery_table
    order by
      title;
  EOQ
}

# Card queries

query "bigquery_table_size" {
  sql = <<-EOQ
    select
      'Table Size (Bytes)' as label,
      num_bytes as value
    from
      gcp_bigquery_table
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}

query "bigquery_table_row_count" {
  sql = <<-EOQ
    select
      'Row Count' as label,
      num_rows as value
    from
      gcp_bigquery_table
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}
query "bigquery_table_last_modified" {
  sql = <<-EOQ
    select
      'Last Modified (Days)' as label,
      (current_date - last_modified_time::date) as value
    from
      gcp_bigquery_table
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}

query "bigquery_table_encryption_enabled" {
  sql = <<-EOQ
    select
      'Encryption' as label,
      case when kms_key_name != '' then 'Enabled' else 'Disabled' end as value,
      case when kms_key_name != '' then 'ok' else 'alert' end as type
    from
      gcp_bigquery_table
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}

query "bigquery_table_expiration_enabled" {
  sql = <<-EOQ
    select
      'Expiration' as label,
      case when expiration_time is null then 'Disabled' else 'Enabled' end as value,
      case when expiration_time is null then 'alert' else 'ok' end as type
    from
      gcp_bigquery_table
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}

# With queries

query "bigquery_dataset_for_bigquery_table" {
  sql = <<-EOQ
    select
      d.dataset_id as dataset_id
    from
      gcp_bigquery_table t,
      gcp_bigquery_dataset d
    where
      t.dataset_id = d.dataset_id
      and t.project = d.project
      and t.id = (split_part($1, '/', 1))::text
      and t.project = split_part($1, '/', 2);
  EOQ
}

query "kms_keys_for_bigquery_table" {
  sql = <<-EOQ
    select
      k.self_link
    from
      gcp_bigquery_table t,
      gcp_kms_key k
    where
      t.kms_key_name is not null
      and k.self_link like '%' || t.kms_key_name || '%'
      and t.id = (split_part($1, '/', 1))::text
      and t.project = split_part($1, '/', 2);
  EOQ
}

# Other queries

query "bigquery_table_overview" {
  sql = <<-EOQ
    select
      id::text as "ID",
      creation_time as "Creation Time",
      description as "Description",
      location as "Location",
      title as "Title",
      project as "Project"
    from
      gcp_bigquery_table
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}

query "bigquery_table_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_bigquery_table
      where
        id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2)
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
}

query "bigquery_table_schema" {
  sql = <<-EOQ
    with jsondata as (
      select
        schema_fields::json as schema_fields
      from
        gcp_bigquery_table
      where
        id = (split_part($1, '/', 1))::text
        and project = split_part($1, '/', 2)
    )
    select
      jsonb_array_elements_text(schema_fields::jsonb) as "Schema Field"
    from
      jsondata;
  EOQ
}

query "bigquery_table_partitioning_clustering" {
  sql = <<-EOQ
    select
      jsonb_array_elements_text(clustering_fields) as "Fields"
    from
      gcp_bigquery_table
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}

query "bigquery_table_external_data_configuration" {
  sql = <<-EOQ
    select
      external_data_configuration::text as "External Data Configuration"
    from
      gcp_bigquery_table
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}

query "bigquery_table_time_partitioning" {
  sql = <<-EOQ
    select
     key,
     value
    from
      gcp_bigquery_table,
      jsonb_each_text(time_partitioning)
    where
      id = (split_part($1, '/', 1))::text
      and project = split_part($1, '/', 2);
  EOQ
}