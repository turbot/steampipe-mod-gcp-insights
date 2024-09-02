edge "cloudfunctions_function_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.self_link as from_id,
      k.self_link as to_id
    from
      gcp_cloudfunctions_function as i
      join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 6),
      gcp_kms_key as k
    where
      i.kms_key_name = split_part(k.self_link , 'v1/', 2);
  EOQ

  param "cloudfunctions_function_self_link" {}
}

edge "cloudfunctions_function_to_pubsub_topic" {
  title = "triggers"

  sql = <<-EOQ
    select
      i.self_link as from_id,
      k.self_link as to_id
    from
      gcp_cloudfunctions_function as i
      join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 6),
      gcp_pubsub_topic as k
    where
      i.event_trigger ->> 'pubsubTopic' = split_part(k.self_link , 'v1/', 2);
  EOQ

  param "cloudfunctions_function_self_link" {}
}

edge "cloudfunctions_function_to_iam_service_account" {
  title = "service account"

  sql = <<-EOQ
    select
      i.self_link as from_id,
      s.name as to_id
    from
      gcp_cloudfunctions_function as i
      join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 6),
      gcp_service_account as s
    where
      i.service_account_email = s.name;
  EOQ

  param "cloudfunctions_function_self_link" {}
}

