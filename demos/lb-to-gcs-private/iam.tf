
resource "google_service_account" "this" {
  account_id   = "demo-sa-${random_id.this.hex}"
  display_name = "Demo Private GCS CDN Service Account"
}

resource "google_storage_bucket_iam_member" "storage_admin" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.admin"
  member = google_service_account.this.member
}

resource "google_storage_hmac_key" "key" {
  service_account_email = google_service_account.this.email
}
