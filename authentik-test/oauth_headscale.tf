resource "authentik_provider_oauth2" "headscale" {
  name               = "Provider for Headscale"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  client_id          = "headscale"
  client_secret      = var.authentik_headscale_client_secret

  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://headscale.test.mantannest.com/oidc/callback",
    }
  ]

  invalidation_flow = data.authentik_flow.default-invalidation-flow.id
  property_mappings = data.authentik_property_mapping_provider_scope.default-scope.ids
  access_token_validity = "minutes=5"
  refresh_token_threshold = "hours=1"
  signing_key = data.authentik_certificate_key_pair.generated.id
}

resource "authentik_application" "headscale" {
  name              = "Headscale"
  slug              = "headscale"
  protocol_provider = authentik_provider_oauth2.headscale.id
}
