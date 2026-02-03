resource "authentik_provider_oauth2" "immich" {
  name               = "Provider for Immich"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  client_id          = "immich"
  client_secret      = var.authentik_immich_client_secret

  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "app.immich:///oauth-callback",
    },
    {
      matching_mode = "strict",
      url           = "https://photos.test.mantannest.com/auth/login",
    },
    {
      matching_mode = "strict",
      url           = "https://photos.mantannest.com/user-settings",
    }
  ]

  invalidation_flow = data.authentik_flow.default-invalidation-flow.id
  property_mappings = data.authentik_property_mapping_provider_scope.default-scope.ids
  access_token_validity = "minutes=5"
  refresh_token_threshold = "hours=1"
  signing_key = data.authentik_certificate_key_pair.generated.id
}

resource "authentik_application" "immich" {
  name              = "Immich (Photos)"
  slug              = "immich"
  protocol_provider = authentik_provider_oauth2.immich.id
  meta_launch_url   = "https://photos.test.mantannest.com"
}

resource "authentik_policy_binding" "immich-parents-access" {
  target = authentik_application.immich.uuid
  group  = authentik_group.parents.id
  order  = 1
}

resource "authentik_policy_binding" "immich-kids-access" {
  target = authentik_application.immich.uuid
  group  = authentik_group.kids.id
  order  = 2
}
