locals {
  proxy_apps = var.proxy_apps_obj

  proxy_access_bindings = merge([
    for app_key, app in local.proxy_apps : {
      for rule in try(app.access, []) :
      "${app_key}:${rule.group}" => {
        app_key = app_key
        group   = rule.group
        order   = rule.order
      }
    }
  ]...)
}

# Proxy Provider (mode = proxy, Authentik's own recommended pattern for apps with no
# OIDC/SAML support and no forced-external-auth setting of their own — see
# https://integrations.goauthentik.io/media/sonarr/) for apps like SABnzbd, and eventually
# Sonarr/Radarr/Prowlarr. Each app gets its own dedicated provider + application. The
# outpost is the actual reverse proxy here (auth check + backend-proxying in one path via
# internal_host) — deliberately NOT forward_single/forward_domain mode, which splits auth
# checking (Caddy calling /outpost.goauthentik.io/auth/caddy) from backend-proxying
# (Caddy's own separate reverse_proxy) into two paths. That split was tried first and the
# auth-check endpoint returned 200 for fully anonymous requests with no session — root
# cause undetermined even after checking skip_path_regex — so Caddy proceeded to the
# backend unauthenticated. Full Proxy mode has no such split: the outpost either forwards
# an authenticated request to internal_host or it doesn't forward at all.
#
# These are served by Authentik's built-in Embedded Outpost — but unlike modules/authentik/ldap.tf's
# dedicated outpost, a new Proxy Provider is NOT auto-attached to it. Confirmed by testing:
# the outpost's /outpost.goauthentik.io/auth/caddy check 404s until the provider is
# explicitly attached via authentik_outpost_provider_attachment below.
data "authentik_outpost" "embedded" {
  name = "authentik Embedded Outpost"
}

resource "authentik_provider_proxy" "apps" {
  for_each = local.proxy_apps

  name               = each.value.provider.name
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  invalidation_flow  = data.authentik_flow.default-invalidation-flow.id

  mode          = "proxy"
  external_host = each.value.provider.external_host
  internal_host = each.value.provider.internal_host
}

resource "authentik_outpost_provider_attachment" "apps" {
  for_each = local.proxy_apps

  outpost           = data.authentik_outpost.embedded.id
  protocol_provider = authentik_provider_proxy.apps[each.key].id
}

resource "authentik_application" "proxy_apps" {
  for_each = local.proxy_apps

  name              = each.value.name
  slug              = each.value.slug
  protocol_provider = authentik_provider_proxy.apps[each.key].id
}

resource "authentik_policy_binding" "proxy_access" {
  for_each = local.proxy_access_bindings

  target = authentik_application.proxy_apps[each.value.app_key].uuid
  group  = authentik_group.groups[each.value.group].id
  order  = each.value.order
}
