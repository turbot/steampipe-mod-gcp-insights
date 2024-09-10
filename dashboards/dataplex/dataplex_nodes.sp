node "dataplex_task" {
  category = category.dataplex_task

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Name', display_name,
        'Project', project,
        'UID', uid,
        'Location', location
      ) as properties
    from
      gcp_dataplex_task
      join unnest($1::text[]) as u on self_link = u and project = split_part(u, '/', 6);
  EOQ

  param "dataplex_task_ids" {}
}

node "dataplex_lake" {
  category = category.dataplex_lake

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Name', name,
        'uid', uid,
        'Created Time', create_time,
        'State', state,
        'Location', location,
        'Project', project
      ) as properties
    from
      gcp_dataplex_lake
      join unnest($1::text[]) as u on self_link = u and project = split_part(u, '/', 6);
  EOQ

  param "dataplex_lake_self_links" {}
}

node "dataplex_zone" {
  category = category.dataplex_lake

  sql = <<-EOQ
    select
      self_link as id,
      title,
      jsonb_build_object(
        'Name', name,
        'uid', uid,
        'Created Time', create_time,
        'State', state,
        'Location', location,
        'Project', project
      ) as properties
    from
      gcp_dataplex_zone
      join unnest($1::text[]) as u on self_link = u and project = split_part(u, '/', 6);
  EOQ

  param "dataplex_zone_self_links" {}
}