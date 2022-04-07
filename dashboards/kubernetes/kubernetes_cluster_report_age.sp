dashboard "gcp_kubernetes_cluster_age_report" {

  title         = "GCP Kubernetes Cluster Age Report"
  documentation = file("./dashboards/kubernetes/docs/kubernetes_cluster_report_age.md")

  tags = merge(local.kubernetes_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      query = query.gcp_kubernetes_cluster_count
      width = 2
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_kubernetes_cluster_24_hours_count
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_kubernetes_cluster_30_days_count
    }

    card {
      type  = "info"
      width = 2
      query = query.gcp_kubernetes_cluster_30_90_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.gcp_kubernetes_cluster_90_365_days_count
    }

    card {
      width = 2
      type  = "info"
      query = query.gcp_kubernetes_cluster_1_year_count
    }

  }

  table {
    column "Project ID" {
      display = "none"
    }

    column "Self-Link" {
      display = "none"
    }

    column "Name" {
      href = "${dashboard.gcp_kubernetes_cluster_detail.url_path}?input.cluster_name={{.Name | @uri}}"
    }

    query = query.gcp_kubernetes_cluster_age_table
  }

}

query "gcp_kubernetes_cluster_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      gcp_kubernetes_cluster
    where
      create_time > now() - '1 days' :: interval;
  EOQ
}

query "gcp_kubernetes_cluster_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      gcp_kubernetes_cluster
    where
      create_time between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "gcp_kubernetes_cluster_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      gcp_kubernetes_cluster
    where
      create_time between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "gcp_kubernetes_cluster_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      gcp_kubernetes_cluster
    where
      create_time between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "gcp_kubernetes_cluster_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      gcp_kubernetes_cluster
    where
      create_time <= now() - '1 year' :: interval;
  EOQ
}

query "gcp_kubernetes_cluster_age_table" {
  sql = <<-EOQ
    select
      c.name as "Name",
      now()::date - c.create_time::date as "Age in Days",
      c.create_time as "Create Time",
      c.status as "Status",
      p.name as "Project",
      p.project_id as "Project ID",
      c.location as "Location",
      c.self_link as "Self-Link"
    from
      gcp_kubernetes_cluster as c,
      gcp_project as p
    where
      p.project_id = c.project
    order by
      c.name;
  EOQ
}

