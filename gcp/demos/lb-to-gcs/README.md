# Terraform Demo

Takes the Terraform example from https://cloud.google.com/cdn/docs/cdn-terraform-examples and fixes error. Additionally, add a self-signed HTTPS frontend to LB

## OpenSSL Command Generation

```bash
# rsa:4096 not supported
cd secrets/ && openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=mydemo.example.com"
```
