resource "google_compute_network" "notejam-network" {
  name = "${var.vpc_name}-network"
  auto_create_subnetworks = "false"
  routing_mode = "REGIONAL"
}

resource "google_compute_subnetwork" "notejam-subnet" {
  name                     = var.cluster_name
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
  network                  = google_compute_network.notejam-network.self_link
}

resource "google_compute_subnetwork" "public-notejam-subnet" {
  name = var.public_subnet_name
  ip_cidr_range = var.public_subnet_cidr
  region = var.region
  network = google_compute_network.notejam-network.self_link
}

resource "google_compute_firewall" "notejam-firewall-allow-web" {
  name    = "${var.vpc_name}-allow-web"
  network = google_compute_network.notejam-network.self_link
  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443", "3000", "5000"]
  }
  source_ranges = [var.subnet_cidr, var.pod_range, var.service_range, "0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ingress-from-iap"
  network = google_compute_network.notejam-network.self_link  
  allow {
    protocol = "tcp"
    ports    = ["22", "3389", "5900"]
  }
  source_ranges = ["35.235.240.0/20", "0.0.0.0/0"]
}


resource "google_compute_address" "external_nat_ips" {
  count  = var.num_of_external_nat_ips
  name   = "${var.name_external_nat_ips}-${count.index + 1}-${var.name_suffix}"
  region = google_compute_subnetwork.notejam-subnet.region
}

resource "google_compute_router" "notejam-router" {
  name = "${var.vpc_name}-nat-router"
  network = google_compute_network.notejam-network.self_link
}

resource "google_compute_router_nat" "cloud_nat" {
  name                                = local.cloud_nat_name
  router                              = google_compute_router.notejam-router.name
  region                              = google_compute_subnetwork.notejam-subnet.region
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option              = local.nat_ip_allocate_option
  nat_ips                             = local.selected_nat_ips.*.self_link
  min_ports_per_vm                    = var.nat_min_ports_per_vm
  enable_endpoint_independent_mapping = var.nat_enable_endpoint_independent_mapping
  log_config {
    # If the NAT gateway runs out of NAT IP addresses, Cloud NAT drops packets.
    # Dropped packets are logged when error logging is turned on for Cloud NAT logging.
    # See https://cloud.google.com/nat/docs/ports-and-addresses#addresses
    enable = true
    filter = "ERRORS_ONLY"
  }
  timeouts {
    create = var.nat_timeout
    update = var.nat_timeout
    delete = var.nat_timeout
  }
}

