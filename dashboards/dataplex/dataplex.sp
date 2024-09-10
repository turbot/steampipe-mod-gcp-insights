locals {
  dataplex_common_tags = {
    service = "GCP/Dataplex"
  }
}

category "dataplex_task" {
  title = "Dataplex Task"
  color = local.database_color
  icon  = "cube"
}

category "dataplex_lake" {
  title = "Dataplex Lake"
  color = local.database_color
  icon  = "box"
}

category "dataplex_zone" {
  title = "Dataplex Zone"
  color = local.database_color
  icon  = "box"
}