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
