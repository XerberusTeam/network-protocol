resource "google_compute_global_address" "rpc" {
  name = "${local.prefix}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "${local.prefix}-https-forwarding-rule"
  target     = google_compute_target_https_proxy.https.self_link
  port_range = "443"
  ip_address = google_compute_global_address.rpc.address
}

resource "google_compute_global_forwarding_rule" "rpc" {
  name       = "${local.prefix}-rpc-forwarding-rule"
  target     = google_compute_target_tcp_proxy.rpc.self_link
  port_range = "9933"
  ip_address = google_compute_global_address.rpc.address
}

resource "google_compute_global_forwarding_rule" "p2p" {
  name       = "${local.prefix}-p2p-forwarding-rule"
  target     = google_compute_target_tcp_proxy.p2p.self_link
  port_range = "30333"
  ip_address = google_compute_global_address.rpc.address
}

resource "google_compute_global_forwarding_rule" "metrics" {
  name       = "${local.prefix}-metrics-forwarding-rule"
  target     = google_compute_target_tcp_proxy.metrics.self_link
  port_range = "9615"
  ip_address = google_compute_global_address.rpc.address
}

resource "google_compute_target_tcp_proxy" "rpc" {
  name            = "${local.prefix}-rpc-tcp-proxy"
  backend_service = google_compute_backend_service.rpc.self_link
}

resource "google_compute_target_tcp_proxy" "p2p" {
  name            = "${local.prefix}-p2p-tcp-proxy"
  backend_service = google_compute_backend_service.p2p.self_link
}

resource "google_compute_target_tcp_proxy" "metrics" {
  name            = "${local.prefix}-metrics-tcp-proxy"
  backend_service = google_compute_backend_service.metrics.self_link
}

resource "google_compute_target_https_proxy" "https" {
  name             = "${local.prefix}-https-proxy"
  url_map          = google_compute_url_map.https.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.self_link]
}

resource "google_compute_url_map" "https" {
  name            = "${local.prefix}-url-map"
  default_service = google_compute_backend_service.rpc-http.self_link
}

resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "${local.prefix}-ssl-cert"

  managed {
    domains = ["node.xerberus.io"]
  }
}
