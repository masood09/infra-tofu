locals {
  # Decrypt + parse (this removes sensitivity for evaluation purposes)
  users_obj = jsondecode(nonsensitive(data.sops_file.users.raw)).users

  # Non-sensitive IDs (u1/u2/...)
  user_ids = toset(keys(local.users_obj))
}

resource "authentik_user" "users" {
  for_each = local.user_ids

  email    = local.users_obj[each.key].email
  username = local.users_obj[each.key].username
  name     = local.users_obj[each.key].name
}

resource "authentik_group" "authentik_admins" {
  name         = "authentik Admins"
  users        = [authentik_user.users["u1"].id]
  is_superuser = true
}

resource "authentik_group" "guests" {
  name         = "guests"
  users        = []
}

resource "authentik_group" "guests-trusted" {
  name         = "guests-trusted"
  users        = []
}

resource "authentik_group" "homelab-admins" {
  name         = "homelab-admins"
  users        = [authentik_user.users["u2"].id]
}

resource "authentik_group" "kids" {
  name         = "kids"
  users        = [
    authentik_user.users["u3"].id,
    authentik_user.users["u5"].id
  ]
}

resource "authentik_group" "parents" {
  name         = "parents"
  users        = [
    authentik_user.users["u2"].id,
    authentik_user.users["u4"].id
  ]
}
