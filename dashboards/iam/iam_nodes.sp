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
