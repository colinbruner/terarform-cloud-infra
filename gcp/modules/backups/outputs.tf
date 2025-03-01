output "backups_service_account" {
  sensitive = true
  value = {
    email = google_service_account.backups.email
    key   = base64decode(google_service_account_key.backups.private_key)
  }
}
