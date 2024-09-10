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