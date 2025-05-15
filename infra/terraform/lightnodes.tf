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
  machine_type = local.lightnode_machine_type
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

  tags = ["allow-iap-ssh", "allow-protocol", "http-server", "https-server", "allow-egress"]

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
  
  depends_on = [google_compute_instance.lightnodes]

  named_port {
    name = "rpc"          # JSON-RPC (both HTTP and WebSocket)
    port = 9933
  }

  named_port {
    name = "p2p"          # libp2p WebSocket transport
    port = 30333
  }

  named_port {
    name = "metrics"      # Prometheus metrics
    port = 9615
  }
}

resource "google_compute_health_check" "lightnodes-rpc" {
  name               = "${local.prefix}-lightnodes-health-check"
  timeout_sec        = 5
  check_interval_sec = 10

  tcp_health_check {
    port = 9933        # Health check on the RPC endpoint
  }
}

resource "google_compute_backend_service" "lightnodes-rpc" {
  name        = "${local.prefix}-lightnodes-rpc-backend"
  protocol    = "TCP"
  port_name   = "rpc"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.lightnodes.self_link
  }

  health_checks = [google_compute_health_check.lightnodes-rpc.self_link]
}

resource "google_compute_backend_service" "lightnodes-rpc-http" {
  name        = "${local.prefix}-lightnodes-rpc-http-backend"
  protocol    = "HTTP"
  port_name   = "rpc"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.lightnodes.self_link
  }

  health_checks = [google_compute_health_check.lightnodes-rpc.self_link]
}

resource "google_compute_backend_service" "lightnodes-p2p" {
  name        = "${local.prefix}-lightnodes-p2p-backend"
  protocol    = "TCP"
  port_name   = "p2p"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.lightnodes.self_link
  }

  health_checks = [google_compute_health_check.lightnodes-rpc.self_link]
}

resource "google_compute_backend_service" "lightnodes-metrics" {
  name        = "${local.prefix}-lightnodes-metrics-backend"
  protocol    = "TCP"
  port_name   = "metrics"
  timeout_sec = 300 # 5 minutes for metrics

  connection_draining_timeout_sec = 60

  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.lightnodes.self_link
  }

  health_checks = [google_compute_health_check.lightnodes-rpc.self_link]
}
