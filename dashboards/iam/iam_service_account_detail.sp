dashboard "iam_service_account_detail" {

  title         = "GCP IAM Service Account Detail"
  documentation = file("./dashboards/iam/docs/iam_service_account_detail.md")

  tags = merge(local.iam_common_tags, {
    type = "Detail"
  })

  input "service_account_name" {
    title = "Select a service account:"
    sql   = query.iam_service_account_input.sql
    width = 4
  }

  container {

    card {
      width = 3
      query = query.iam_service_account_default
      args  = [self.input.service_account_name.value]
    }

    card {
      width = 3
      query = query.iam_service_account_enabled
      args  = [self.input.service_account_name.value]
    }
  }

  with "cloudfunction_functions_for_iam_service_account" {
    query = query.cloudfunction_functions_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "compute_instances_for_iam_service_account" {
    query = query.compute_instances_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "compute_instance_templates_for_iam_service_account" {
    query = query.compute_instance_templates_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "iam_member_roles_for_iam_service_account" {
    query = query.iam_member_roles_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "iam_policies_for_iam_service_account" {
    query = query.iam_policies_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "iam_roles_for_iam_service_account" {
    query = query.iam_roles_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "iam_service_account_keys_for_iam_service_account" {
    query = query.iam_service_account_keys_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "pubsub_subscriptions_for_iam_service_account" {
    query = query.pubsub_subscriptions_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "source_compute_firewalls_for_iam_service_account" {
    query = query.source_compute_firewalls_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  with "target_compute_firewalls_for_iam_service_account" {
    query = query.target_compute_firewalls_for_iam_service_account
    args  = [self.input.service_account_name.value]
  }

  container {

    graph {
      title     = "Relationships"
      type      = "graph"
      direction = "TD"

      node {
        base = node.cloudfunctions_function
        args = {
          cloudfunctions_function_ids = with.cloudfunction_functions_for_iam_service_account.rows[*].function_id
        }
      }

      node {
        base = node.compute_firewall
        args = {
          compute_firewall_ids = with.source_compute_firewalls_for_iam_service_account.rows[*].source_firewall_id
        }
      }

      node {
        base = node.compute_firewall
        args = {
          compute_firewall_ids = with.target_compute_firewalls_for_iam_service_account.rows[*].target_firewall_id
        }
      }

      node {
        base = node.compute_instance
        args = {
          compute_instance_ids = with.compute_instances_for_iam_service_account.rows[*].instance_id
        }
      }

      node {
        base = node.compute_instance_template
        args = {
          compute_instance_template_ids = with.compute_instance_templates_for_iam_service_account.rows[*].template_id
        }
      }

      node {
        base = node.iam_member
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }

      node {
        base = node.iam_policy
        args = {
          iam_policy_ids = with.iam_policies_for_iam_service_account.rows[*].policy_id
        }
      }

      node {
        base = node.iam_role
        args = {
          iam_role_ids = with.iam_member_roles_for_iam_service_account.rows[*].role_id
        }
      }

      node {
        base = node.iam_role
        args = {
          iam_role_ids = with.iam_roles_for_iam_service_account.rows[*].role_id
        }
      }

      node {
        base = node.iam_service_account
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }

      node {
        base = node.iam_service_account_key
        args = {
          iam_service_account_key_names = with.iam_service_account_keys_for_iam_service_account.rows[*].key_name
        }
      }

      node {
        base = node.pubsub_subscription
        args = {
          pubsub_subscription_self_links = with.pubsub_subscriptions_for_iam_service_account.rows[*].subscription_id
        }
      }

      edge {
        base = edge.compute_firewall_to_iam_service_account
        args = {
          compute_firewall_ids = with.source_compute_firewalls_for_iam_service_account.rows[*].source_firewall_id
        }
      }

      edge {
        base = edge.compute_instance_to_iam_service_account
        args = {
          compute_instance_ids = with.compute_instances_for_iam_service_account.rows[*].instance_id
        }
      }

      edge {
        base = edge.iam_member_to_iam_role
        args = {
          iam_role_ids = with.iam_member_roles_for_iam_service_account.rows[*].role_id
        }
      }

      edge {
        base = edge.iam_role_to_iam_policy
        args = {
          iam_role_ids = with.iam_roles_for_iam_service_account.rows[*].role_id
        }
      }

      edge {
        base = edge.iam_service_account_to_cloudfunction_function
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }

      edge {
        base = edge.iam_service_account_to_compute_firewall
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }

      edge {
        base = edge.iam_service_account_to_compute_instance_template
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }

      edge {
        base = edge.iam_service_account_to_iam_member
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }

      edge {
        base = edge.iam_service_account_to_iam_role
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }

      edge {
        base = edge.iam_service_account_to_iam_service_account_key
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }

      edge {
        base = edge.iam_service_account_to_pubsub_subscription
        args = {
          iam_service_account_names = [self.input.service_account_name.value]
        }
      }
    }
  }

  container {

      width = 12

      table {
        title = "Overview"
        type  = "line"
        width = 3
        query = query.iam_storage_account_overview
        args  = [self.input.service_account_name.value]
      }

      table {
        title = "Keys"
        width = 9
        query = query.iam_storage_account_keys
        args  = [self.input.service_account_name.value]
      }

  }

}

# Input queries

query "iam_service_account_input" {
  sql = <<-EOQ
    select
      title as label,
      name as value,
      json_build_object(
        'location', location,
        'project', project
      ) as tags
    from
      gcp_service_account
    order by
      title;
  EOQ
}

# # With queries

query "cloudfunction_functions_for_iam_service_account" {
  sql = <<-EOQ
    select
      f.name as function_id
    from
      gcp_cloudfunctions_function as f,
      gcp_service_account as s
    where
      f.service_account_email = s.email
      and s.name = $1;
  EOQ
}

query "compute_instances_for_iam_service_account" {
  sql = <<-EOQ
    select
      i.id::text as instance_id
    from
      gcp_service_account as s,
      gcp_compute_instance as i,
      jsonb_array_elements(service_accounts) as sa
    where
      sa ->> 'email' = s.email
      and s.name = $1;
  EOQ
}

query "compute_instance_templates_for_iam_service_account" {
  sql = <<-EOQ
    select
      t.id::text as template_id
    from
      gcp_service_account as s,
      gcp_compute_instance_template as t,
      jsonb_array_elements(instance_service_accounts) as tsa
    where
      tsa ->> 'email' = s.email
      and s.name = $1;
  EOQ
}

query "iam_member_roles_for_iam_service_account" {
  sql = <<-EOQ
    with role_name as (
      select
        name,
        role_name
      from
        gcp_iam_role,
        split_part(name,'roles/',2) as role_name
    )
    select
      rn.name as role_id
    from
      role_name as rn,
      gcp_service_account as s,
      jsonb_array_elements(iam_policy -> 'bindings') as b,
      split_part(b ->> 'role','roles/',2) as r
    where
      rn.role_name = r
      and s.name= $1;
  EOQ
}

query "iam_policies_for_iam_service_account" {
  sql = <<-EOQ
    select
      title as policy_id
    from
      gcp_iam_policy,
      jsonb_array_elements(bindings) as b,
      jsonb_array_elements_text(b -> 'members') as m,
      split_part(m,'serviceAccount:',2) as member_name
    where
      m like 'serviceAccount:%'
      and member_name = $1;
  EOQ
}

query "iam_roles_for_iam_service_account" {
  sql = <<-EOQ
    select
      b ->> 'role' as role_id
    from
      gcp_iam_policy,
      jsonb_array_elements(bindings) as b,
      jsonb_array_elements_text(b -> 'members') as m,
      split_part(m,'serviceAccount:',2) as member_name
    where
      m like 'serviceAccount:%'
      and member_name = $1;
  EOQ
}

query "iam_service_account_keys_for_iam_service_account" {
  sql = <<-EOQ
    select
      name as key_name
    from
      gcp_service_account_key
    where
      service_account_name = $1;
  EOQ
}

query "pubsub_subscriptions_for_iam_service_account" {
  sql = <<-EOQ
    select
      p.self_link as subscription_id
    from
      gcp_pubsub_subscription as p,
      gcp_service_account as s
    where
      p.push_config_oidc_token_service_account_email = s.email
      and s.name = $1;
  EOQ
}

query "source_compute_firewalls_for_iam_service_account" {
  sql = <<-EOQ
    select
      id::text as source_firewall_id
    from
      gcp_compute_firewall,
      jsonb_array_elements_text(target_service_accounts) as t
    where
      t = $1;
  EOQ
}

query "target_compute_firewalls_for_iam_service_account" {
  sql = <<-EOQ
    select
      id::text as target_firewall_id
    from
      gcp_compute_firewall,
      jsonb_array_elements_text(source_service_accounts) as s
    where
      s = $1;
  EOQ
}

# # Card queries

query "iam_service_account_default" {
  sql = <<-EOQ
    select
      'Project Default' as label,
      case when s.email = p.default_service_account then 'Default' else 'Not Default' end as value
    from
      gcp_compute_project_metadata as p,
      gcp_service_account as s
    where
      s.name = $1
  EOQ
}

query "iam_service_account_enabled" {
  sql = <<-EOQ
    select
      case when disabled then 'Disabled' else 'Enabled' end as value,
      'Status' as label,
      case when disabled then 'alert' else 'ok' end as type
    from
      gcp_service_account
    where
      name = $1
  EOQ
}

# # Other detail page queries

query "iam_storage_account_overview" {
  sql = <<-EOQ
    select
      display_name as "Name",
      oauth2_client_id as "OAuth 2.0 client ID",
      unique_id as "ID",
      email as "Email ID",
      title as "Title",
      location as "Location",
      project as "Project"
    from
      gcp_service_account
    where
      name = $1
  EOQ
}

query "iam_storage_account_keys" {
  sql = <<-EOQ
    select
      k.name as "Name",
      k.key_origin as "Origin",
      k.key_type as "Type",
      k.key_algorithm as "Algorithm"
    from
      gcp_service_account_key as k,
      gcp_service_account as s
    where
      s.email = k.service_account_name
      and s.name = $1
  EOQ
}
