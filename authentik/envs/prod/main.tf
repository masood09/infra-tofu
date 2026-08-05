module "auth" {
  source = "../../../modules/authentik"

  users_obj = local.users_obj
  apps_obj  = local.apps_obj
  ldap_obj  = local.ldap_obj
}
