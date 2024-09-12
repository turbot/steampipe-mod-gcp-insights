dashboard "dataplex_zone_dashboard" {

  title         = "GCP Dataplex Zone Dashboard"
  documentation = file("./dashboards/dataplex/docs/dataplex_zone_dashboard.md")

  tags = merge(local.dataplex_common_tags, {
    type = "Dashboard"
  })

  container {

    // # Analysis
    card {
      query = query.dataplex_zone_count
      width = 2
    }

    card {
      query = query.dataplex_zone_by_state
      width = 2
    }

    card {
      query = query.dataplex_zone_by_lake
      width = 2
    }
  }

  container {

    title = "Assessments"

    chart {
      title = "Zones by State"
      query = query.dataplex_zone_by_state_chart
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
      title = "Zones by Type"
      query = query.dataplex_zone_by_type_chart
      type  = "donut"
      width = 4
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Zones by Location"
      query = query.dataplex_zone_by_location_chart
      type  = "column"
      width = 4
    }

    chart {
      title = "Zones by Lake"
      query = query.dataplex_zone_by_lake_chart
      type  = "column"
      width = 4
    }

    chart {
      title = "Zones by Creation Time"
      query = query.dataplex_zone_by_creation_time
      type  = "column"
      width = 4
    }

    chart {
      title = "Zones by Update Time"
      query = query.dataplex_zone_by_update_time
      type  = "column"
      width = 4
    }

  }

}

# Queries for Dashboard

query "dataplex_zone_count" {
  sql = <<-EOQ
    select count(*) as "Total Zones" from gcp_dataplex_zone;
  EOQ
}

query "dataplex_zone_by_state" {
  sql = <<-EOQ
    select 
      count(*) as value,
      'Active' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from 
      gcp_dataplex_zone
    group by 
      state;
  EOQ
}

query "dataplex_zone_by_lake" {
  sql = <<-EOQ
    select 
      count(*) as value,
      'Lake Count' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from 
      gcp_dataplex_zone
    group by 
      lake_name;
  EOQ
}

query "dataplex_zone_by_state_chart" {
  sql = <<-EOQ
    select
      state,
      count(*)
    from (
      select name,
        case when state = 'ACTIVE' then 'active' else 'inactive' end as state
      from gcp_dataplex_zone
    ) as c
    group by state
    order by state;
  EOQ
}

query "dataplex_zone_by_type_chart" {
  sql = <<-EOQ
    select 
      type,
      count(*)
    from 
      gcp_dataplex_zone
    group by type
    order by type;
  EOQ
}

query "dataplex_zone_by_location_chart" {
  sql = <<-EOQ
    select 
      location,
      count(*) as value
    from 
      gcp_dataplex_zone
    group by location;
  EOQ
}

query "dataplex_zone_by_lake_chart" {
  sql = <<-EOQ
    select 
      lake_name,
      count(*) as value
    from 
      gcp_dataplex_zone
    group by lake_name;
  EOQ
}

query "dataplex_zone_by_creation_time" {
  sql = <<-EOQ
    select 
      date_trunc('day', create_time) as "Creation Day",
      count(*) as value
    from 
      gcp_dataplex_zone
    group by "Creation Day"
    order by "Creation Day";
  EOQ
}

query "dataplex_zone_by_update_time" {
  sql = <<-EOQ
    select 
      date_trunc('day', update_time) as "Update Day",
      count(*) as value
    from 
      gcp_dataplex_zone
    group by "Update Day"
    order by "Update Day";
  EOQ
}