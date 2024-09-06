resource "google_compute_disk" "lightnodes" {
  count = local.number_of_lightnodes

  name = "${local.compute_name}-lightnode-disk-${count.index}"
  type = "pd-ssd"
  zone = local.zone
  size = 1000
}

resource "google_compute_instance" "lightnodes" {
  count = local.number_of_lightnodes

  name         = "${local.compute_name}-lightnode-${count.index}"
  machine_type = local.machine_type
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.this.self_link
      size  = 1000
    }
  }

  attached_disk {
    source = google_compute_disk.lightnodes[count.index].self_link
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("start-up-script.sh")
  }

  tags = ["allow-iap-ssh", "allow-protocol", "allow-egress"]

  network_interface {
    # network = "default"
    network    = google_compute_network.this.self_link
    subnetwork = google_compute_subnetwork.this.self_link
    access_config {
      nat_ip = google_compute_address.static_ip_lightnode[count.index].address
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

resource "google_compute_instance_group" "lightnodes" {
  name        = "${local.prefix}-lightnodes-group"
  description = "Lightnodes group"
  zone        = local.zone

  instances = google_compute_instance.lightnodes[*].self_link

  named_port {
    name = "jsonrpc"
    port = 9944
  }

  named_port {
    name = "libp2p"
    port = 30333
  }

  named_port {
    name = "libp2pws"
    port = 30334
  }
}


resource "google_compute_health_check" "lightnodes-jsonrpc" {
  name               = "${local.prefix}-lightnodes-health-check"
  timeout_sec        = 5
  check_interval_sec = 10

  tcp_health_check {
    port = 9944
  }
}

resource "google_compute_backend_service" "lightnodes-jsonrpc-tcp" {
  name        = "${local.prefix}-lightnodes-backend-service"
  protocol    = "TCP"
  port_name   = "jsonrpc"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  # locality_lb_policy    = "RING_HASH"
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.lightnodes.self_link
  }

  health_checks = [google_compute_health_check.lightnodes-jsonrpc.self_link]
}

resource "google_compute_backend_service" "lightnodes-jsonrpc-http" {
  name        = "${local.prefix}-lightnodes-backend-service-over-http"
  protocol    = "HTTP"
  port_name   = "jsonrpc"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  # locality_lb_policy    = "RING_HASH"
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.lightnodes.self_link
  }

  health_checks = [google_compute_health_check.lightnodes-jsonrpc.self_link]
}

resource "google_compute_backend_service" "lightnodes-libp2p" {
  name        = "${local.prefix}-lightnodes-backend-service-over-libp2p"
  protocol    = "TCP"
  port_name   = "libp2p"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  # locality_lb_policy    = "RING_HASH"
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.lightnodes.self_link
  }

  health_checks = [google_compute_health_check.lightnodes-jsonrpc.self_link]
}

resource "google_compute_backend_service" "lightnodes-libp2pws" {
  name        = "${local.prefix}-lightnodes-backend-service-over-libp2pws"
  protocol    = "TCP"
  port_name   = "libp2pws"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  # locality_lb_policy    = "RING_HASH"
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.lightnodes.self_link
  }

  health_checks = [google_compute_health_check.lightnodes-jsonrpc.self_link]
}
