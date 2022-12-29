mod "gcp_insights" {
  # hub metadata
  title         = "GCP Insights"
  description   = "Create dashboards and reports for your GCP resources using Steampipe."
  color         = "#EA4335"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/gcp-insights.svg"
  categories    = ["gcp", "dashboard", "public cloud"]

  opengraph {
    title       = "Steampipe Mod for GCP Insights"
    description = "Create dashboards and reports for your GCP resources using Steampipe."
    image       = "/images/mods/turbot/gcp-insights-social-graphic.png"
  }

  require {
    steampipe = "0.13.1"
    plugin "gcp" {
      version = "0.21.0"
    }
  }
}
