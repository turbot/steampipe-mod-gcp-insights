dashboard "gcp_storage_bucket_detail" {

  title = "GCP Storage Bucket Detail"

  tags = merge(local.storage_common_tags, {
    type = "Detail"
  })

  input "bucket_id" {
    title = "Select a bucket:"
    query = query.gcp_storage_bucket_input
    width = 4
  }

  container {

    card {
      query = query.gcp_storage_bucket_public_access
      width = 2
    }

    card {
      query = query.gcp_storage_bucket_versioning_disabled
      width = 2
    }

    card {
      query = query.gcp_storage_bucket_logging_disabled
      width = 2
    }

    card {
      query = query.gcp_storage_bucket_uniform_bucket_level_access_disabled
      width = 2
    }

  }

  container {

    container {
      width = 6

      table {
        title = "Overview"
        type  = "line"
        width = 6
        query = query.gcp_storage_bucket_overview
        args = {
          id = self.input.bucket_id.value
        }

      }

      table {
        title = "Tags"
        width = 6
        query = query.gcp_storage_bucket_tag
        args = {
          id = self.input.bucket_id.value
        }

      }
    }

    container {
      width = 6

      table {
        title = "IAM Policy Binding Details"
        query = query.gcp_storage_bucket_iam_policy
        args = {
          id = self.input.bucket_id.value
        }
      }

      table {
        title = "Retention Policy Details"
        query = query.gcp_storage_bucket_retention_policy
        args = {
          id = self.input.bucket_id.value
        }
      }

      table {
        title = "Lifecycle Rules"
        query = query.gcp_storage_bucket_lifecycle_rules
        args = {
          id = self.input.bucket_id.value
        }
      }

    }

    container {

      table {
        title = "ACL Details"
        query = query.gcp_storage_bucket_acl
        args = {
          id = self.input.bucket_id.value
        }
      }

    }

  }
}

query "gcp_storage_bucket_input" {
  sql = <<EOQ
    select
      name as label,
      id as value,
      json_build_object(
        'region', region,
        'project', project
      ) as tags
    from
      gcp_storage_bucket
    order by
      name;
EOQ
}

query "gcp_storage_bucket_public_access" {
  sql = <<-EOQ
    select
      'Public Access' as label,
      case when iam_policy ->> 'bindings' like any (array ['%allAuthenticatedUsers%','%allUsers%']) then 'Enabled' else 'Disabled' end as value,
      case when iam_policy ->> 'bindings' like any (array ['%allAuthenticatedUsers%','%allUsers%']) then 'alert' else 'ok' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_versioning_disabled" {
  sql = <<-EOQ
    select
      'Versioning' as label,
      case when versioning_enabled then 'Enabled' else 'Disabled' end as value,
      case when versioning_enabled then 'ok' else 'alert' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_logging_disabled" {
  sql = <<-EOQ
    select
      'Logging' as label,
      case when log_bucket is null then 'Disabled' else 'Enabled' end as value,
      case when log_bucket is null then 'alert' else 'ok' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_uniform_bucket_level_access_disabled" {
  sql = <<-EOQ
    select
      'Uniform Access' as label,
      case when iam_configuration_uniform_bucket_level_access_enabled then 'Enabled' else 'Disabled' end as value,
      case when iam_configuration_uniform_bucket_level_access_enabled then 'ok' else 'alert' end as type
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      time_created as "Time Created"
      location_type as "Location Type",
      storage_class as "Storage Class",
      region as "Region",
      id as "ID",
    from
      gcp_storage_bucket
    where
      id = $1;
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_tag" {
  sql = <<-EOQ
    with jsondata as (
      select
      tags::json as tags
    from
      gcp_storage_bucket
    where
      id = $1
    )
    select
      key as "Key",
      value as "Value"
    from
      jsondata,
      json_each_text(tags);
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_iam_policy" {
  sql = <<-EOQ
    select
      b ->> 'role' as "Role",
      b -> 'members' as "Members"
    from
      gcp_storage_bucket,
      jsonb_array_elements(iam_policy -> 'bindings') as b
    where
      id  = $1 and jsonb_typeof(iam_policy -> 'bindings') = 'array';
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_retention_policy" {
  sql = <<-EOQ
    select
      retention_policy ->> 'effectiveTime' as "Effective Time",
      retention_policy -> 'retentionPeriod' as "Retention Period (Second)"
    from
      gcp_storage_bucket
    where
      id  = $1;
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_lifecycle_rules" {
  sql = <<-EOQ
    select
      l ->> 'action' as "Action",
      l ->> 'condition' as "Condition"
    from
      gcp_storage_bucket,
      jsonb_array_elements(lifecycle_rules) as l
    where
      id  = $1 and jsonb_typeof(lifecycle_rules) = 'array';
  EOQ

  param "id" {}
}

query "gcp_storage_bucket_acl" {
  sql = <<-EOQ
    select
      acl ->> 'id' as "ID",
      acl ->> 'kind' as "Kind",
      acl ->> 'role' as "Role",
      acl ->> 'entity' as "Entity",
      acl -> 'projectTeam' ->> 'team' as "Project Team",
      acl -> 'projectTeam' ->> 'projectNumber' as "Project Number"
    from
      gcp_storage_bucket,
      jsonb_array_elements(acl) as acl
    where
      id  = $1 and jsonb_typeof(acl) = 'array';
  EOQ

  param "id" {}
}


