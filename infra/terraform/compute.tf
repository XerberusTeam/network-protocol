data "google_compute_image" "this" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_disk" "multiple" {
  count = local.number_of_instances

  name = "${local.compute_name}-disk-${count.index}"
  type = "pd-ssd"
  zone = local.zone
  size = 1000
}

resource "google_compute_instance" "multiple" {
  count = local.number_of_instances

  name         = "${local.compute_name}-${count.index}"
  machine_type = local.machine_type
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.this.self_link
      size  = 1000
    }
  }

  attached_disk {
    source = google_compute_disk.multiple[count.index].self_link
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("start-up-script.sh")
  }

  tags = ["allow-iap-ssh", "allow-protocol"]

  network_interface {
    # network = "default"
    network    = google_compute_network.this.self_link
    subnetwork = google_compute_subnetwork.this.self_link
    access_config {
      nat_ip = google_compute_address.static_ip[count.index].address
    }
  }

  service_account {
    email  = google_service_account.this.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  labels = merge(local.common_tags, {
    instance_number = count.index
  })

  allow_stopping_for_update = true
}

