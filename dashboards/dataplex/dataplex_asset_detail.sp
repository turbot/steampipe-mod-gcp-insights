dashboard "dataplex_asset_detail" {

  title         = "GCP Dataplex Asset Detail"
  documentation = file("./dashboards/dataplex/docs/dataplex_asset_detail.md")

  tags = merge(local.dataplex_common_tags, {
    type = "Detail"
  })

  input "asset_self_link" {
    title = "Select a Dataplex Asset:"
    query = query.dataplex_asset_input
    width = 4
  }

  container {

    card {
      width = 3
      query = query.dataplex_asset_state
      args  = [self.input.asset_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_asset_resource_type
      type  = "info"
      args  = [self.input.asset_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_asset_zone_name_card
      type  = "info"
      args  = [self.input.asset_self_link.value]
    }

    card {
      width = 3
      query = query.dataplex_asset_lake_name
      type  = "info"
      args  = [self.input.asset_self_link.value]
    }

  }

  with "dataplex_asset_zone_name" {
    query = query.dataplex_asset_zone_name
    args  = [self.input.asset_self_link.value]
  }

  with "dataplex_zone_for_dataplex_asset" {
    query = query.dataplex_zone_for_dataplex_asset
    args  = [self.input.asset_self_link.value]
  }

  with "dataplex_lake_for_dataplex_asset" {
    query = query.dataplex_lake_for_dataplex_asset
    args  = [self.input.asset_self_link.value]
  }

  container {

    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.dataplex_asset
        args = {
          dataplex_zone_names = with.dataplex_asset_zone_name.rows[*].zone_name
          dataplex_asset_self_links = [self.input.asset_self_link.value]
        }
      }

      node {
        base = node.dataplex_zone
        args = {
          dataplex_zone_self_links = with.dataplex_zone_for_dataplex_asset.rows[*].self_link
        }
      }

      node {
        base = node.dataplex_lake
        args = {
          dataplex_lake_self_links = with.dataplex_lake_for_dataplex_asset.rows[*].self_link
        }
      }

      edge {
        base = edge.dataplex_lake_to_dataplex_zone
        args = {
          dataplex_lake_self_links = with.dataplex_lake_for_dataplex_asset.rows[*].self_link
        }
      }

      edge {
        base = edge.dataplex_zone_to_dataplex_asset
        args = {
          dataplex_zone_self_links = with.dataplex_zone_for_dataplex_asset.rows[*].self_link
        }
      }
    }
  }

    container {

      container {
        width = 6

        table {
          title = "Overview"
          width = 6
          type  = "line"
          query = query.dataplex_asset_overview
          args  = [self.input.asset_self_link.value]
        }

        table {
          title = "Tags"
          width = 6
          query = query.dataplex_asset_tags
          args  = [self.input.asset_self_link.value]
        }

      }

      container {
        width = 6
        table {
          title = "Lake Details"
          query = query.dataplex_asset_lake_details
          args  = [self.input.asset_self_link.value]
        }

        table {
          title = "Zone Details"
          query = query.dataplex_asset_zone_details
          args  = [self.input.asset_self_link.value]
        }
    }

    }

    container {

      table {
        title = "Resource Specs"
        query = query.dataplex_asset_resource_spec
        args  = [self.input.asset_self_link.value]
      }

    }

    container {

      table {
        title = "Resource Status"
        width = 6
        query = query.dataplex_asset_resource_status
        args  = [self.input.asset_self_link.value]
      }

      table {
        title = "Security Status"
        width = 6
        query = query.dataplex_asset_security_status
        args  = [self.input.asset_self_link.value]
      }

    }

  }


# Input query

query "dataplex_asset_input" {
  sql = <<-EOQ
    select
      a.title as label,
      a.self_link as value,
      json_build_object(
        'zone', z.title,
        'project', a.project,
        'uid', a.uid::text
      ) as tags
    from
      gcp_dataplex_zone as z,
      gcp_dataplex_asset as a
    where
      a.zone_name = z.name
    order by
      a.title;
  EOQ
}

# Card queries

query "dataplex_asset_state" {
  sql = <<-EOQ
    select
      'State' as label,
      state as value,
      case when state = 'ACTIVE' then 'ok' else 'alert' end as type
    from
      gcp_dataplex_asset
    where
      self_link = $1
      and zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_asset_resource_type" {
  sql = <<-EOQ
    select
      'Resource Type' as label,
      resource_spec ->> 'type' as value
    from
      gcp_dataplex_asset
    where
      self_link = $1
      and zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_asset_zone_name_card" {
  sql = <<-EOQ
    select
      'Zone Name' as label,
      split_part(zone_name, '/', 8) as value
    from
      gcp_dataplex_asset
    where
      self_link = $1
      and zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_asset_lake_name" {
  sql = <<-EOQ
    select
      'Lake Name' as label,
      split_part(zone_name, '/', 6) as value
    from
      gcp_dataplex_asset
    where
      self_link = $1
      and zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and project = split_part($1, '/', 6);
  EOQ
}

# # Table queries

query "dataplex_asset_overview" {
  sql = <<-EOQ
    select
      uid as "UID",
      name as "Name",
      location as "Location",
      description as "Description",
      project as "Project ID",
      create_time as "Creation Time",
      update_time as "Update Time"
    from
      gcp_dataplex_asset
    where
      self_link = $1
      and zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_asset_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_dataplex_asset
      where
        self_link = $1
        and zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
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

query "dataplex_asset_lake_details" {
  sql = <<-EOQ
    select
      l.name as "Lake Name",
      l.state as "State"
    from
      gcp_dataplex_asset as z,
      gcp_dataplex_lake as l
    where
      z.self_link = $1
      and z.zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and z.project = split_part($1, '/', 6)
      and l.name = z.lake_name
  EOQ
}

query "dataplex_asset_zone_details" {
  sql = <<-EOQ
    select
      z.name as "Zone Name",
      z.state as "State"
    from
      gcp_dataplex_zone as z,
      gcp_dataplex_asset as a
    where
      a.self_link = $1
      and a.project = split_part($1, '/', 6)
      and z.name = a.zone_name
  EOQ
}

query "dataplex_asset_resource_spec" {
  sql = <<-EOQ
    select
      s.resource_spec ->> 'name' as "Resource Name",
      s.resource_spec ->> 'readAccessMode' as "Read Access Mode",
      s.resource_spec ->> 'type' as "Type"
    from
      gcp_dataplex_asset as s
    where
      s.self_link = $1
      and s.zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and s.project = split_part($1, '/', 6)
  EOQ
}

query "dataplex_asset_resource_status" {
  sql = <<-EOQ
    select
      s.resource_status ->> 'state' as "State",
      s.resource_status ->> 'updateTime' as "Update Time"
    from
      gcp_dataplex_asset as s
    where
      s.self_link = $1
      and s.zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and s.project = split_part($1, '/', 6)
  EOQ
}

query "dataplex_asset_security_status" {
  sql = <<-EOQ
    select
      s.security_status ->> 'state' as "State",
      s.security_status ->> 'updateTime' as "Update Time"
    from
      gcp_dataplex_asset as s
    where
      s.self_link = $1
      and s.zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and s.project = split_part($1, '/', 6)
  EOQ
}

# query "dataplex_asset_discovery_specs" {
#   sql = <<-EOQ
#     select
#       discovery_spec -> 'csvOptions' as "CSV Options",
#       discovery_spec ->> 'enabled' as "Enabled",
#       discovery_spec -> 'jsonOptions' as "JSON Options",
#       discovery_spec ->> 'schedule' as "Schedule"
#     from
#       gcp_dataplex_asset
#     where
#       self_link = $1
#       and project = split_part($1, '/', 6);
#   EOQ
# }

# query "dataplex_lake_for_dataplex_asset" {
#   sql = <<-EOQ
#     select
#       l.self_link as self_link
#     from
#       gcp_dataplex_asset as t,
#       gcp_dataplex_lake as l
#     where
#       t.self_link = $1
#       and t.project = split_part($1, '/', 6)
#       and l.name = t.lake_name;
#   EOQ
# }

query "dataplex_asset_zone_name" {
  sql = <<-EOQ
    select
      zone_name as zone_name
    from
      gcp_dataplex_asset
    where
      self_link = $1
      and zone_name = substring($1, 'projects/[^/]+/locations/[^/]+/lakes/[^/]+/zones/[^/]+')
      and project = split_part($1, '/', 6);
  EOQ
}

query "dataplex_zone_for_dataplex_asset" {
  sql = <<-EOQ
    select
      z.self_link as self_link
    from
      gcp_dataplex_asset as a,
      gcp_dataplex_zone as z
    where
      a.self_link = $1
      and a.project = split_part($1, '/', 6)
      and z.name = a.zone_name
  EOQ
}

query "dataplex_lake_for_dataplex_asset" {
  sql = <<-EOQ
    select
      l.self_link as self_link
    from
      gcp_dataplex_asset as a,
      gcp_dataplex_lake as l,
      gcp_dataplex_zone as z
    where
      a.self_link = $1
      and a.project = split_part($1, '/', 6)
      and z.name = a.zone_name
      and z.lake_name = l.name
  EOQ
}

