###
# Network
###
# reserve IP address
resource "google_compute_global_address" "default" {
  name = "demo-ip-${random_id.this.hex}"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  #port_range            = "80"
  port_range = "443"
  target     = google_compute_target_https_proxy.default.id
  ip_address = google_compute_global_address.default.id
}

resource "google_compute_target_https_proxy" "default" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

# NOTE: this is for a demo, please dont ever do this outside of a demo
resource "google_compute_ssl_certificate" "default" {
  name        = "my-certificate"
  private_key = file("secrets/key.pem")
  certificate = file("secrets/cert.pem")
}

###
# NEG
###
resource "google_compute_global_network_endpoint_group" "this" {
  provider              = google-beta
  name                  = "my-lb-neg"
  default_port          = "443"
  network_endpoint_type = "INTERNET_FQDN_PORT"

  lifecycle {
    create_before_destroy = true
  }
}

# curl --
resource "google_compute_global_network_endpoint" "this" {
  provider                      = google-beta
  global_network_endpoint_group = google_compute_global_network_endpoint_group.this.name
  fqdn                          = "${google_storage_bucket.default.name}.storage.googleapis.com"
  port                          = 443
}

###
# Backend Service
###
resource "google_compute_backend_service" "default" {
  provider   = google-beta
  name       = "backend-service"
  enable_cdn = true
  protocol   = "HTTPS"

  custom_request_headers  = ["Host: ${google_compute_global_network_endpoint.this.fqdn}"]
  custom_response_headers = ["X-Cache-Hit: {cdn_cache_status}"]

  security_settings {
    aws_v4_authentication {
      access_key    = google_storage_hmac_key.key.secret
      access_key_id = google_storage_hmac_key.key.access_id
      origin_region = "any"
    }
  }

  backend {
    group = google_compute_global_network_endpoint_group.this.id
  }
}
###
# url map
###
resource "google_compute_url_map" "default" {
  name            = "http-lb"
  default_service = google_compute_backend_service.default.id
}
