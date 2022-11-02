locals {
  gcp_sql_database_instance_icon = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_sql_database_instance_light.svg"))
  gcp_sql_database_instance_machine_type_icon = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_sql_database_instance_machine_type_light.svg"))
  gcp_sql_database_instance_data_disk_icon = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_sql_database_instance_data_disk_light.svg"))
  gcp_sql_database_instance_kms_key_icon = format("%s,%s", "data:image/svg+xml;base64", filebase64("./icons/gcp_sql_database_instance_kms_key_light.svg"))
}
