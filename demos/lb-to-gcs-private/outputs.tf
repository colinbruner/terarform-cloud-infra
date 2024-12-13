
output "cmd" {
  # trust local secrets/cert.pem, force resolve by fqdn
  value = "curl -I --cacert secrets/cert.pem https://mydemo.example.com --resolve mydemo.example.com:443:${google_compute_global_address.default.address}"
}
