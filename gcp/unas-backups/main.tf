locals {
  unas_volumes = {
    "documents" = {
      name = "documents"
    }
    "photos" = {
      name = "photos"
    }
    "k8s" = {
      name = "k8s"
    }
  }
}

module "backups" {
  for_each = local.unas_volumes

  source = "../modules/backups"
  name   = each.value.name
}
