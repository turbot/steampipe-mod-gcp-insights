dashboard "gcp_compute_forwarding_rule_detail" {

  title         = "GCP Compute Forwarding Rule Detail"
  documentation = file("./dashboards/compute/docs/compute_forwarding_rule_detail.md")

  tags = merge(local.compute_common_tags, {
    type = "Detail"
  })

  input "id" {
    title = "Select a forwarding rule:"
    query = query.gcp_compute_forwarding_rule_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.gcp_compute_forwarding_rule_network_tier
      args = {
        id = self.input.id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_forwarding_rule_global_access
      args = {
        id = self.input.id.value
      }
    }

    card {
      width = 2
      query = query.gcp_compute_forwarding_rule_label
      args = {
        id = self.input.id.value
      }
    }

  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"


      nodes = [
        node.gcp_compute_forwarding_rule_node,
        node.gcp_compute_forwarding_rule_to_compute_backend_service_node,
        node.gcp_compute_forwarding_rule_to_compute_target_pool_node,
        node.gcp_compute_forwarding_rule_to_compute_target_https_proxy_node,
        node.gcp_compute_forwarding_rule_to_compute_target_ssl_proxy_node,
        node.gcp_compute_forwarding_rule_to_compute_network_node,
        node.gcp_compute_forwarding_rule_to_compute_subnetwork_node,
        node.gcp_compute_forwarding_rule_to_compute_firewall_node
      ]

      edges = [
        edge.gcp_compute_forwarding_rule_to_compute_backend_service_edge,
        edge.gcp_compute_forwarding_rule_to_compute_target_pool_edge,
        edge.gcp_compute_forwarding_rule_to_compute_target_https_proxy_edge,
        edge.gcp_compute_forwarding_rule_to_compute_target_ssl_proxy_edge,
        edge.gcp_compute_forwarding_rule_to_compute_network_edge,
        edge.gcp_compute_forwarding_rule_to_compute_subnetwork_edge,
        edge.gcp_compute_forwarding_rule_to_compute_firewall_edge

      ]

      args = {
        id = self.input.id.value
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
        query = query.gcp_compute_forwarding_rule_overview
        args = {
          id = self.input.id.value
        }
      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_compute_forwarding_rule_tags
        args = {
          id = self.input.id.value
        }
      }
    }

    container {

      width = 6

      table {
        title = "Target Details"
        query = query.gcp_compute_forwarding_rule_target_detail
        args = {
          id = self.input.id.value
        }
      }

      table {
        title = "IP Details"
        query = query.gcp_compute_forwarding_rule_ip_details
        args = {
          id = self.input.id.value
        }
      }
    }
  }

}

query "gcp_compute_forwarding_rule_input" {
  sql = <<-EOQ
    select
      name as label,
      id::text as value,
      json_build_object(
        'location', location,
        'project', project,
        'id', id
      ) as tags
    from
      gcp_compute_forwarding_rule
    order by
      title;
  EOQ
}

query "gcp_compute_forwarding_rule_network_tier" {
  sql = <<-EOQ
    select
      'Network Tier' as label,
      network_tier as value
    from
      gcp_compute_forwarding_rule
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_forwarding_rule_global_access" {
  sql = <<-EOQ
    select
      'Global Access' as label,
      case when allow_global_access then 'Enabled' else 'Disabled' end as value,
      case when allow_global_access then 'ok' else 'alert' end as type
    from
      gcp_compute_forwarding_rule
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_forwarding_rule_label" {
  sql = <<-EOQ
    select
      'Labeling' as label,
      case when labels is not null then 'Enabled' else 'Disabled' end as value,
      case when labels is not null then 'ok' else 'alert' end as type
    from
      gcp_compute_forwarding_rule
    where
      id = $1;
  EOQ

  param "id" {}
}

category "gcp_compute_forwarding_rule_no_link" {}

node "gcp_compute_forwarding_rule_node" {
  category = category.gcp_compute_forwarding_rule_no_link

  sql = <<-EOQ
    select
      id::text,
      title,
      jsonb_build_object(
        'ID', id,
        'Name', name,
        'Created Time', creation_timestamp,
        'Region', region,
        'Project ID', project
      ) as properties
    from
      gcp_compute_forwarding_rule
    where
      id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_forwarding_rule_to_compute_backend_service_node" {
  category = category.gcp_compute_backend_service

  sql = <<-EOQ
    with forwarding_rule as (
      select
      split_part(bds, '/backendServices/', 2) as bsname,
      location,
      ip_protocol,
      id
    from (
      select
        backend_service as bds,
        location,
        ip_protocol,
        id
      from
        gcp_compute_forwarding_rule
      ) as bends
    )
    select
      bs.id::text,
      bs.title,
      jsonb_build_object(
        'ID', bs.id,
        'Name', bs.name,
        'Created Time', bs.creation_timestamp,
        'Location', bs.location,
        'Project ID', bs.project
      ) as properties
    from
      gcp_compute_backend_service as bs
      left join forwarding_rule as f on bs.name = f.bsname
    where
      f.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_forwarding_rule_to_compute_backend_service_edge" {
  title = "backend service"

  sql = <<-EOQ
    with forwarding_rule as (
      select
      split_part(bds, '/backendServices/', 2) as bsname,
      location,
      ip_protocol,
      id
    from (
      select
        backend_service as bds,
        location,
        ip_protocol,
        id
      from
        gcp_compute_forwarding_rule
      ) as bends
    )
    select
      f.id::text as from_id,
      bs.id::text as to_id,
      jsonb_build_object(
        'Connection Draining Timeout', connection_draining_timeout_sec
      ) as properties
    from
      gcp_compute_backend_service as bs
      left join forwarding_rule as f on bs.name = f.bsname
    where
      f.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_forwarding_rule_to_compute_target_pool_node" {
  category = category.gcp_compute_target_pool

  sql = <<-EOQ
    with forwarding_rule as (
      select
      split_part(t, '/targetPools/', 2) as tname,
      location,
      id
    from (
      select
        target as t,
        location,
        id
      from
        gcp_compute_forwarding_rule
      ) as tp
    )
    select
      t.id::text,
      t.title,
      jsonb_build_object(
        'ID', t.id,
        'Name', t.name,
        'Created Time', t.creation_timestamp,
        'Location', t.location,
        'Project ID', t.project
      ) as properties
    from
      gcp_compute_target_pool as t
      left join forwarding_rule as f on t.name = f.tname
    where
      f.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_forwarding_rule_to_compute_target_pool_edge" {
  title = "target pool"

  sql = <<-EOQ
    with forwarding_rule as (
      select
      split_part(t, '/targetPools/', 2) as tname,
      location,
      id
    from (
      select
        target as t,
        location,
        id
      from
        gcp_compute_forwarding_rule
      ) as tp
    )
    select
      f.id::text as from_id,
      t.id::text as to_id
    from
      gcp_compute_target_pool as t
      left join forwarding_rule as f on t.name = f.tname
    where
      f.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_forwarding_rule_to_compute_target_https_proxy_node" {
  category = category.gcp_compute_target_https_proxy

  sql = <<-EOQ
    with forwarding_rule as (
      select
      split_part(t, '/targetHttpsProxies/', 2) as tname,
      location,
      id
    from (
      select
        target as t,
        location,
        id
      from
        gcp_compute_forwarding_rule
      ) as tp
    )
    select
      t.id::text,
      t.title,
      jsonb_build_object(
        'ID', t.id,
        'Name', t.name,
        'Created Time', t.creation_timestamp,
        'Location', t.location,
        'Project ID', t.project
      ) as properties
    from
      gcp_compute_target_https_proxy as t
      left join forwarding_rule as f on t.name = f.tname
    where
      f.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_forwarding_rule_to_compute_target_https_proxy_edge" {
  title = "target https proxy"

  sql = <<-EOQ
    with forwarding_rule as (
      select
      split_part(t, '/targetHttpsProxies/', 2) as tname,
      location,
      id
    from (
      select
        target as t,
        location,
        id
      from
        gcp_compute_forwarding_rule
      ) as tp
    )
    select
      f.id::text as from_id,
      t.id::text as to_id
    from
      gcp_compute_target_https_proxy as t
      left join forwarding_rule as f on t.name = f.tname
    where
      f.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_forwarding_rule_to_compute_target_ssl_proxy_node" {
  category = category.gcp_compute_target_ssl_proxy

  sql = <<-EOQ
    with forwarding_rule as (
      select
      split_part(t, '/targetSslProxies/', 2) as tname,
      location,
      id
    from (
      select
        target as t,
        location,
        id
      from
        gcp_compute_forwarding_rule
      ) as tp
    )
    select
      t.id::text,
      t.title,
      jsonb_build_object(
        'ID', t.id,
        'Name', t.name,
        'Created Time', t.creation_timestamp,
        'Location', t.location,
        'Project ID', t.project,
        'SSL Policy', ssl_policy
      ) as properties
    from
      gcp_compute_target_ssl_proxy as t
      left join forwarding_rule as f on t.name = f.tname
    where
      f.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_forwarding_rule_to_compute_target_ssl_proxy_edge" {
  title = "target ssl proxy"

  sql = <<-EOQ
    with forwarding_rule as (
      select
      split_part(t, '/targetSslProxies/', 2) as tname,
      location,
      id
    from (
      select
        target as t,
        location,
        id
      from
        gcp_compute_forwarding_rule
      ) as tp
    )
    select
      f.id::text as from_id,
      t.id::text as to_id
    from
      gcp_compute_target_ssl_proxy as t
      left join forwarding_rule as f on t.name = f.tname
    where
      f.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_forwarding_rule_to_compute_network_node" {
  category = category.gcp_compute_network

  sql = <<-EOQ
    select
      n.id::text as id,
      n.name as title,
      jsonb_build_object(
        'ID', n.id,
        'Name', n.name,
        'Created Time', n.creation_timestamp
      ) as properties
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_network n
    where
      split_part(fr.network, 'networks/', 2) = n.name
      and fr.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_forwarding_rule_to_compute_network_edge" {
  title = "network"

  sql = <<-EOQ
    select
      fr.id::text as from_id,
      n.id::text as to_id
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_network n
    where
      split_part(fr.network, 'networks/', 2) = n.name
      and fr.id = $1;
  EOQ

  param "id" {}
}

node "gcp_compute_forwarding_rule_to_compute_subnetwork_node" {
  category = category.gcp_compute_subnetwork

  sql = <<-EOQ
    select
      s.id::text as id,
      s.name as title,
      jsonb_build_object(
        'ID', s.id::text,
        'Name', s.name,
        'Created Time', s.creation_timestamp,
        'Location', s.location,
        'IP Cidr Range', s.ip_cidr_range
      ) as properties
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_subnetwork s
    where
      split_part(fr.subnetwork, 'subnetworks/', 2) = s.name
      and fr.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_forwarding_rule_to_compute_subnetwork_edge" {
  title = "subnetwork"

  sql = <<-EOQ
    select
      fr.id::text as from_id,
      s.id::text as to_id
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_subnetwork s
    where
      split_part(fr.subnetwork, 'subnetworks/', 2) = s.name
      and fr.id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_forwarding_rule_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      id as "ID",
      creation_timestamp as "Create Time",
      title as "Title",
      location as "Location",
      project as "Project ID"
    from
      gcp_compute_forwarding_rule
    where
      id = $1
  EOQ

  param "id" {}
}

node "gcp_compute_forwarding_rule_to_compute_firewall_node" {
  category = category.gcp_compute_firewall

  sql = <<-EOQ
    select
      f.id::text,
      f.title,
      jsonb_build_object(
        'ID', f.id,
        'Direction', f.direction,
        'Enabled', not f.disabled,
        'Action', f.action,
        'Priority', f.priority
      ) as properties
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_network n,
      gcp_compute_firewall f
    where
      split_part(fr.network, 'networks/', 2) = n.name
      and n.self_link = f.network
      and fr.id = $1;
  EOQ

  param "id" {}
}

edge "gcp_compute_forwarding_rule_to_compute_firewall_edge" {
  title = "firewall"

  sql = <<-EOQ
    select
      fr.id::text as from_id,
      f.id::text as to_id
    from
      gcp_compute_forwarding_rule fr,
      gcp_compute_network n,
      gcp_compute_firewall f
    where
      split_part(fr.network, 'networks/', 2) = n.name
      and n.self_link = f.network
      and fr.id = $1;
  EOQ

  param "id" {}
}

query "gcp_compute_forwarding_rule_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        gcp_compute_forwarding_rule
      where
        id = $1
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

  param "id" {}
}

query "gcp_compute_forwarding_rule_target_detail" {
  sql = <<-EOQ

    with forwarding_rule_1 as (
      select
      split_part(t, '/targetPools/', 2) as tname,
      id
    from (
      select
        target as t,
        id
      from
        gcp_compute_forwarding_rule
      ) as tp
    ), forwarding_rule_2 as (
        select
        split_part(t, '/targetHttpsProxies/', 2) as tname,
        id
      from (
        select
          target as t,
          id
        from
          gcp_compute_forwarding_rule
        ) as tp
      ), forwarding_rule_3 as (
        select
        split_part(t, '/targetSslProxies/', 2) as tname,
        id
      from (
        select
          target as t,
          id
        from
          gcp_compute_forwarding_rule
        ) as tp
      )

    -- Target Pools
    select
      t.title as "Title",
      t.kind as  "Kind",
      t.id as "ID"
    from
      gcp_compute_target_pool as t
      left join forwarding_rule_1 as f on t.name = f.tname
    where
      f.id = $1

    -- Target HTTPS Proxy
    union all
    select
      t.title as "Title",
      t.kind as  "Kind",
      t.id as "ID"
    from
      gcp_compute_target_https_proxy as t
      left join forwarding_rule_2 as f on t.name = f.tname
    where
      f.id = $1

    -- Target SSL Proxy
    union all
    select
      t.title as "Title",
      t.kind as  "Kind",
      t.id as "ID"
    from
      gcp_compute_target_ssl_proxy as t
      left join forwarding_rule_3 as f on t.name = f.tname
    where
      f.id = $1;

  EOQ

  param "id" {}
}

query "gcp_compute_forwarding_rule_ip_details" {
  sql = <<-EOQ
    select
      ip_address as "IP Address",
      ip_protocol as "IP Protocol",
      ip_version as "IP Version"
    from
      gcp_compute_forwarding_rule
    where
      id = $1

  EOQ

  param "id" {}
}
