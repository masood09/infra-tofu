resource "authentik_provider_oauth2" "karakeep" {
  name               = "Provider for Karakeep"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  client_id          = "karakeep"
  client_secret      = var.authentik_karakeep_client_secret

  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://keep.test.mantannest.com/api/auth/callback/custom",
    }
  ]

  invalidation_flow = data.authentik_flow.default-invalidation-flow.id
  property_mappings = data.authentik_property_mapping_provider_scope.default-scope.ids
  access_token_validity = "minutes=5"
  refresh_token_threshold = "hours=1"
  signing_key = data.authentik_certificate_key_pair.generated.id
}

resource "authentik_application" "karakeep" {
  name              = "Karakeep"
  slug              = "karakeep"
  protocol_provider = authentik_provider_oauth2.karakeep.id
}

resource "authentik_policy_binding" "karakeep-parents-access" {
  target = authentik_application.karakeep.uuid
  group  = authentik_group.parents.id
  order  = 1
}

resource "authentik_policy_binding" "karakeep-kids-access" {
  target = authentik_application.karakeep.uuid
  group  = authentik_group.kids.id
  order  = 2
}
