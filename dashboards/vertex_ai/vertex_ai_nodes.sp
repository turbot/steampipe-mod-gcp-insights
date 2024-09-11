node "vertex_ai_endpoint" {
  category = category.vertex_ai_endpoint

  sql = <<-EOQ
    select
      name as id,
      jsonb_build_object(
        'Name', name,
        'Project', project,
        'Location', location,
        'Create Time', create_time,
        'Update Time', update_time
      ) as properties
    from
      gcp_vertex_ai_endpoint
      join unnest($1::text[]) as u on name = split_part(u, '/', 1) and project = split_part(u, '/', 2);
  EOQ

  param "vertex_ai_endpoint_ids" {}
}

node "vertex_ai_model" {
  category = category.vertex_ai_model

  sql = <<-EOQ
    select
      name as id,
      jsonb_build_object(
        'Project', project,
        'Location', location,
        'Create Time', create_time,
        'Update Time', update_time
      ) as properties
    from
      gcp_vertex_ai_model
      join unnest($1::text[]) as u on name = split_part(u, '/', 1) and project = split_part(u, '/', 2);
  EOQ

  param "vertex_ai_model_ids" {}
}