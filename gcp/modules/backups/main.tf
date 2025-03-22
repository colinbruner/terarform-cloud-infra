data "google_project" "this" {}

resource "random_id" "this" {
  byte_length = 2
}

###
# Bucket
###
resource "google_storage_bucket" "this" {
  name     = "backup-unas-vol-${var.name}-${random_id.this.hex}"
  location = "US-CENTRAL1" # Cheapest

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = google_kms_crypto_key.this.id
  }

  lifecycle_rule {
    # Nearline in 30 days not accessed
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = 30
    }
  }
  # Coldline in 60 days not accessed
  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
    condition {
      age = 60
    }
  }
  # Archive in 180 days not accessed
  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
    condition {
      age = 180
    }
  }

  # Delete noncurrent object versions after 30 days
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_noncurrent_time = 30
    }
  }

  versioning {
    enabled = true
  }
}
