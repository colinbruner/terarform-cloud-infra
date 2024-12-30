# Demo: Private GCS Bucket through Cloud CDN

Terraform HTTPS LB with Private GCS Bucket sans intelligent caching configurations.

Loosely Terraform-ified from: https://medium.com/@thetechbytes/private-gcs-bucket-access-through-google-cloud-cdn-430d940ebad9

## Creating

```bash
# after reconfiguring backend, run
$ terraform init
$ terraform apply
$ terraform out
# returns curl command with IP
```

## OpenSSL Command Generation

```bash
# rsa:4096 not supported
cd secrets/ && openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=mydemo.example.com"
```
