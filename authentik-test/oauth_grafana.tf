resource "authentik_provider_oauth2" "grafana" {
  name               = "Provider for Grafana"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  client_id          = "grafana"
  client_secret      = var.authentik_grafana_client_secret

  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://grafana.test.mantannest.com/login/generic_oauth",
    }
  ]

  logout_method     = "frontchannel"
  logout_uri        = "https://grafana.test.mantannest.com/logout"
  invalidation_flow = data.authentik_flow.default-invalidation-flow.id
  property_mappings = data.authentik_property_mapping_provider_scope.default-scope.ids
  access_token_validity = "minutes=5"
  refresh_token_threshold = "hours=1"
  signing_key = data.authentik_certificate_key_pair.generated.id
}

resource "authentik_application" "grafana" {
  name              = "Grafana"
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id
}

resource "authentik_policy_binding" "grafana-homelab-admin-access" {
  target = authentik_application.grafana.uuid
  group  = authentik_group.groups["homelab-admins"].id
  order  = 1
}

resource "authentik_policy_binding" "grafana-parents-access" {
  target = authentik_application.grafana.uuid
  group  = authentik_group.groups["parents"].id
  order  = 2
}
