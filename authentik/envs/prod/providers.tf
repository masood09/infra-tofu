terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2026.5.1"
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

# Optional — only read once secrets/ldap.sops.json has been created (see
# docs on adding a new LDAP app). Absent, ldap_obj stays null and the shared
# module's Jellyfin LDAP resources (modules/authentik/ldap.tf) are skipped.
data "sops_file" "ldap" {
  count       = fileexists("${path.module}/secrets/ldap.sops.json") ? 1 : 0
  source_file = "${path.module}/secrets/ldap.sops.json"
}

# Optional — Proxy Provider apps for services with no OIDC/SAML support of their own
# (SABnzbd, and eventually Sonarr/Radarr/Prowlarr). Absent, proxy_apps_obj stays empty
# and modules/authentik/proxy.tf provisions nothing.
data "sops_file" "proxy_apps" {
  count       = fileexists("${path.module}/secrets/proxy-apps.sops.json") ? 1 : 0
  source_file = "${path.module}/secrets/proxy-apps.sops.json"
}

locals {
  users_obj = jsondecode(nonsensitive(data.sops_file.users.raw)).users
  apps_raw  = jsondecode(nonsensitive(data.sops_file.apps.raw)).apps

  ldap_raw = length(data.sops_file.ldap) > 0 ? jsondecode(nonsensitive(data.sops_file.ldap[0].raw)).ldap : null
  ldap_obj = local.ldap_raw == null ? null : {
    base_dn       = local.ldap_raw.base_dn
    access_groups = try(local.ldap_raw.access_groups, [])
  }

  proxy_apps_raw = length(data.sops_file.proxy_apps) > 0 ? jsondecode(nonsensitive(data.sops_file.proxy_apps[0].raw)).proxy_apps : {}
  proxy_apps_obj = {
    for app_key, app in local.proxy_apps_raw : app_key => {
      name   = app.name
      slug   = app.slug
      access = try(app.access, [])

      provider = {
        name          = app.provider.name
        external_host = app.provider.external_host
        internal_host = app.provider.internal_host
      }
    }
  }

  apps_obj = {
    for app_key, app in local.apps_raw : app_key => {
      name            = app.name
      slug            = app.slug
      meta_launch_url = try(app.meta_launch_url, null)
      access          = try(app.access, [])

      provider = {
        name                  = app.provider.name
        client_type           = try(app.provider.client_type, "confidential")
        client_id             = app.provider.client_id
        client_secret         = try(app.provider.client_secret, null)
        allowed_redirect_uris = app.provider.allowed_redirect_uris

        access_code_validity    = try(app.provider.access_code_validity, "minutes=1")
        access_token_validity   = try(app.provider.access_token_validity, "minutes=10")
        refresh_token_threshold = try(app.provider.refresh_token_threshold, "seconds=0")
        refresh_token_validity  = try(app.provider.refresh_token_validity, "days=30")

        sub_mode             = try(app.provider.sub_mode, "hashed_user_id")
        extra_managed_scopes = try(app.provider.extra_managed_scopes, [])

        logout_method = try(app.provider.logout_method, null)
        logout_uri    = try(app.provider.logout_uri, null)
      }
    }
  }
}
