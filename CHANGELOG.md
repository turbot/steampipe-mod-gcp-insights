## v0.3 [2022-05-09]

_Enhancements_

- Updated docs/index.md and README with new dashboard screenshots and latest format. ([#31](https://github.com/turbot/steampipe-mod-gcp-insights/pull/31))

_Breaking changes_

- Renamed `gcp_vpc_network_dashboard` to `gcp_compute_network_dashboard` and `gcp_vpc_network_detail` to `gcp_compute_network_detail` to maintain consistency with the GCP plugin.

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
