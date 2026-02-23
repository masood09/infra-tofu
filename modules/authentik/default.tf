locals {
  default_managed_scopes = [
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
  ]
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-explicit-consent"
}

data "authentik_flow" "default-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_property_mapping_provider_scope" "scopes" {
  for_each = local.apps

  managed_list = distinct(concat(
    local.default_managed_scopes,
    try(each.value.provider.extra_managed_scopes, [])
  ))
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}
