edge "iam_member_to_iam_role" {
  title = "can assume"

  sql = <<-EOQ
    with role_name as (
      select
        name,
        role_name
      from
        gcp_iam_role,
        split_part(name,'roles/',2) as role_name
    )
    select
      split_part(m,':',2) as from_id,
      rn.name as to_id
    from
      role_name as rn,
      gcp_service_account as s,
      jsonb_array_elements(iam_policy -> 'bindings') as b,
      jsonb_array_elements_text(b-> 'members') as m,
      split_part(b ->> 'role','roles/',2) as r
    where
      rn.role_name = r
      and rn.name= any($1);
  EOQ

  param "iam_role_ids" {}
}

edge "iam_role_to_iam_policy" {
  title = "attaches"

  sql = <<-EOQ
    select
      coalesce(b ->> 'role', s.name::text) as from_id,
      p.title as to_id
    from
      gcp_iam_policy as p,
      jsonb_array_elements(bindings) as b,
      jsonb_array_elements_text(b -> 'members') as m,
      split_part(m,'serviceAccount:',2) as member_name,
      split_part(b ->> 'role','roles/',2) as m_role_name,
      gcp_iam_role as r,
      split_part(name,'roles/',2) as role_name,
      gcp_service_account as s
    where
      m like 'serviceAccount:%'
      and m_role_name = role_name
      and r.name = any($1);
  EOQ

  param "iam_role_ids" {}
}

edge "iam_service_account_to_cloudfunction_function" {
  title = "function"

  sql = <<-EOQ
    select
      s.name as from_id,
      f.name as to_id
    from
      gcp_cloudfunctions_function as f,
      gcp_service_account as s
      join unnest($1::text[]) as u on s.name = split_part(u, '/', 1) and s.project = split_part(u, '/', 2)
    where
      f.service_account_email = s.email;
  EOQ

  param "iam_service_account_names" {}
}

edge "iam_service_account_to_compute_firewall" {
  title = "firewall"

  sql = <<-EOQ
    select
      s as from_id,
      id::text as to_id
    from
      gcp_compute_firewall ,
      jsonb_array_elements_text(source_service_accounts) as s
      join unnest($1::text[]) as u on s = split_part(u, '/', 1)
  EOQ

  param "iam_service_account_names" {}
}

edge "iam_service_account_to_compute_instance_template" {
  title = "instance template"

  sql = <<-EOQ
    select
      s.name as from_id,
      t.id::text as to_id
    from
      gcp_service_account as s
      join unnest($1::text[]) as u on s.name = split_part(u, '/', 1),
      gcp_compute_instance_template as t,
      jsonb_array_elements(instance_service_accounts) as tsa
    where
      tsa ->> 'email' = s.email
  EOQ

  param "iam_service_account_names" {}
}

edge "iam_service_account_to_iam_member" {
  title = "has member"

  sql = <<-EOQ
    select
      name as from_id,
      split_part(m,':',2) as to_id
    from
      gcp_service_account
      join unnest($1::text[]) as u on name = split_part(u, '/', 1) and project = split_part(u, '/', 2),
      jsonb_array_elements(iam_policy -> 'bindings') as b,
      jsonb_array_elements_text(b-> 'members') as m
  EOQ

  param "iam_service_account_names" {}
}

edge "iam_service_account_to_iam_role" {
  title = "can assume"

  sql = <<-EOQ
    select
      member_name as from_id,
      b ->> 'role' as to_id
    from
      gcp_iam_policy,
      jsonb_array_elements(bindings) as b,
      jsonb_array_elements_text(b -> 'members') as m,
      split_part(m,'serviceAccount:',2) as member_name
      join unnest($1::text[]) as u on member_name = split_part(u, '/', 1)
    where
      m like 'serviceAccount:%';
  EOQ

  param "iam_service_account_names" {}
}

edge "iam_service_account_to_iam_service_account_key" {
  title = "key"

  sql = <<-EOQ
    select
      service_account_name as from_id,
      name as to_id
    from
      gcp_service_account_key
      join unnest($1::text[]) as u on service_account_name = split_part(u, '/', 1);
  EOQ

  param "iam_service_account_names" {}
}

edge "iam_service_account_to_pubsub_subscription" {
  title = "pubsub subscription"

  sql = <<-EOQ
    select
      s.name as from_id,
      p.self_link as to_id
    from
      gcp_pubsub_subscription as p,
      gcp_service_account as s
      join unnest($1::text[]) as u on s.name = split_part(u, '/', 1) and s.project = split_part(u, '/', 2)
    where
      p.push_config_oidc_token_service_account_email = s.email;
  EOQ

  param "iam_service_account_names" {}
}