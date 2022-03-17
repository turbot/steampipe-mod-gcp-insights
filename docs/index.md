---
repository: "https://github.com/turbot/steampipe-mod-gcp-insights"
---

# GCP Insights Mod

Create dashboards and reports for your GCP resources using Steampipe.

<!-- TODO - Add links for images -->

## Overview

Dashboards can help answer questions like:

- How many resources do I have?
- How old are my resources?
- Are there any publicly accessible resources?
- Is encryption enabled and what keys are used for encryption?
- Is versioning enabled?

Dashboards are available for Compute, IAM, KMS, Kubernetes and Storage services.

## References

[GCP](https://gcp.amazon.com/) provides on-demand cloud computing platforms and APIs to authenticated customers on a metered pay-as-you-go basis.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration, and `dashboards` that organize and display key pieces of information.

## Documentation

- **[Dashboards →](https://hub.steampipe.io/mods/turbot/gcp_insights/dashboards)**

## Getting started

### Installation

1) Install the GCP plugin:

```shell
steampipe plugin install gcp
```

2) Clone this repo:

```sh
git clone https://github.com/turbot/steampipe-mod-gcp-insights.git
cd steampipe-mod-gcp-insights
```

### Usage

Start your dashboard server to get started:

```shell
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194.

From here, you can view all of your dashboards and reports.

### Credentials

This mod uses the credentials configured in the [Steampipe GCP plugin](https://hub.steampipe.io/plugins/turbot/gcp).

## Get involved

* Contribute: [GitHub Repo](https://github.com/turbot/steampipe-mod-gcp-insights)
* Community: [Slack Channel](https://steampipe.io/community/join)
