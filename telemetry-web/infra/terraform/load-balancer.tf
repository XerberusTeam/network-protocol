
resource "google_compute_global_address" "web" {
  name = "${local.prefix}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "web-443" {
  name       = "${local.prefix}-https-forwarding-rule"
  target     = google_compute_target_https_proxy.web.self_link
  port_range = "443"
  ip_address = google_compute_global_address.web.address
}

resource "google_compute_global_forwarding_rule" "target-port" {
  name       = "${local.prefix}-tcp-forwarding-rule"
  target     = google_compute_target_tcp_proxy.web.self_link
  port_range = local.target_port
  ip_address = google_compute_global_address.web.address
}

resource "google_compute_global_forwarding_rule" "web-80" {
  name       = "${local.prefix}-web-forwarding-rule"
  target     = google_compute_target_http_proxy.web.self_link
  port_range = "80"
  ip_address = google_compute_global_address.web.address
}

resource "google_compute_target_tcp_proxy" "web" {
  name            = "${local.prefix}-tcp-proxy"
  backend_service = google_compute_backend_service.web-tcp.self_link
}

resource "google_compute_target_http_proxy" "web" {
  name    = "${local.prefix}-web80-proxy"
  url_map = google_compute_url_map.web.self_link
}

resource "google_compute_target_https_proxy" "web" {
  name             = "${local.prefix}-https-proxy"
  url_map          = google_compute_url_map.web.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.web.self_link]
}

resource "google_compute_url_map" "web" {
  name            = "${local.prefix}-url-map"
  default_service = google_compute_backend_service.web-http.self_link
}

resource "google_compute_managed_ssl_certificate" "web" {
  name = "${local.prefix}-ssl-cert"

  managed {
    domains = local.domains
  }
}
