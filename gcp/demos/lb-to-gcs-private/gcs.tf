# Cloud Storage bucket
resource "random_id" "this" {
  byte_length = 8
}

###
# Bucket
###
resource "google_storage_bucket" "default" {
  name                        = "${random_id.this.hex}-my-bucket"
  location                    = "us-east1"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  // delete bucket and contents on destroy.
  force_destroy = true
  // Assign specialty files
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

###
# Add Objects
###
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
