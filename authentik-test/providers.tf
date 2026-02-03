terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2025.12.0"
    }
    sops = {
      source = "carlpett/sops"
    }
  }
}

provider "authentik" {
  url   = "https://auth.test.mantannest.com"
  token = var.authentik_token
}

data "sops_file" "users" {
  source_file = "${path.module}/secrets/users.sops.json"
}
