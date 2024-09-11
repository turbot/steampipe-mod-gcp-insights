edge "composer_environment_to_kms_key" {
  title = "encrypted with"

  sql = <<-EOQ
    select
      i.name as from_id,
      k.self_link as to_id
    from
      gcp_composer_environment as i
      join unnest($1::text[]) as a on i.name = a and i.project = split_part(a, '/', 2),
      gcp_kms_key as k
    where
      i.encryption_config ->> 'kmsKeyName' = split_part(k.self_link , 'v1/', 2);
  EOQ

  param "composer_environment_names" {}
}

edge "composer_environment_to_iam_service_account" {
  title = "service account"

  sql = <<-EOQ
    select
      i.name as from_id,
      s.name as to_id
    from
      gcp_composer_environment as i
      join unnest($1::text[]) as a on i.name = a and i.project = split_part(a, '/', 2),
      gcp_service_account as s
    where
      i.node_config ->> 'serviceAccount' = s.name;
  EOQ

  param "composer_environment_names" {}
}

edge "composer_environment_to_compute_network" {
  title = "network"

  sql = <<-EOQ
     select
        v.name as from_id,
        n.id::text as to_id
      from
        gcp_composer_environment as v
        join unnest($1::text[]) as a on v.name = a and v.project = split_part(a, '/', 2),
        gcp_compute_network as n
      where
        v.node_config ->> 'network' = split_part(n.self_link , 'v1/', 2);
  EOQ

  param "composer_environment_names" {}
}

edge "composer_environment_to_compute_subnetwork" {
  title = "subnetwork"

  sql = <<-EOQ
     select
        n.id::text as from_id,
        s.id::text as to_id
      from
        gcp_composer_environment as v
        join unnest($1::text[]) as a on v.name = a and v.project = split_part(a, '/', 2),
        gcp_compute_subnetwork as s,
        gcp_compute_network as n
      where
        v.node_config ->> 'subnetwork' = split_part(s.self_link , 'v1/', 2)
        and v.node_config ->> 'network' = split_part(n.self_link , 'v1/', 2);
  EOQ

  param "composer_environment_names" {}
}

edge "composer_environment_to_storage_bucket" {
  title = "storage bucket"

  sql = <<-EOQ
    select
      i.name as from_id,
      (s.id || '/' || s.project) as to_id
    from
      gcp_composer_environment as i
      join unnest($1::text[]) as a on i.name = a and i.project = split_part(a, '/', 2),
      gcp_storage_bucket as s
    where
      i.storage_config_bucket = s.name
      and i.project = s.project
  EOQ

  param "composer_environment_names" {}
}

edge "composer_environment_to_kubernetes_cluster" {
  title = "kubernetes cluster"

  sql = <<-EOQ
    select
      i.name as from_id,
      c.id as to_id
    from
      gcp_composer_environment i
      join unnest($1::text[]) as a on i.name = a and i.project = split_part(a, '/', 2),
      gcp_kubernetes_cluster c
    where
      i.gke_cluster = split_part(c.self_link, 'v1/', 2);
  EOQ

  param "composer_environment_names" {}
}

