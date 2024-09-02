resource "google_compute_network" "this" {
  name                    = "${local.prefix}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "${local.prefix}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = local.region
  network       = google_compute_network.this.self_link
}

resource "google_compute_address" "static_ip" {
  count        = local.number_of_instances
  name         = "${local.compute_name}-static-ip-${count.index}"
  region       = local.region
  address_type = "EXTERNAL"
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${local.prefix}-allow-iap-ssh"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP's IP range
  # - https://cloud.google.com/iap/docs/using-tcp-forwarding
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-iap-ssh"]

  depends_on = [google_project_service.iap]
}

resource "google_compute_firewall" "allow_protocol" {
  name    = "${local.prefix}-allow-protocol"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports = [
      "9615",
      "9930",
      "9333",
      "9944",
      "30333",
      "30334",
    ]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-protocol"]
}