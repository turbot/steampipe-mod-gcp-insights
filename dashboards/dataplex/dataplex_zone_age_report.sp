dashboard "dataplex_zone_age_report" {

  title         = "GCP Dataplex Zone Age Report"
  documentation = file("./dashboards/dataplex/docs/dataplex_zone_age_report.md")

  tags = merge(local.dataplex_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.dataplex_zone_total_count
      width = 2
    }

    card {
      query = query.dataplex_zone_24_hours_count
      width = 2
    }

    card {
      query = query.dataplex_zone_30_days_count
      width = 2
    }

    card {
      query = query.dataplex_zone_30_90_days_count
      width = 2
    }

    card {
      query = query.dataplex_zone_90_365_days_count
      width = 2
    }

    card {
      query = query.dataplex_zone_1_year_count
      width = 2
    }

  }

  table {
    query = query.dataplex_zone_age_table
  }

}

# Query definitions for the age report

query "dataplex_zone_total_count" {
  sql = <<-EOQ
    select 
      count(*) as value,
      'Total Zones' as label
    from 
      gcp_dataplex_zone;
  EOQ
}

query "dataplex_zone_24_hours_count" {
  sql = <<-EOQ
    select 
      count(*) as value,
      '< 24 Hours' as label
    from 
      gcp_dataplex_zone
    where 
      create_time > now() - interval '1 day';
  EOQ
}

query "dataplex_zone_30_days_count" {
  sql = <<-EOQ
    select 
      count(*) as value,
      '1-30 Days' as label
    from 
      gcp_dataplex_zone
    where 
      create_time between now() - interval '30 days' and now();
  EOQ
}

query "dataplex_zone_30_90_days_count" {
  sql = <<-EOQ
    select 
      count(*) as value,
      '30-90 Days' as label
    from 
      gcp_dataplex_zone
    where 
      create_time between now() - interval '90 days' and now() - interval '30 days';
  EOQ
}

query "dataplex_zone_90_365_days_count" {
  sql = <<-EOQ
    select 
      count(*) as value,
      '90-365 Days' as label
    from 
      gcp_dataplex_zone
    where 
      create_time between now() - interval '365 days' and now() - interval '90 days';
  EOQ
}

query "dataplex_zone_1_year_count" {
  sql = <<-EOQ
    select 
      count(*) as value,
      '> 1 Year' as label
    from 
      gcp_dataplex_zone
    where 
      create_time <= now() - interval '1 year';
  EOQ
}

query "dataplex_zone_age_table" {
  sql = <<-EOQ
    select 
      name as "Zone Name",
      now()::date - create_time::date as "Age in Days",
      create_time as "Creation Time",
      project as "Project",
      location as "Location",
      self_link as "Self-Link"
    from 
      gcp_dataplex_zone
    order by 
      create_time, name;
  EOQ
}