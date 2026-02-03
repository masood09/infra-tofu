locals {
  apps = var.apps_obj

  access_bindings = merge([
    for app_key, app in local.apps : {
      for rule in try(app.access, []) :
      "${app_key}:${rule.group}" => {
        app_key = app_key
        group   = rule.group
        order   = rule.order
      }
    }
  ]...)
}

resource "authentik_provider_oauth2" "apps" {
  for_each = local.apps

  name               = each.value.provider.name
  authorization_flow = data.authentik_flow.default-authorization-flow.id

  client_id     = each.value.provider.client_id
  client_secret = each.value.provider.client_secret

  allowed_redirect_uris = each.value.provider.allowed_redirect_uris

  invalidation_flow       = data.authentik_flow.default-invalidation-flow.id
  property_mappings       = data.authentik_property_mapping_provider_scope.default-scope.ids
  access_token_validity   = "minutes=5"
  refresh_token_threshold = "hours=1"
  signing_key             = data.authentik_certificate_key_pair.generated.id

  # Optional logout settings
  logout_method = try(each.value.provider.logout_method, null)
  logout_uri    = try(each.value.provider.logout_uri, null)
}

resource "authentik_application" "apps" {
  for_each = local.apps

  name              = each.value.name
  slug              = each.value.slug
  protocol_provider = authentik_provider_oauth2.apps[each.key].id

  meta_launch_url = try(each.value.meta_launch_url, null)
}

resource "authentik_policy_binding" "access" {
  for_each = local.access_bindings

  target = authentik_application.apps[each.value.app_key].uuid
  group  = authentik_group.groups[each.value.group].id
  order  = each.value.order
}
