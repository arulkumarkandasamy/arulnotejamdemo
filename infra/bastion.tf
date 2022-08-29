data "template_file" "default" {
  template = "${file("startup.sh")}"
  vars = {
    address = "some value"
  }
}

resource "google_service_account" "notejam-bastion" {
  account_id   = var.service_account_name
  display_name = var.service_account_name
}

resource "google_compute_instance" "notejam-bastion" {
  project = var.project_name
  zone    = var.zone
  name    = var.instance_name

  machine_type = var.machine_type

  tags = [var.tag]

  network_interface {
    subnetwork         = google_compute_subnetwork.public-notejam-subnet.self_link
    subnetwork_project = var.project_name
  }

  service_account {
    email  = google_service_account.notejam-bastion.email
    scopes = var.scopes
  }

  boot_disk {
    initialize_params {
      image = var.image
    }
  }  

  metadata_startup_script = "${data.template_file.default.rendered}"

  shielded_instance_config {
    enable_secure_boot = (var.shielded_vm == true ? true : false)
  }
}

# Allow SSHing into machines tagged "allow-ssh"
resource "google_compute_firewall" "allow_ssh" {
  project = var.project_name
  name    = "allow-iap-ssh"
  network = google_compute_network.notejam-network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "2222", "8888"]
  }

  # Allow SSH only from IAP
  source_ranges  = ["35.235.240.0/20", "86.159.161.228/32"]
  target_tags = [var.tag]
}

resource "google_compute_firewall" "allow_from_bastion" {
  project = var.project_name
  name    = "allow-from-bastion"
  network = google_compute_network.notejam-network.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3389"]
  }

  # Allow management traffic from bastion
  source_tags = [var.tag]
}

resource "google_iap_tunnel_instance_iam_binding" "enable_iap" {
  project    = var.project_name
  zone       = var.zone
  instance   = var.instance_name
  role       = "roles/iap.tunnelResourceAccessor"
  members    = var.members
  depends_on = [google_compute_instance.notejam-bastion]
}