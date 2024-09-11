locals {
  dataplex_common_tags = {
    service = "GCP/Dataplex"
  }
}

category "dataplex_task" {
  title = "Dataplex Task"
  color = local.database_color
  href  = "/gcp_insights.dashboard.dataplex_task_detail?input.task_id={{.properties.'Self Link' | @uri}}"
  icon  = "cube"
}

category "dataplex_lake" {
  title = "Dataplex Lake"
  color = local.database_color
  href  = "/gcp_insights.dashboard.dataplex_lake_detail?input.lake_self_link={{.properties.'Self Link' | @uri}}"
  icon  = "box"
}

category "dataplex_zone" {
  title = "Dataplex Zone"
  color = local.database_color
  href  = "/gcp_insights.dashboard.dataplex_zone_detail?input.zone_self_link={{.properties.'Self Link' | @uri}}"
  icon  = "box"
}

category "dataplex_asset" {
  title = "Dataplex Asset"
  color = local.database_color
  href  = "/gcp_insights.dashboard.dataplex_asset_detail?input.asset_self_link={{.properties.'Self Link' | @uri}}"
  icon  = "box"
}