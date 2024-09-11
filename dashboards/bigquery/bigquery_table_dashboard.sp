dashboard "bigquery_table_dashboard" {

  title         = "GCP BigQuery Table Dashboard"
  documentation = file("./dashboards/bigquery/docs/bigquery_table_dashboard.md")

  tags = merge(local.bigquery_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.bigquery_table_count
      width = 2
    }

    card {
      query = query.bigquery_table_storage_total
      width = 2
    }

    card {
      query = query.bigquery_table_row_count_total
      width = 2
    }

    card {
      query = query.bigquery_table_expired_count
      width = 2
    }

    card {
      query = query.bigquery_table_encryption_disabled_count
      width = 2
    }

  }

  container {

    title = "Assessments"

    chart {
      title = "Table Encryption Status"
      query = query.bigquery_table_encryption_status
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
      title = "Table Expiration Status"
      query = query.bigquery_table_expiration_status
      type  = "donut"
      width = 3

      series "count" {
        point "expired" {
          color = "alert"
        }
        point "active" {
          color = "ok"
        }
      }
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Tables by Project"
      query = query.bigquery_table_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Tables by Location"
      query = query.bigquery_table_by_location
      type  = "column"
      width = 4

      series "total" {
        color = "purple"
      }
    }

    chart {
      title = "Tables by Dataset"
      query = query.bigquery_table_by_dataset
      type  = "column"
      width = 4
    }
  
    chart {
      title = "Tables by Age"
      query = query.bigquery_table_by_creation_month
      type  = "column"
      width = 4

      series "count" {
        color = "yellow"
      }
    }

    chart {
      title = "Tables by Clustering"
      query = query.bigquery_table_by_clustering
      type  = "column"
      width = 4
    }

    chart {
      title = "Tables by Partitioning By Time"
      query = query.bigquery_table_by_partinioning_time
      type  = "column"
      width = 4

      series "total" {
        color = "green"
      }
    }

    chart {
      title = "Tables by Partitioning By Range"
      query = query.bigquery_table_by_partinioning_range
      type  = "column"
      width = 4
    }

  }

  container {

    title = "Storage & Performance"

    chart {
      title = "Storage by Project (GB)"
      query = query.bigquery_table_storage_by_project
      type  = "column"
      width = 4

      series "GB" {
        color = "olive"
      }
    }

    chart {
      title = "Storage by Location (GB)"
      query = query.bigquery_table_storage_by_location
      type  = "column"
      width = 4

      series "GB" {
        color = "maroon"
      }
    }

    chart {
      title = "Storage by Dataset (GB)"
      query = query.bigquery_table_storage_by_dataset
      type  = "column"
      width = 4

      series "GB" {
        color = "darkblue"
      }
    }

    chart {
      title = "Top 10 Tables by Size (Bytes)"
      query = query.bigquery_table_top_10_by_size
      type  = "column"
      width = 6

      series "Size (Bytes)" {
        color = "pink"
      }
    }

    chart {
      title = "Top 10 Tables by Row Count"
      query = query.bigquery_table_top_10_by_row_count
      type  = "bar"
      width = 6

      series "Row Count" {
        color = "teal"
      }
    }

  }
}

# Card Queries

query "bigquery_table_count" {
  sql = <<-EOQ
    select count(*) as "Tables" from gcp_bigquery_table;
  EOQ
}

query "bigquery_table_storage_total" {
  sql = <<-EOQ
    select
      sum(num_bytes) as "Total Storage (Bytes)"
    from
      gcp_bigquery_table;
  EOQ
}

query "bigquery_table_row_count_total" {
  sql = <<-EOQ
    select
      sum(num_rows) as "Total Rows"
    from
      gcp_bigquery_table;
  EOQ
}

query "bigquery_table_expired_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Not Expired' as label,
      case 
        when sum(case when expiration_time < current_timestamp then 1 else 0 end) > 0 
        then 'alert' 
        else 'ok' 
      end as "type"
    from
      gcp_bigquery_table;
  EOQ
}

query "bigquery_table_encryption_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Encrypted' as label,
      case count(*) when 0 then 'alert' else 'ok' end as "type"
    from
      gcp_bigquery_table
    where
      kms_key_name != '';
  EOQ
}

# Assessment Queries

query "bigquery_table_encryption_status" {
  sql = <<-EOQ
    select
      case when kms_key_name != '' then 'enabled' else 'disabled' end as encryption_status,
      count(*)
    from
      gcp_bigquery_table
    group by
      encryption_status;
  EOQ
}

query "bigquery_table_expiration_status" {
  sql = <<-EOQ
    select
      case when expiration_time < current_timestamp then 'expired' else 'active' end as expiration_status,
      count(*)
    from
      gcp_bigquery_table
    group by
      expiration_status;
  EOQ
}

# Analysis Queries

query "bigquery_table_by_project" {
  sql = <<-EOQ
    select
      project,
      count(*) as total
    from
      gcp_bigquery_table
    group by
      project
    order by
      total desc;
  EOQ
}

query "bigquery_table_by_location" {
  sql = <<-EOQ
    select
      location,
      count(*) as total
    from
      gcp_bigquery_table
    group by
      location;
  EOQ
}

query "bigquery_table_by_type" {
  sql = <<-EOQ
    select
      type as table_type,
      count(*) as total
    from
      gcp_bigquery_table
    group by
      type;
  EOQ
}

query "bigquery_table_by_creation_month" {
  sql = <<-EOQ
    with tables as (
      select
        title,
        creation_time,
        to_char(creation_time,
          'YYYY-MM') as creation_month
      from
        gcp_bigquery_table
    ),
    months as (
      select
        to_char(d,
          'YYYY-MM') as month
      from
        generate_series(date_trunc('month',
        (
        select
          min(creation_time)
        from tables)),
        date_trunc('month',
          current_date),
        interval '1 month') as d
    ),
    tables_by_month as (
      select
        creation_month,
        count(*)
      from
        tables
      group by
        creation_month
    )
    select
      months.month,
      tables_by_month.count
    from
      months
      left join tables_by_month on months.month = tables_by_month.creation_month
    order by
      months.month;
  EOQ
}

query "bigquery_table_by_clustering" {
  sql = <<-EOQ
    select
      case when clustering_fields is null then 'Not Clustered' else 'Clustered' end as clustering_status,
      count(*) as total
    from
      gcp_bigquery_table
    group by
      clustering_status;
  EOQ
}

query "bigquery_table_by_partinioning_time" {
  sql = <<-EOQ
    select
      case when time_partitioning is null then 'Not Partitioned' else 'Partitioned' end as partitioning_status,
      count(*) as total
    from
      gcp_bigquery_table
    group by
      time_partitioning;
  EOQ
}

query "bigquery_table_by_partinioning_range" {
  sql = <<-EOQ
    select
      case when range_partitioning is null then 'Not Partitioned' else 'Partitioned' end as partitioning_status,
      count(*) as total
    from
      gcp_bigquery_table
    group by
      range_partitioning;
  EOQ
}

query "bigquery_table_by_dataset" {
  sql = <<-EOQ
    select
      dataset_id as dataset,
      count(*) as total
    from
      gcp_bigquery_table
    group by
      dataset_id
    order by
      total desc;
  EOQ
}
# Storage & Performance Queries

query "bigquery_table_storage_by_project" {
  sql = <<-EOQ
    select
      project,
      sum(num_bytes) / (1024 * 1024 * 1024) as "GB"
    from
      gcp_bigquery_table
    group by
      project
    order by
      "GB" desc;
  EOQ
}

query "bigquery_table_storage_by_location" {
  sql = <<-EOQ
    select
      location,
      sum(num_bytes) / (1024 * 1024 * 1024) as "GB"
    from
      gcp_bigquery_table
    group by
      location;
  EOQ
}

query "bigquery_table_storage_by_dataset" {
  sql = <<-EOQ
    select
      dataset_id as dataset,
      sum(num_bytes) / (1024 * 1024 * 1024) as "GB"
    from
      gcp_bigquery_table
    group by
      dataset_id
    order by
      "GB" desc;
  EOQ
}

query "bigquery_table_top_10_by_size" {
  sql = <<-EOQ
    select
      id,
      num_bytes as "Size (Bytes)"
    from
      gcp_bigquery_table
    order by
      num_bytes desc
    limit 10;
  EOQ
}

query "bigquery_table_top_10_by_row_count" {
  sql = <<-EOQ
    select
      id,
      num_rows as "Row Count"
    from
      gcp_bigquery_table
    order by
      num_rows desc
    limit 10;
  EOQ
}
