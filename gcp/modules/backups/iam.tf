###
# SA
###
resource "google_service_account" "backups" {
  account_id   = "${var.name}-backups-${random_id.this.hex}"
  display_name = "UNAS Volume ${var.name} Service Account for Backups"
}

resource "google_storage_bucket_iam_member" "backups" {
  bucket = google_storage_bucket.backups.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.backups.email}"
}

resource "google_service_account_key" "backups" {
  service_account_id = google_service_account.backups.name
}
