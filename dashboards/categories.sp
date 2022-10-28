category "gcp_compute_backend_bucket" {
  fold {
    title     = "Compute Backend Bucket"
    threshold = 3
  }
}

category "gcp_compute_disk" {
  href = "/gcp_insights.dashboard.gcp_compute_disk_detail?input.id={{.properties.'ID' | @uri}}"
  fold {
    title     = "Compute Disk"
    threshold = 3
  }
}

category "gcp_compute_instance" {
  href = "/gcp_insights.dashboard.gcp_compute_instance_detail?input.id={{.properties.'ID' | @uri}}"
  fold {
    title     = "Compute Instance"
    threshold = 3
  }
}

category "gcp_compute_image" {
  fold {
    title     = "Compute Image"
    threshold = 3
  }
}

category "gcp_compute_instance_group" {
  fold {
    title     = "Compute Instance Group"
    threshold = 3
  }
}

category "gcp_compute_machine_type" {
  fold {
    title     = "Compute Machine Type"
    threshold = 3
  }
}

category "gcp_compute_network" {
  fold {
    title     = "Compute Network"
    threshold = 3
  }
}

category "gcp_compute_network_interface" {
  fold {
    title     = "Compute Network Interface"
    threshold = 3
  }
}

category "gcp_compute_snapshot" {
  fold {
    title     = "Compute Snapshot"
    threshold = 3
  }
}

category "gcp_compute_subnetwork" {
  fold {
    title     = "Compute Subnetwork"
    threshold = 3
  }
}

category "gcp_kms_key" {
  href = "/gcp_insights.dashboard.gcp_kms_key_detail?input.id={{.properties.'ID' | @uri}}"
  icon = local.gcp_kms_key
  fold {
    title     = "KMS Key"
    icon      = local.gcp_kms_key
    threshold = 3
  }
}

category "gcp_logging_bucket" {
  fold {
    title     = "Logging Bucket"
    threshold = 3
  }
}

category "gcp_storage_bucket" {
  href = "/gcp_insights.dashboard.gcp_storage_bucket_detail?input.id={{.properties.'ID' | @uri}}"
  icon = local.gcp_storage_bucket
  fold {
    title     = "Storage Bucket"
    icon      = local.gcp_storage_bucket
    threshold = 3
  }
}

graph "gcp_graph_categories" {
  type  = "graph"
  title = "Relationships"
}
