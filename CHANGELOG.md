## v1.1.0 [2025-06-26]

_What's new?_

- New dashboards added: ([#94](https://github.com/turbot/steampipe-mod-gcp-insights/pull/94))
  - [GCP Compute Disk Inventory Report](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.compute_disk_report_inventory)
  - [GCP Compute Instance Inventory Report](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.compute_instance_report_inventory)
  - [GCP IAM Service Account Inventory Report](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.iam_service_account_report_inventory)
  - [GCP KMS Key Inventory Report](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.kms_key_report_inventory)
  - [GCP Kubernetes Cluster Inventory Report](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.kubernetes_cluster_report_inventory)
  - [GCP SQL Database Instance Report Inventory](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.sql_database_instance_report_inventory)
  - [GCP Storage Bucket Report Inventory](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.storage_bucket_report_inventory)

## v1.0.0 [2024-10-22]

This mod now requires [Powerpipe](https://powerpipe.io). [Steampipe](https://steampipe.io) users should check the [migration guide](https://powerpipe.io/blog/migrating-from-steampipe).

## v0.9 [2024-05-13]

_Enhancements_

- Queries have been optimized to better work with the connection quals. ([#78](https://github.com/turbot/steampipe-mod-gcp-insights/pull/78))

## v0.8 [2024-03-06]

_Powerpipe_

[Powerpipe](https://powerpipe.io) is now the preferred way to run this mod!  [Migrating from Steampipe →](https://powerpipe.io/blog/migrating-from-steampipe)

All v0.x versions of this mod will work in both Steampipe and Powerpipe, but v1.0.0 onwards will be in Powerpipe format only.

_Enhancements_

- Focus documentation on Powerpipe commands.
- Show how to combine Powerpipe mods with Steampipe plugins.

## v0.7 [2023-11-03]

_Breaking changes_

- Updated the plugin dependency section of the mod to use `min_version` instead of `version`. ([#72](https://github.com/turbot/steampipe-mod-gcp-insights/pull/72))

## v0.6 [2023-08-07]

_Bug fixes_

- Updated the Age Report dashboards to order by the creation time of the resource. ([#66](https://github.com/turbot/steampipe-mod-gcp-insights/pull/66))
- Fixed dashboard localhost URLs in README and index doc. ([#65](https://github.com/turbot/steampipe-mod-gcp-insights/pull/65))

## v0.5 [2023-02-03]

_What's new?_

- New dashboards added: ([#62](https://github.com/turbot/steampipe-mod-gcp-insights/pull/62))
  - [GCP IAM Service Account Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.iam_service_account_detail)

_Enhancements_

- Updated the `card` width across all the dashboards to enhance readability. ([#62](https://github.com/turbot/steampipe-mod-gcp-insights/pull/62))

_Bug fixes_

- Fixed the `GCP Compute Instance Group Detail` dashboard to correctly display the compute network resources associated with the instance group. ([#60](https://github.com/turbot/steampipe-mod-gcp-insights/pull/60))

## v0.4 [2023-01-12]

_Dependencies_

- Steampipe `v0.18.0` or higher is now required. ([#56](https://github.com/turbot/steampipe-mod-gcp-insights/pull/56))
- GCP plugin `v0.32.0` or higher is now required. ([#56](https://github.com/turbot/steampipe-mod-gcp-insights/pull/56))

_What's new?_

- Added resource relationship graphs across all the detail dashboards to highlight the relationship the resource shares with other resources. ([#55](https://github.com/turbot/steampipe-mod-gcp-insights/pull/55))
- New dashboards added: ([#55](https://github.com/turbot/steampipe-mod-gcp-insights/pull/55))
  - [GCP Compute Subnetwork Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.compute_subnetwork_detail)
  - [GCP Pub/Sub Topic Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.pubsub_topic_detail_detail)
  - [GCP SQL Database Instance Dashboard](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.sql_database_instance_dashboard)
  - [GCP SQL Database Instance Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.sql_database_instance_detail)
  - [GCP Storage Bucket Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.storage_bucket_detail)

## v0.3 [2022-05-09]

_Enhancements_

- Updated docs/index.md and README with new dashboard screenshots and latest format. ([#31](https://github.com/turbot/steampipe-mod-gcp-insights/pull/31))

_Breaking changes_

- Renamed dashboard `gcp_vpc_network_dashboard` to `gcp_compute_network_dashboard` and dashboard `gcp_vpc_network_detail` to `gcp_compute_network_detail` to maintain consistency with the GCP plugin.

## v0.2 [2022-04-07]

_What's new?_

- New dashboards added:
  - [Compute Disk Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.gcp_compute_disk_detail) ([#24](https://github.com/turbot/steampipe-mod-gcp-insights/pull/24))
  - [Compute Instance Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.gcp_compute_instance_detail) ([#23](https://github.com/turbot/steampipe-mod-gcp-insights/pull/23))
  - [Kubernetes Cluster Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.gcp_kubernetes_cluster_detail) ([#25](https://github.com/turbot/steampipe-mod-gcp-insights/pull/25))
  - [VPC Network Dashboard](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.gcp_vpc_network_dashboard) ([#26](https://github.com/turbot/steampipe-mod-gcp-insights/pull/26))
  - [VPC Network Detail](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards/dashboard.gcp_vpc_network_detail) ([#27](https://github.com/turbot/steampipe-mod-gcp-insights/pull/27))

## v0.1 [2022-03-21]

_What's new?_

New dashboards and reports for the following services:
- Compute
- IAM
- KMS
- Kubernetes
- Storage
