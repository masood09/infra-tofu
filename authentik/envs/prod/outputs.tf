output "jellyfin_ldap_bind_password" {
  value     = module.auth.jellyfin_ldap_bind_password
  sensitive = true
}
