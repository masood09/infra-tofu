locals {
  ldap_enabled = var.ldap_obj != null
}

data "authentik_flow" "default-authentication-flow" {
  count = local.ldap_enabled ? 1 : 0
  slug  = "default-authentication-flow"
}

resource "authentik_rbac_role" "jellyfin_ldap_search" {
  count = local.ldap_enabled ? 1 : 0
  name  = "jellyfin-ldap-search"
}

resource "authentik_user" "jellyfin_ldap_bind" {
  count    = local.ldap_enabled ? 1 : 0
  username = "jellyfin-ldap-bind"
  name     = "Jellyfin LDAP Bind"
  type     = "service_account"
  roles    = [authentik_rbac_role.jellyfin_ldap_search[0].id]
}

# Bind/search access alone isn't enough — without this object permission, the LDAP
# outpost only exposes the bind account's own entry (and nothing else: no real users,
# no groups), even though the bind itself succeeds. Confirmed via Authentik's own docs:
# up to 2024.8 this was a provider-level "Search group" setting, since migrated to this
# RBAC permission.
#
# NOT managed here — authentik_rbac_permission_role hits a confirmed, currently-open
# upstream provider bug (goauthentik/terraform-provider-authentik#845): it POSTs a single
# permission where the API requires an array, and fails with 405 on every apply. One-time
# manual step instead: Authentik admin console -> Directory -> Roles ->
# "jellyfin-ldap-search" -> assign the "Search full LDAP directory" permission
# (scoped to the "Jellyfin LDAP" provider object, not global).

resource "authentik_token" "jellyfin_ldap_bind" {
  count        = local.ldap_enabled ? 1 : 0
  identifier   = "jellyfin-ldap-bind-token"
  user         = authentik_user.jellyfin_ldap_bind[0].id
  description  = "LDAP bind credential for Jellyfin's LDAP Authentication plugin"
  intent       = "app_password"
  expiring     = false
  retrieve_key = true
}

resource "authentik_provider_ldap" "jellyfin" {
  count       = local.ldap_enabled ? 1 : 0
  name        = "Jellyfin LDAP"
  base_dn     = var.ldap_obj.base_dn
  bind_flow   = data.authentik_flow.default-authentication-flow[0].id
  unbind_flow = data.authentik_flow.default-invalidation-flow.id
}

resource "authentik_application" "jellyfin_ldap" {
  count             = local.ldap_enabled ? 1 : 0
  name              = "Jellyfin"
  slug              = "jellyfin"
  protocol_provider = authentik_provider_ldap.jellyfin[0].id
}

resource "authentik_outpost" "jellyfin_ldap" {
  count              = local.ldap_enabled ? 1 : 0
  name               = "Jellyfin LDAP Outpost"
  type               = "ldap"
  protocol_providers = [authentik_provider_ldap.jellyfin[0].id]
}

resource "authentik_policy_binding" "jellyfin_ldap_access" {
  for_each = local.ldap_enabled ? toset(var.ldap_obj.access_groups) : toset([])

  target = authentik_application.jellyfin_ldap[0].uuid
  group  = authentik_group.groups[each.key].id
  order  = 10
}

# The bind service account itself needs access to the application too — Authentik
# denies it "Insufficient Access Rights" on bind/search otherwise, even with a valid
# token, since access-group membership only covers end users, not the outpost's own
# bind identity.
resource "authentik_policy_binding" "jellyfin_ldap_bind_access" {
  count = local.ldap_enabled ? 1 : 0

  target = authentik_application.jellyfin_ldap[0].uuid
  user   = authentik_user.jellyfin_ldap_bind[0].id
  order  = 0
}

output "jellyfin_ldap_bind_password" {
  value     = local.ldap_enabled ? authentik_token.jellyfin_ldap_bind[0].key : null
  sensitive = true
}
