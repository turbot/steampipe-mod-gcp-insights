node "iam_role" {
  category = category.iam_role

  sql = <<-EOQ
    select
      i.role_id as id,
      i.title,
      jsonb_build_object(
        'Name', i.name,
        'Role ID', i.role_id,
        'Location', i.location,
        'Project', i.project,
        'Stage', i.stage,
        'Description', i.description
      ) as properties
    from
      gcp_iam_role as i
    where
      i.role_id = any($1);
  EOQ

  param "iam_role_ids" {}
}