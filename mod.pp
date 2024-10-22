mod "gcp_insights" {
  # Hub metadata
  title         = "GCP Insights"
  description   = "Create dashboards and reports for your GCP resources using Powerpipe and Steampipe."
  color         = "#EA4335"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/gcp-insights.svg"
  categories    = ["gcp", "dashboard", "public cloud"]

  opengraph {
    title       = "Powerpipe Mod for GCP Insights"
    description = "Create dashboards and reports for your GCP resources using Powerpipe and Steampipe."
    image       = "/images/mods/turbot/gcp-insights-social-graphic.png"
  }

  require {
    plugin "gcp" {
      min_version = "0.32.0"
    }
  }
}
