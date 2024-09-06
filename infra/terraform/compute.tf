data "google_compute_image" "this" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}