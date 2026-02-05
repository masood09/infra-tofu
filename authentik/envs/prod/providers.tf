terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.12.1"
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
        client_type          = try(app.provider.client_type, "confidential")
        client_id            = app.provider.client_id
        client_secret        = try(app.provider.client_secret, null)
        allowed_redirect_uris = app.provider.allowed_redirect_uris

        access_code_validity    = try(app.provider.access_code_validity, "minutes=1")
        access_token_validity   = try(app.provider.access_token_validity, "minutes=10")
        refresh_token_threshold = try(app.provider.refresh_token_threshold, "seconds=0")
        refresh_token_validity  = try(app.provider.refresh_token_validity, "days=30")

        sub_mode = try(app.provider.sub_mode, "hashed_user_id")
        extra_managed_scopes = try(app.provider.extra_managed_scopes, [])

        logout_method = try(app.provider.logout_method, null)
        logout_uri    = try(app.provider.logout_uri, null)
      }
    }
  }
}
