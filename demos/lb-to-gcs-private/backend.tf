terraform {
  backend "gcs" {
    bucket = "bruner-infra"
    prefix = "demos/lb-to-gcs-private/"
  }
}
