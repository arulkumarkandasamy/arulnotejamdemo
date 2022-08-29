resource "google_container_cluster" "notejam-cluster" {
  provider = google-beta
  name     = var.cluster_name
  location     = var.region
  remove_default_node_pool = true
  initial_node_count       = 1  

  network      = google_compute_network.notejam-network.self_link
  subnetwork   = google_compute_subnetwork.notejam-subnet.self_link

  release_channel {
    channel = var.gke_release_channel
  }
/*
  dynamic "workload_identity_config" {
    for_each = var.enable_workload_identity_config ? [1] : []
    content {
      identity_namespace = "${var.project_name}.svc.id.goog"
    }
  }
*/
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pod_range
    services_ipv4_cidr_block = var.service_range
  }

  master_authorized_networks_config {    
    dynamic "cidr_blocks" {
      for_each     = var.configure_gke_networking ? [1] : []
      content {
        display_name = "trusted-external"
        cidr_block   = google_compute_subnetwork.notejam_subnet[0].ip_cidr_range
        }
      }

    dynamic "cidr_blocks" {
      for_each = local.authorized_networks
      content {
        cidr_block   = cidr_blocks.value["cidr_block"]
        display_name = cidr_blocks.value["display_name"]
      }
    }
  }

  private_cluster_config {
    enable_private_endpoint = var.enable_private_endpoint
    enable_private_nodes   = true
    master_ipv4_cidr_block = var.master_range
  }

  pod_security_policy_config {
    enabled = var.pod_security_policy
  }

  dynamic cluster_autoscaling {
    for_each = var.cluster_autoscaling_config.enabled ? [1] : []
    iterator = config
    content {
      enabled = true
      resource_limits {
        resource_type = "cpu"
        minimum       = config.cpu_min
        maximum       = config.cpu_max
      }
      resource_limits {
        resource_type = "memory"
        minimum       = config.memory_min
        maximum       = config.memory_max
      }
    }
  }

  
  lifecycle {
    ignore_changes = [
      min_master_version,
      node_version
    ]
  }
}

resource "google_container_node_pool" "notejam-pool" {
  provider = google-beta
  name     = var.notejam_pool_name
  location     = var.region
  cluster    = google_container_cluster.notejam-cluster.name
  node_count = var.notejam_pool_node_number
  autoscaling {
    min_node_count = var.notejam_pool_min_node
    max_node_count = var.notejam_pool_max_node
  }
  node_config {
    machine_type     = var.machine_type
    disk_size_gb = var.disk_size_gb
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write", 
      "https://www.googleapis.com/auth/monitoring",
    ]
    service_account = google_service_account.gke_service_account.email
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

