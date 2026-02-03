terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.12.0"
    }
    sops = {
      source = "carlpett/sops"
    }
  }
}

provider "authentik" {
  url   = var.authentik_url
  token = var.authentik_token
}

data "sops_file" "users" {
  source_file = "${path.module}/secrets/users.sops.json"
}

data "sops_file" "apps" {
  source_file = "${path.module}/secrets/apps.sops.json"
}

locals {
  users_obj = jsondecode(nonsensitive(data.sops_file.users.raw)).users
  apps_raw  = jsondecode(nonsensitive(data.sops_file.apps.raw)).apps

  apps_obj = {
    for app_key, app in local.apps_raw : app_key => {
      name            = app.name
      slug            = app.slug
      meta_launch_url = try(app.meta_launch_url, null)
      access          = try(app.access, [])

      provider = {
        name                 = app.provider.name
        client_id            = app.provider.client_id
        client_secret        = app.provider.client_secret
        allowed_redirect_uris = app.provider.allowed_redirect_uris

        logout_method = try(app.provider.logout_method, null)
        logout_uri    = try(app.provider.logout_uri, null)
      }
    }
  }
}
