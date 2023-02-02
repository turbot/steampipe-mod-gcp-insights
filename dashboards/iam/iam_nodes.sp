node "iam_member" {
  category = category.iam_member

  sql = <<-EOQ
    select
      split_part(m,':',2) as id,
      split_part(m,':',2) as title,
      jsonb_build_object(
        'Binding', 'Member'
      ) as properties
    from
      gcp_service_account,
      jsonb_array_elements(iam_policy -> 'bindings') as b,
      jsonb_array_elements_text(b-> 'members') as m
    where
      name = any($1);
  EOQ

  param "iam_service_account_names" {}
}

node "iam_policy" {
  category = category.iam_policy

  sql = <<-EOQ
    select
      title as id,
      title,
      jsonb_build_object(
        'Title', title,
        'Project', project,
        'Location', location,
        'Version', version
      ) as properties
    from
      gcp_iam_policy
    where
      title = any($1);
  EOQ

  param "iam_policy_ids" {}
}

node "iam_role" {
  category = category.iam_role

  sql = <<-EOQ
    select
      i.name as id,
      i.title,
      jsonb_build_object(
        'Name', i.name,
        'Role ID', i.role_id,
        'Location', i.location,
        'Stage', i.stage,
        'Description', i.description
      ) as properties
    from
      gcp_iam_role as i
    where
      i.name = any($1);
  EOQ

  param "iam_role_ids" {}
}

node "iam_service_account" {
  category = category.iam_service_account

  sql = <<-EOQ
    select
      s.name as id,
      s.title,
      jsonb_build_object(
        'ID', s.unique_id,
        'Enabled', not s.disabled,
        'Region', s.location,
        'OAuth 2.0 client ID', s.oauth2_client_id,
        'Project', project
      ) as properties
    from
      gcp_service_account s
    where
      s.name = any($1);
  EOQ

  param "iam_service_account_names" {}
}

node "iam_service_account_key" {
  category = category.iam_service_account_key

  sql = <<-EOQ
    select
      name as id,
      title,
      jsonb_build_object(
        'Type', key_type,
        'Valid after Time', valid_after_time,
        'Region', location,
        'Project', project
      ) as properties
    from
      gcp_service_account_key
    where
      name = any($1);
  EOQ

  param "iam_service_account_key_names" {}
}

