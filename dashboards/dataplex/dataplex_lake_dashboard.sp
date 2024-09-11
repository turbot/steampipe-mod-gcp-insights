dashboard "dataplex_lake_dashboard" {

  title         = "GCP Dataplex Lake Dashboard"
  documentation = file("./dashboards/dataplex/docs/dataplex_lake_dashboard.md")

  tags = merge(local.dataplex_common_tags, {
    type = "Dashboard"
  })

  container {

    # Analysis
    card {
      query = query.dataplex_lake_count
      width = 2
    }

    card {
      query = query.dataplex_lake_status
      width = 2
    }

    card {
      query = query.dataplex_lake_metastore_configured
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Lakes by State"
      query = query.dataplex_lake_by_state
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
      title = "Metastore Status"
      query = query.dataplex_lake_metastore_status
      type  = "donut"
      width = 4

      series "count" {
        point "configured" {
          color = "ok"
        }
        point "not configured" {
          color = "alert"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Lakes by Project"
      query = query.dataplex_lake_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Lakes by Location"
      query = query.dataplex_lake_by_location
      type  = "column"
      width = 4
    }

    chart {
      title = "Lakes by Service Account"
      query = query.dataplex_lake_by_service_account
      type  = "column"
      width = 4
    }

    chart {
      title = "Lakes by Creation Time"
      query = query.dataplex_lake_by_creation_time
      type  = "column"
      width = 4
    }

    chart {
      title = "Lakes by Update Time"
      query = query.dataplex_lake_by_update_time
      type  = "column"
      width = 4
    }
  }
}

# Card Queries
query "dataplex_lake_count" {
  sql = <<-EOQ
    select count(*) as "Lakes" from gcp_dataplex_lake;
  EOQ
}

query "dataplex_lake_status" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Active' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_dataplex_lake
    where
      state = 'ACTIVE';
  EOQ
}

query "dataplex_lake_metastore_configured" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Metastore' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_dataplex_lake
    where
      metastore ->> 'service' is not null;
  EOQ
}

# Analysis Queries
query "dataplex_lake_by_location" {
  sql = <<-EOQ
    select
      location,
      count(*) as "Total"
    from
      gcp_dataplex_lake
    group by
      location;
  EOQ
}

query "dataplex_lake_by_service_account" {
  sql = <<-EOQ
    select
      service_account,
      count(*) as "Total"
    from
      gcp_dataplex_lake
    group by
      service_account;
  EOQ
}

query "dataplex_lake_by_project" {
  sql = <<-EOQ
    select
      project,
      count(*) as "Total"
    from
      gcp_dataplex_lake
    group by
      project;
  EOQ
}

query "dataplex_lake_by_creation_time" {
  sql = <<-EOQ
    select
      create_time,
      count(*) as "Total"
    from
      gcp_dataplex_lake
    group by
      create_time;
  EOQ
}

query "dataplex_lake_by_update_time" {
  sql = <<-EOQ
    select
      update_time,
      count(*) as "Total"
    from
      gcp_dataplex_lake
    group by
      update_time;
  EOQ
}

# Assessment Queries

query "dataplex_lake_by_state" {
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
        gcp_dataplex_lake) as c
    group by
      state
    order by
      state;
  EOQ
}

query "dataplex_lake_metastore_status" {
  sql = <<-EOQ
    select
      metastore_status,
      count(*)
    from (
      select name,
        case when metastore ->> 'service' is not null then
          'configured'
        else
          'not configured'
        end metastore_status
      from
        gcp_dataplex_lake) as c
    group by
      metastore_status
    order by
      metastore_status;
  EOQ
}