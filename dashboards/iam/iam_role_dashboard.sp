dashboard "gcp_iam_role_dashboard" {

  title         = "GCP IAM Role Dashboard"
  documentation = file("./dashboards/iam/docs/iam_role_dashboard.md")

  tags = merge(local.iam_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.gcp_iam_role_count
      width = 2
    }

    card {
      query = query.gcp_iam_role_customer_managed_count
      width = 2
    }

    card {
      query = query.gcp_iam_role_beta_stage_count
      width = 2
    }

  }

  container {

    title = "Analysis"

    chart {
      title = "Roles by Project"
      query = query.gcp_iam_role_by_project
      type  = "column"
      width = 4
    }

    chart {
      title = "Roles by Stage"
      query = query.gcp_iam_role_by_stage
      type  = "column"
      width = 4
    }

    chart {
      title = "Roles by Type"
      query = query.gcp_iam_role_by_type
      type  = "column"
      width = 4
    }

  }

}

# Card Queries

query "gcp_iam_role_count" {
  sql = <<-EOQ
    select count(*) as "Roles" from gcp_iam_role;
  EOQ
}

query "gcp_iam_role_customer_managed_count" {
  sql = <<-EOQ
    select count(*) as "Customer-Managed" from gcp_iam_role where not is_gcp_managed;
  EOQ
}

query "gcp_iam_role_beta_stage_count" {
  sql = <<-EOQ
    select count(*) as "BETA Stage" from gcp_iam_role where stage = 'BETA';
  EOQ
}

# Analysis Queries

query "gcp_iam_role_by_project" {
  sql = <<-EOQ
    select
      p.title as "project",
      count(r.*) as "total"
    from
      gcp_iam_role as r,
      gcp_project as p
    where
      p.project_id = r.project
    group by
      p.title
    order by 
      count(r.*) desc;
  EOQ
}

query "gcp_iam_role_by_stage" {
  sql = <<-EOQ
    select
      stage,
      count(r.*) as total
    from
      gcp_iam_role as r
    group by
      stage;
  EOQ
}

query "gcp_iam_role_by_type" {
  sql = <<-EOQ
    select
      case when is_gcp_managed then 'GCP managed' else 'customer managed' end as type,
      count(r.*) as total
    from
      gcp_iam_role as r
    group by
      type;
  EOQ
}
