dashboard "dataplex_zone_detail" {

  title         = "GCP Dataplex Zone Detail"
  documentation = file("./dashboards/dataplex/docs/dataplex_zone_detail.md")

  tags = merge(local.dataplex_common_tags, {
    type = "Detail"
  })

  input "zone_self_link" {
    title = "Select a Dataplex Zone:"
    query = query.dataplex_zone_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.dataplex_zone_type
      type  = "info"
      args  = [self.input.zone_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_zone_state
      args  = [self.input.zone_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_zone_location_type
      type  = "info"
      args  = [self.input.zone_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_zone_asset_count
      type  = "info"
      args  = [self.input.zone_self_link.value]
    }

  }

  with "dataplex_lake_for_dataplex_zone" {
    query = query.dataplex_lake_for_dataplex_zone
    args  = [self.input.zone_self_link.value]
  }

  with "dataplex_zone_name" {
    query = query.dataplex_zone_name
    args  = [self.input.zone_self_link.value]
  }


  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.dataplex_zone
        args = {
          dataplex_zone_self_links = [self.input.zone_self_link.value]
        }
      }

      node {
        base = node.dataplex_lake
        args = {
          dataplex_lake_self_links = with.dataplex_lake_for_dataplex_zone.rows[*].self_link
        }
      }

      node {
        base = node.dataplex_assets
        args = {
          dataplex_zone_names = with.dataplex_zone_name.rows[*].zone_name
        }
      }

      edge {
        base = edge.dataplex_lake_to_dataplex_zone
        args = {
          dataplex_lake_self_links = with.dataplex_lake_for_dataplex_zone.rows[*].self_link
        }
      }

      edge {
        base = edge.dataplex_zone_to_dataplex_asset
        args = {
          dataplex_zone_self_links = [self.input.zone_self_link.value]
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
        query = query.dataplex_zone_overview
        args  = [self.input.zone_self_link.value]
      }

      table {
        title = "Tags"
        width = 4
        query = query.dataplex_zone_tags
        args  = [self.input.zone_self_link.value]
      }

      table {
        title = "Lake Details"
        width = 4
        query = query.dataplex_zone_lake_details
        args  = [self.input.zone_self_link.value]
      }
    }

    container {

      table {
        title = "Asset Specs"
        query = query.dataplex_zone_asset_details
        args  = [self.input.zone_self_link.value]
      }

      table {
        title = "Discovery Specs"
        query = query.dataplex_zone_discovery_specs
        args  = [self.input.zone_self_link.value]
      }

    }
  }
}

# Input query

query "dataplex_zone_input" {
  sql = <<-EOQ
    select
      title as label,
      self_link as value,
      json_build_object(
        'project', project,
        'uid', uid::text
      ) as tags
    from
      gcp_dataplex_zone
    order by
      name;
  EOQ
}

# Card queries

query "dataplex_zone_type" {
  sql = <<-EOQ
    select
      'Type' as label,
      type as value
    from
      gcp_dataplex_zone
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_zone_state" {
  sql = <<-EOQ
    select
      'Zone State' as label,
      case when state = 'ACTIVE' then 'Active' else state end as value,
      case when state = 'ACTIVE' then 'ok' else 'alert' end as type
    from
      gcp_dataplex_zone
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_zone_location_type" {
  sql = <<-EOQ
    select
      'Location Type' as label,
      resource_spec -> 'locationType'  as value
    from
      gcp_dataplex_zone
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_zone_asset_count" {
  sql = <<-EOQ
    select
     'Asset' as label,
      count(*) as value
    from
      gcp_dataplex_zone as z,
      gcp_dataplex_asset as s
    where
      s.zone_name = z.name
      and z.self_link = $1;
  EOQ
}

# Table queries

query "dataplex_zone_overview" {
  sql = <<-EOQ
    select
      uid as "UID",
      name as "Zone Name",
      location as "Location",
      description as "Description",
      project as "Project ID",
      create_time as "Creation Time",
      update_time as "Update Time"
    from
      gcp_dataplex_zone
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_zone_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_dataplex_zone
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

query "dataplex_zone_lake_details" {
  sql = <<-EOQ
    select
      l.name as "Lake Name",
      l.state as "State"
    from
      gcp_dataplex_zone as z,
      gcp_dataplex_lake as l
    where
      z.self_link = $1
      and z.project = split_part($1, '/', 6)
      and l.name = z.lake_name;
  EOQ
}

query "dataplex_zone_asset_details" {
  sql = <<-EOQ
    select
      s.name as "Asset Name",
      s.state as "State",
      s.resource_spec ->> 'name' as "Resource Name",
      s.resource_spec ->> 'readAccessMode' as "Read Access Mode",
      s.resource_spec ->> 'type' as "Type"
    from
      gcp_dataplex_zone as z,
      gcp_dataplex_asset as s
    where
      s.zone_name = z.name
      and z.self_link = $1;
  EOQ
}

query "dataplex_zone_discovery_specs" {
  sql = <<-EOQ
    select
      discovery_spec -> 'csvOptions' as "CSV Options",
      discovery_spec ->> 'enabled' as "Enabled",
      discovery_spec -> 'jsonOptions' as "JSON Options",
      discovery_spec ->> 'schedule' as "Schedule"
    from
      gcp_dataplex_zone
    where
      self_link = $1
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_lake_for_dataplex_zone" {
  sql = <<-EOQ
    select
      l.self_link as self_link
    from
      gcp_dataplex_zone as t,
      gcp_dataplex_lake as l
    where
      t.self_link = $1
      and t.project = split_part($1, '/', 6)
      and l.name = t.lake_name;
  EOQ
}

query "dataplex_zone_name" {
  sql = <<-EOQ
    select
      name as zone_name
    from
      gcp_dataplex_zone
    where
      self_link = $1
      and project = split_part($1, '/', 6)
  EOQ
}

