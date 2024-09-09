dashboard "dataplex_task_dashboard" {

  title         = "GCP Dataplex Task Dashboard"
  documentation = file("./dashboards/dataplex/docs/dataplex_task_dashboard.md")

  tags = merge(local.dataplex_common_tags, {
    type = "Dashboard"
  })

  container {

    //   # Analysis
    card {
      query = query.dataplex_task_count
      width = 2
    }

      card {
        query = query.dataplex_task_by_status
        width = 2
      }

      card {
        query = query.dataplex_task_lake_count
        width = 2
      }

      card {
        query = query.dataplex_task_notebook_count
        width = 2
      }

      card {
        query = query.dataplex_task_spark_count
        width = 2
      }

    card {
      query = query.dataplex_task_trigger_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Tasks by State"
      query = query.dataplex_task_by_state
      type  = "donut"
      width = 4

      series "count" {
        point "active" {
          color = "ok"
        }
        point "inactive" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Tasks Execution Encryption Status"
      query = query.dataplex_task_execution_encryption_enabled
      type  = "donut"
      width = 4

      series "count" {
        point "Encrypted" {
          color = "ok"
        }
        point "Not Encrypted" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Tasks by Lake"
      query = query.dataplex_task_by_lake
      type  = "column"
      width = 4
    }

    chart {
      title = "Tasks by Execution Service"
      query = query.dataplex_task_by_execution_service
      type  = "column"
      width = 4
    }

    chart {
      title = "Tasks by Location"
      query = query.dataplex_task_by_location
      type  = "column"
      width = 4
    }

    chart {
      title = "Tasks by Creation Time"
      query = query.dataplex_task_by_creation_time
      type  = "column"
      width = 4
    }

    chart {
      title = "Tasks by Project"
      query = query.dataplex_task_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Tasks by Update Time"
      query = query.dataplex_task_by_update_time
      type  = "column"
      width = 4
    }
  }

}

# Card Queries

query "dataplex_task_count" {
  sql = <<-EOQ
    select count(*) as "Tasks" from gcp_dataplex_task;
  EOQ
}

query "dataplex_task_by_status" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Active' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_dataplex_task
    where
      state = 'ACTIVE';
  EOQ
}

query "dataplex_task_lake_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Lake Count' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_dataplex_task
    group by
      lake_name;
  EOQ
}

query "dataplex_task_notebook_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Notebook Tasks' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_dataplex_task
    where
      notebook is not null;
  EOQ
}

query "dataplex_task_spark_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Spark Count' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_dataplex_task
    where
      spark is not null;
  EOQ
}

query "dataplex_task_trigger_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Trigger Count' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_dataplex_task
    where
      trigger_spec is not null;
  EOQ
}

# Assessment Queries

query "dataplex_task_by_state" {
  sql = <<-EOQ
    select
      state,
      count(*)
    from (
      select name,
        case when state = 'ACTIVE' then
          'active'
        else
          'inactive'
        end state
      from
        gcp_dataplex_task) as c
    group by
      state
    order by
      state;
  EOQ
}

query "dataplex_task_execution_encryption_enabled" {
  sql = <<-EOQ
    select
      state,
      count(*)
    from (
      select name,
        case when execution_spec -> 'kmsKey' is not null then
          'Encrypted'
        else
          'Not Encrypted'
        end state
      from
        gcp_dataplex_task) as c    
      group by
        state
      order by
        state;
  EOQ
}

# Analysis Queries

query "dataplex_task_by_lake" {
  sql = <<-EOQ
    select
      lake_name as "Lake Name",
      count(*) as "Total"
    from
      gcp_dataplex_task
    group by
      lake_name;
  EOQ
}

query "dataplex_task_by_location" {
  sql = <<-EOQ
    select
      location,
      count(*) as total
    from
      gcp_dataplex_task
    group by
      location;
  EOQ
}

query "dataplex_task_by_project" {
  sql = <<-EOQ
    select
      project,
      count(*) as total
    from
      gcp_dataplex_task
    group by
      project;
  EOQ
}

query "dataplex_task_by_creation_time" {
  sql = <<-EOQ
    select
      date_trunc('day', create_time) as "Day",
      count(*) as "Total"
    from
      gcp_dataplex_task
    group by
      "Day"
    order by
      "Day";
  EOQ
}

query "dataplex_task_by_execution_service" {
  sql = <<-EOQ
    select
      execution_status->'latestJob'->>'service' as "Execution Service",
      count(*) as "Total"
    from
      gcp_dataplex_task
    group by
      execution_status->'latestJob'->>'service'
    order by
      "Total" desc;
  EOQ
}

query "dataplex_task_by_update_time" {
  sql = <<-EOQ
    select
      date_trunc('day', update_time) as "Day",
      count(*) as "Total"
    from
      gcp_dataplex_task
    group by
      "Day"
    order by
      "Day";
  EOQ
}