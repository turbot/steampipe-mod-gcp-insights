dashboard "dataplex_lake_detail" {

  title         = "GCP Dataplex Lake Detail"
  documentation = file("./dashboards/dataplex/docs/dataplex_lake_detail.md")

  tags = merge(local.dataplex_common_tags, {
    type = "Detail"
  })

  input "lake_self_link" {
    title = "Select a lake:"
    query = query.dataplex_lake_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.dataplex_lake_state
      args  = [self.input.lake_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_lake_metastore_state
      args  = [self.input.lake_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_lake_zone_count
      args  = [self.input.lake_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_lake_task_count
      args  = [self.input.lake_self_link.value]
    }

  }

  with "dataplex_zone_for_dataplex_lake" {
    query = query.dataplex_zone_for_dataplex_lake
    args  = [self.input.lake_self_link.value]
  }

  with "dataproc_metastore_service_for_dataplex_lake" {
    query = query.dataproc_metastore_service_for_dataplex_lake
    args  = [self.input.lake_self_link.value]
  }

  with "compute_networks_for_dataplex_lake" {
    query = query.compute_networks_for_dataplex_lake
    args  = [self.input.lake_self_link.value]
  }

  with "dataplex_task_for_dataplex_lake" {
    query = query.dataplex_task_for_dataplex_lake
    args  = [self.input.lake_self_link.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.dataplex_lake
        args = {
          dataplex_lake_self_links = [self.input.lake_self_link.value]
        }
      }

      node {
        base = node.dataplex_zone
        args = {
          dataplex_zone_self_links = with.dataplex_zone_for_dataplex_lake.rows[*].self_link
        }
      }

      node {
        base = node.compute_network
        args = {
          compute_network_ids = with.compute_networks_for_dataplex_lake.rows[*].network_id
        }
      }

      node {
        base = node.dataproc_metastore_service
        args = {
          dataproc_metastore_service_self_links = with.dataproc_metastore_service_for_dataplex_lake.rows[*].self_link
        }
      }

      node {
        base = node.dataplex_task
        args = {
          dataplex_task_ids = with.dataplex_task_for_dataplex_lake.rows[*].self_link
        }
      }

      edge {
        base = edge.dataplex_lake_to_dataplex_zone
        args = {
          dataplex_lake_self_links = [self.input.lake_self_link.value]
        }
      }

      edge {
        base = edge.dataplex_lake_to_dataproc_metastore_service
        args = {
          dataplex_lake_self_links = [self.input.lake_self_link.value]
        }
      }

      edge {
        base = edge.dataplex_lake_to_compute_network
        args = {
          dataplex_lake_self_links = [self.input.lake_self_link.value]
        }
      }

      edge {
        base = edge.dataplex_lake_to_dataplex_task
        args = {
          dataplex_lake_self_links = [self.input.lake_self_link.value]
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
        query = query.dataplex_lake_overview
        args  = [self.input.lake_self_link.value]
      }

      table {
        title = "Tags"
        width = 6
        query = query.dataplex_lake_tags_detail
        args  = [self.input.lake_self_link.value]
      }
    }

    container {
      width = 6

      table {
        title = "Metastore Service Details"
        query = query.dataplex_lake_metastore_service_details
        args  = [self.input.lake_self_link.value]
      }

      table {
        title = "Zone Details"
        query = query.dataplex_lake_zone_details
        args  = [self.input.lake_self_link.value]
      }

      table {
        title = "Task Details"
        query = query.dataplex_lake_task_details
        args  = [self.input.lake_self_link.value]
      }
    }

  }

}

# Input queries

query "dataplex_lake_input" {
  sql = <<-EOQ
    select
      title as label,
      self_link as value,
      json_build_object(
        'project', project
      ) as tags
    from
      gcp_dataplex_lake
    order by
      title;
  EOQ
}

# Card Queries

query "dataplex_lake_state" {
  sql = <<-EOQ
    select
      'State' as label,
      initcap(state) as value
    from
      gcp_dataplex_lake
    where
      self_link = $1
      and project = split_part( $1, '/', 6);
  EOQ
}

query "dataplex_lake_metastore_state" {
  sql = <<-EOQ
    select
      'Metastore Status' as label,
      initcap(metastore_status ->> 'state') as value
    from
      gcp_dataplex_lake
    where
      self_link = $1
      and project =split_part( $1, '/', 6);
  EOQ
}

query "dataplex_lake_zone_count" {
  sql = <<-EOQ
    select
     'Zone' as label,
      count(*) as value
    from
      gcp_dataplex_zone
    where
      lake_name =  split_part( $1, 'v1/', 2)
  EOQ
}

query "dataplex_lake_task_count" {
  sql = <<-EOQ
    select
     'Task' as label,
      count(*) as value
    from
      gcp_dataplex_task
    where
      lake_name =  split_part( $1, 'v1/', 2)
  EOQ
}

query "dataplex_lake_metastore_service_details" {
  sql = <<-EOQ
    select
      metastore ->> 'service' as "service",
      metastore_status ->> 'state'  as "Metastore State",
      metastore_status ->> 'updateTime' as "Update Time"
    from
      gcp_dataplex_lake
    where
      self_link = $1
      and project =split_part( $1, '/', 6);
  EOQ
}

query "dataplex_lake_zone_details" {
  sql = <<-EOQ
    select
      z.name as "Name",
      z.resource_spec ->> 'locationType'  as "Location Type",
      z.state  as "State"
    from
      gcp_dataplex_zone as z,
      gcp_dataplex_lake as l
    where
      l.self_link = $1
      and l.project = split_part( $1, '/', 6)
      and l.name = z.lake_name;
  EOQ
}

query "dataplex_lake_task_details" {
  sql = <<-EOQ
    select
      t.display_name as "Name",
      t.location  as "Location",
      t.state  as "State"
    from
      gcp_dataplex_task as t,
      gcp_dataplex_lake as l
    where
      l.self_link = $1
      and l.project = split_part($1, '/', 6)
      and l.name = t.lake_name;
  EOQ
}

# Other queries

query "dataplex_lake_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      uid as "UID",
      state as "State",
      description as "Description",
      create_time as "Create Time",
      title as "Title",
      location as "Location",
      project as "Project ID"
    from
      gcp_dataplex_lake
    where
      self_link = $1
      and project =split_part( $1, '/', 6);
  EOQ
}

query "dataplex_lake_tags_detail" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_dataplex_lake
      where
        self_link = $1
      and project = split_part( $1, '/', 6)
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

# With queries

query "dataplex_zone_for_dataplex_lake" {
  sql = <<-EOQ
    select
      t.self_link as self_link
    from
      gcp_dataplex_zone as t,
      gcp_dataplex_lake as l
    where
      l.self_link = $1
      and t.project = split_part( $1, '/', 6)
      and l.name = t.lake_name;
  EOQ
}

query "dataproc_metastore_service_for_dataplex_lake" {
  sql = <<-EOQ
    select
      t.self_link as self_link
    from
      gcp_dataproc_metastore_service as t,
      gcp_dataplex_lake as l
    where
      l.self_link = $1
      and t.project = split_part( $1, '/', 6)
      and l.metastore ->> 'service' = t.name;
  EOQ
}

query "compute_networks_for_dataplex_lake" {
  sql = <<-EOQ
    select
        n.id::text || '/' || n.project as network_id
      from
        gcp_dataproc_metastore_service as t,
        gcp_dataplex_lake as l,
        gcp_compute_network as n
      where
        l.self_link = $1
        and t.project = split_part( $1, '/', 6)
        and l.metastore ->> 'service' = t.name
        and split_part(t.network,'networks/', 2) = n.name
  EOQ
}

query "dataplex_task_for_dataplex_lake" {
  sql = <<-EOQ
    select
      t.self_link as self_link
    from
      gcp_dataplex_task as t,
      gcp_dataplex_lake as l
    where
      l.self_link = $1
      and l.project = split_part($1, '/', 6)
      and l.name = t.lake_name;
  EOQ
}

