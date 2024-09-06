
resource "google_compute_global_address" "jsonrpc" {
  name = "${local.prefix}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "jsonrpc-443" {
  name       = "${local.prefix}-forwarding-rule"
  target     = google_compute_target_https_proxy.jsonrpc.self_link
  port_range = "443"
  ip_address = google_compute_global_address.jsonrpc.address
}

resource "google_compute_global_forwarding_rule" "jsonrpc-9944" {
  name       = "${local.prefix}-jsonrpc-forwarding-rule"
  target     = google_compute_target_tcp_proxy.jsonrpc.self_link
  port_range = "9944"
  ip_address = google_compute_global_address.jsonrpc.address
}

resource "google_compute_global_forwarding_rule" "libp2p-30333" {
  name       = "${local.prefix}-libp2p-forwarding-rule"
  target     = google_compute_target_tcp_proxy.libp2p.self_link
  port_range = "30333"
  ip_address = google_compute_global_address.jsonrpc.address
}

resource "google_compute_global_forwarding_rule" "libp2p-30334" {
  name       = "${local.prefix}-libp2pws-forwarding-rule"
  target     = google_compute_target_tcp_proxy.libp2pws.self_link
  port_range = "30334"
  ip_address = google_compute_global_address.jsonrpc.address
}

resource "google_compute_target_tcp_proxy" "jsonrpc" {
  name            = "${local.prefix}-tcp-proxy"
  backend_service = google_compute_backend_service.jsonrpc-tcp.self_link
}

resource "google_compute_target_tcp_proxy" "libp2p" {
  name            = "${local.prefix}-libp2p-proxy"
  backend_service = google_compute_backend_service.libp2p.self_link
}

resource "google_compute_target_tcp_proxy" "libp2pws" {
  name            = "${local.prefix}-libp2pws-proxy"
  backend_service = google_compute_backend_service.libp2pws.self_link
}

resource "google_compute_target_https_proxy" "jsonrpc" {
  name             = "${local.prefix}-https-proxy"
  url_map          = google_compute_url_map.jsonrpc.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.jsonrpc.self_link]
}

resource "google_compute_url_map" "jsonrpc" {
  name            = "${local.prefix}-url-map"
  default_service = google_compute_backend_service.jsonrpc-http.self_link
}

resource "google_compute_managed_ssl_certificate" "jsonrpc" {
  name = "${local.prefix}-ssl-cert"

  managed {
    domains = ["node.xerberus.io"]
  }
}
