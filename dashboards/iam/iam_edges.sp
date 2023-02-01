edge "iam_member_to_iam_role" {
  title = "role"

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

edge "iam_service_account_to_cloudfunction_function" {
  title = "function"

  sql = <<-EOQ
    select
      s.name as from_id,
      f.name as to_id
    from
      gcp_cloudfunctions_function as f,
      gcp_service_account as s
    where
      f.service_account_email = s.email
      and s.name = any($1);
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
      gcp_compute_firewall,
      jsonb_array_elements_text(source_service_accounts) as s
    where
      s = any($1);
  EOQ

  param "iam_service_account_names" {}
}

edge "iam_service_account_to_compute_instance" {
  title = "compute instance"

  sql = <<-EOQ
    select
      s.name as from_id,
      i.id::text as to_id
    from
      gcp_service_account as s,
      gcp_compute_instance as i,
      jsonb_array_elements(service_accounts) as sa
    where
      sa ->> 'email' = s.email
      and s.name = any($1);
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
      gcp_service_account as s,
      gcp_compute_instance_template as t,
      jsonb_array_elements(instance_service_accounts) as tsa
    where
      tsa ->> 'email' = s.email
      and s.name = any($1);
  EOQ

  param "iam_service_account_names" {}
}

edge "iam_service_account_to_iam_member" {
  title = "member"

  sql = <<-EOQ
    select
      name as from_id,
      split_part(m,':',2) as to_id
    from
      gcp_service_account,
      jsonb_array_elements(iam_policy -> 'bindings') as b,
      jsonb_array_elements_text(b-> 'members') as m
    where
      name = any($1);
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
    where
      service_account_name = any($1);
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
    where
      p.push_config_oidc_token_service_account_email = s.email
      and s.name = any($1);
  EOQ

  param "iam_service_account_names" {}
}