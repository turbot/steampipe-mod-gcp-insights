locals {
  dataproc_common_tags = {
    service = "GCP/Dataproc"
  }
}

category "dataproc_metastore_service" {
  title = "Dataproc Metastore Service"
  color = local.containers_color
  icon  = "add_a_photo"
}
