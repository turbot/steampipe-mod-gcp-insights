edge "vertex_ai_endpoint_to_vertex_ai_model" {
  title = "deploys"
  sql = <<-EOQ
    select
      name as from_id,
      split_part(jsonb_array_elements(deployed_models) ->> 'model', '/models/', 2) as to_id
    from
      gcp_vertex_ai_endpoint
    join unnest($1::text[]) as u on name = split_part(u, '/', 1) and project = split_part(u, '/', 2);
  EOQ
  param "vertex_ai_endpoint_ids" {}

}

edge "vertex_ai_endpoint_to_kms_key" {
  title = "encrypted with"
  sql = <<-EOQ
    select
      m.name as from_id,
      k.self_link as to_id
    from
      gcp_kms_key k,
      gcp_vertex_ai_endpoint m
      left join gcp_kms_key kms
    on
      (encryption_spec ->> 'kms_key_name') = replace(kms.self_link, 'https://cloudkms.googleapis.com/v1/', '')
      join unnest($1::text[]) as u on m.name = split_part(u, '/', 1) and m.project = split_part(u, '/', 2);
  EOQ
  param "vertex_ai_endpoint_ids" {}
}

edge "vertex_ai_endpoint_to_compute_network" {
  title = "uses"
  sql = <<-EOQ
    select
      m.name as from_id,
      n.id::text as to_id
    from
      gcp_vertex_ai_endpoint m
      left join gcp_compute_network n on split_part(m.network, '/networks/',2) = n.name
    join unnest($1::text[]) as u on m.name = split_part(u, '/', 1) and m.project = split_part(u, '/', 2);
  EOQ
  param "vertex_ai_endpoint_ids" {}
}