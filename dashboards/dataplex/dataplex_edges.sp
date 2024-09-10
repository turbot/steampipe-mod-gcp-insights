edge "dataplex_task_to_dataplex_lake" {
  title = "operates on"

  sql = <<-EOQ
    select
      l.self_link as from_id,
      t.self_link as to_id
    from
      gcp_dataplex_task as t
      join unnest($1::text[]) as u on t.self_link = u and t.project = split_part(u, '/', 6),
      gcp_dataplex_lake as l
    where
      l.name = t.lake_name;
  EOQ

  param "dataplex_task_ids" {}
}

edge "dataplex_lake_to_dataplex_zone" {
  title = "zone"

  sql = <<-EOQ
    select
      l.self_link as from_id,
      z.self_link as to_id
    from
      gcp_dataplex_lake as l
      join unnest($1::text[]) as u on l.self_link = u and l.project = split_part(u, '/', 6),
      gcp_dataplex_zone as z
    where
      l.name = z.lake_name;
  EOQ

  param "dataplex_lake_self_links" {}
}

