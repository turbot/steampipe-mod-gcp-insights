dashboard "dataplex_task_detail" {

  title         = "GCP Dataplex Task Detail"
  documentation = file("./dashboards/dataplex/docs/dataplex_task_detail.md")

  tags = merge(local.dataplex_common_tags, {
    type = "Detail"
  })

  input "task_id" {
    title = "Select a Dataplex Task:"
    query = query.dataplex_task_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.dataplex_task_name
      args  = [self.input.task_id.value]
    }

    card {
      width = 2
      query = query.dataplex_task_state
      args  = [self.input.task_id.value]
    }

    card {
      width = 2
      query = query.dataplex_task_trigger_type
      type  = "info"
      args  = [self.input.task_id.value]
    }

    card {
      width = 2
      query = query.dataplex_task_execution_service
      type  = "info"
      args  = [self.input.task_id.value]
    }

    card {
      width = 2
      query = query.dataplex_task_execution_status
      type  = "info"
      args  = [self.input.task_id.value]
    }

  }

  with "dataplex_lake_for_dataplex_task" {
    query = query.dataplex_lake_for_dataplex_task
    args  = [self.input.task_id.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.dataplex_task
        args = {
          dataplex_task_ids = [self.input.task_id.value]
        }
      }

      node {
        base = node.dataplex_lake
        args = {
          dataplex_lake_self_links = with.dataplex_lake_for_dataplex_task.rows[*].self_link
        }
      }

      edge {
        base = edge.dataplex_task_to_dataplex_lake
        args = {
          dataplex_task_ids = [self.input.task_id.value]
        }
      }
    }
  }

  container {

    container {

      table {
        title = "Overview"
        width = 4
        type  = "line"
        query = query.dataplex_task_overview
        args  = [self.input.task_id.value]
      }

      table {
        title = "Tags"
        width = 4
        query = query.dataplex_task_tags
        args  = [self.input.task_id.value]
      }

      table {
        title = "Trigger Details"
        width = 4
        query = query.dataplex_task_trigger_details
        args  = [self.input.task_id.value]
      }
    }

    container {

      table {
        title = "Execution Status Details"
        query = query.dataplex_task_execution_status_details
        args  = [self.input.task_id.value]
      }

      table {
        title = "Related Lakes"
        query = query.dataplex_task_related_lakes
        args  = [self.input.task_id.value]
      }

    }
  }
}

# Input query

query "dataplex_task_input" {
  sql = <<-EOQ
    select
      display_name as label,
      self_link as value,
      json_build_object(
        'project', project,
        'uid', uid::text
      ) as tags
    from
      gcp_dataplex_task
    order by
      display_name;
  EOQ
}

# Card queries

query "dataplex_task_name" {
  sql = <<-EOQ
    select
      'Task Name' as label,
      display_name as value
    from
      gcp_dataplex_task
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_task_state" {
  sql = <<-EOQ
    select
      'Task State' as label,
      case when state = 'ACTIVE' then 'Active' else 'Not Active' end as value,
      case when state = 'ACTIVE' then 'ok' else 'alert' end as type
    from
      gcp_dataplex_task
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_task_trigger_type" {
  sql = <<-EOQ
    select
      'Trigger Type' as label,
      trigger_spec -> 'type'  as value
    from
      gcp_dataplex_task
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_task_execution_service" {
  sql = <<-EOQ
    select
      'Execution Type' as label,
      execution_status -> 'latestJob' ->> 'service' as value
    from
      gcp_dataplex_task
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_task_execution_status" {
  sql = <<-EOQ
    select
      'Execution Status' as label,
      execution_status -> 'latestJob' ->> 'state' as value
    from
      gcp_dataplex_task
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

# Table queries

query "dataplex_task_overview" {
  sql = <<-EOQ
    select
      uid as "UID",
      display_name as "Task Name",
      location as "Location",
      project as "Project ID",
      create_time as "Creation Time",
      update_time as "Update Time",
      notebook as "Notebook",
      spark as "Spark"
    from
      gcp_dataplex_task
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_task_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_dataplex_task
      where
        self_link = $1
      and project = split_part($1, '/', 6)
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

query "dataplex_task_trigger_details" {
  sql = <<-EOQ
    select
      trigger_spec -> 'maxRetries' as "Trigger Max Retries",
      trigger_spec -> 'schedule' as "Trigger Schedule",
      trigger_spec -> 'startTime' as "Trigger Start Time"
    from
      gcp_dataplex_task
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_task_execution_status_details" {
  sql = <<-EOQ
    select
      execution_status -> 'latestJob' ->> 'name' as "Job Name",
      execution_status -> 'latestJob' -> 'executionSpec' ->> 'kmsKey' as "KMS Key",
      execution_status -> 'latestJob' -> 'executionSpec' ->> 'maxJobExecutionLifetime' as "Max Job Execution Lifetime",
      execution_status -> 'latestJob' ->> 'uid' as "Job UID",
      execution_status -> 'latestJob' ->> 'service' as "Service",
      execution_status -> 'latestJob' ->> 'state' as "State",
      execution_status -> 'latestJob' -> 'executionSpec' ->> 'serviceAccount' as "Service Account"
    from
      gcp_dataplex_task
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_task_related_lakes" {
  sql = <<-EOQ
    select
      t.lake_name as "Lake Name",
      l.project as "Project",
      l.location as "Location",
      l.state as "State",
      l.create_time as "Create Time",
      l.metastore_status as "Metastore Status"
    from
      gcp_dataplex_task as t,
      gcp_dataplex_lake as l
    where
      t.self_link = $1
      and t.project = split_part($1, '/', 6)
      and l.name = t.lake_name;
  EOQ
}

query "dataplex_lake_for_dataplex_task" {
  sql = <<-EOQ
    select
      l.self_link as self_link
    from
      gcp_dataplex_task as t,
      gcp_dataplex_lake as l
    where
      t.self_link = $1
      and t.project = split_part($1, '/', 6)
      and l.name = t.lake_name;
  EOQ
}