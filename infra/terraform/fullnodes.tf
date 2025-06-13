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

  tags = ["allow-iap-ssh", "allow-protocol", "http-server", "https-server", "allow-egress"]

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

resource "google_compute_instance_group" "multiple" {
  name        = "${local.prefix}-instance-group"
  description = "Node instance group"
  zone        = local.zone

  instances = google_compute_instance.multiple[*].self_link
  
  depends_on = [google_compute_instance.multiple]

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

resource "google_compute_health_check" "rpc" {
  name               = "${local.prefix}-health-check"
  timeout_sec        = 5
  check_interval_sec = 10

  tcp_health_check {
    port = 9933        # Health check on the RPC endpoint
  }
}

resource "google_compute_backend_service" "rpc" {
  name        = "${local.prefix}-rpc-backend"
  protocol    = "TCP"
  port_name   = "rpc"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.multiple.self_link
  }

  health_checks = [google_compute_health_check.rpc.self_link]
}

resource "google_compute_backend_service" "rpc-http" {
  name        = "${local.prefix}-rpc-http-backend"
  protocol    = "HTTP"
  port_name   = "rpc"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.multiple.self_link
  }

  health_checks = [google_compute_health_check.rpc.self_link]
}

resource "google_compute_backend_service" "p2p" {
  name        = "${local.prefix}-p2p-backend"
  protocol    = "TCP"
  port_name   = "p2p"
  timeout_sec = 1800 # 30 minutes, adjust as needed

  connection_draining_timeout_sec = 300

  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.multiple.self_link
  }

  health_checks = [google_compute_health_check.rpc.self_link]
}

resource "google_compute_backend_service" "metrics" {
  name        = "${local.prefix}-metrics-backend"
  protocol    = "TCP"
  port_name   = "metrics"
  timeout_sec = 300 # 5 minutes for metrics

  connection_draining_timeout_sec = 60

  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.multiple.self_link
  }

  health_checks = [google_compute_health_check.rpc.self_link]
}
