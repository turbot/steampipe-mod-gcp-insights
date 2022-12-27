node "dns_policy" {
  category = category.dns_policy

  sql = <<-EOQ
    select
      p.id::text,
      p.title,
      jsonb_build_object(
        'ID', p.id,
        'Name', p.name,
        'Enable Logging', p.enable_logging,
        'Enable Inbound Forwarding', p.enable_inbound_forwarding,
        'Location', p.location,
        'Project', project
      ) as properties
    from
      gcp_dns_policy p
    where
      p.id = any($1);
  EOQ

  param "dns_policy_ids" {}
}
