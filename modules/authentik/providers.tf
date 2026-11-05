terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2026.8.2"
    }
    sops = {
      source = "carlpett/sops"
    }
  }
}
