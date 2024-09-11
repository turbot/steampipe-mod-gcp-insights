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

edge "cloudfunctions_function_to_storage_bucket" {
  title = "storage bucket"

  sql = <<-EOQ
    select
      i.self_link as from_id,
      (s.id || '/' || s.project) as to_id
    from
      gcp_cloudfunctions_function as i
      join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 6),
      gcp_storage_bucket as s
    where
      i.build_config -> 'source' -> 'storageSource' ->> 'bucket' = s.name;
  EOQ

  param "cloudfunctions_function_self_link" {}
}

edge "cloudfunctions_function_to_vpc_access_connector" {
  title = "VPC access connector"

  sql = <<-EOQ
    select
      i.self_link as from_id,
      s.self_link as to_id
    from
      gcp_cloudfunctions_function as i
      join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 6),
      gcp_vpc_access_connector as s
    where
      i.vpc_connector = s.name;
  EOQ

  param "cloudfunctions_function_self_link" {}
}

edge "cloudfunctions_function_to_compute_network" {
  title = "network"

  sql = <<-EOQ
    with network_name as (
      select
        s.network as network_name,
        s.location,
        s.self_link,
        s.project
      from
        gcp_cloudfunctions_function as i
        join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 6),
        gcp_vpc_access_connector as s
      where
        i.vpc_connector = s.name
    )
      select
        v.self_link as from_id,
        n.id::text as to_id
      from
        gcp_compute_network as n,
        network_name as v
      where
        n.name = v.network_name
        and n.project = v.project
        and n.location = v.location;
  EOQ

  param "cloudfunctions_function_self_link" {}
}


edge "cloudfunctions_function_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
    with subnetwork_name as (
      select
        s.network as network_name,
        s.subnet ->> 'name' as subnet_name,
        s.location,
        i.self_link,
        s.project
      from
        gcp_cloudfunctions_function as i
        join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 6),
        gcp_vpc_access_connector as s
      where
        i.vpc_connector = s.name
    )
      select
        n.id::text as from_id,
        s.id::text as to_id
      from
        gcp_compute_subnetwork as s,
        gcp_compute_network as n,
        subnetwork_name as v
      where
        s.name = v.subnet_name
        and s.network_name = v.network_name
        and n.name = v.network_name
        and s.project = v.project
        and s.location = v.location
        and n.project = v.project;
  EOQ

  param "cloudfunctions_function_self_link" {}
}

edge "cloudrun_service_to_cloudfunctions_function" {
  title = "function"

  sql = <<-EOQ
    select
      i.self_link as to_id,
      s.self_link as from_id
    from
      gcp_cloudfunctions_function as i
      join unnest($1::text[]) as a on i.self_link = a and i.project = split_part(a, '/', 6),
      gcp_cloud_run_service as s
    where
      i.name = s.name;
  EOQ

  param "cloudfunctions_function_self_link" {}
}
