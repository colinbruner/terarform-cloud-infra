
# Cloud Storage bucket
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

###
# Bucket
###
resource "google_storage_bucket" "default" {
  name                        = "${random_id.bucket_prefix.hex}-my-bucket"
  location                    = "us-east1"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  // delete bucket and contents on destroy.
  force_destroy = true
  // Assign specialty files
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}


# make bucket public
resource "google_storage_bucket_iam_member" "default" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "index_page" {
  name    = "index.html"
  bucket  = google_storage_bucket.default.name
  content = <<-EOT
    <html><body>
    <h1>Congratulations on setting up Google Cloud CDN with Storage backend!</h1>
    </body></html>
  EOT
}

resource "google_storage_bucket_object" "error_page" {
  name    = "404.html"
  bucket  = google_storage_bucket.default.name
  content = <<-EOT
    <html><body>
    <h1>404 Error: Object you are looking for is no longer available!</h1>
    </body></html>
  EOT
}

# image object for testing, try to access http://<your_lb_ip_address>/test.jpg
resource "google_storage_bucket_object" "test_image" {
  name = "test-object"
  # Uncomment and add valid path to an object.
  #  source       = "/path/to/an/object"
  #  content_type = "image/jpeg"

  # Delete after uncommenting above source and content_type attributes
  content      = "Data as string to be uploaded"
  content_type = "text/plain"

  bucket = google_storage_bucket.default.name
}

###
# Network
###
# reserve IP address
resource "google_compute_global_address" "default" {
  name = "example-ip"
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
  #target                = google_compute_target_http_proxy.default.id
}

# http proxy
#resource "google_compute_target_http_proxy" "default" {
#  name    = "http-lb-proxy"
#  url_map = google_compute_url_map.default.id
#}

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

# url map
resource "google_compute_url_map" "default" {
  name            = "http-lb"
  default_service = google_compute_backend_bucket.default.id
}

# backend bucket with CDN policy with default ttl settings
resource "google_compute_backend_bucket" "default" {
  name        = "cat-backend-bucket"
  description = "Contains beautiful images"
  bucket_name = google_storage_bucket.default.name
  enable_cdn  = true
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}
