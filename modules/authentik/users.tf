locals {
  # Decrypt + parse (this removes sensitivity for evaluation purposes)
  users_obj = var.users_obj

  # Non-sensitive IDs (u1/u2/...)
  user_ids = toset(keys(local.users_obj))

  # All groups referenced by any user
  referenced_group_keys = toset(flatten([
    for _, u in local.users_obj : try(u.groups, [])
  ]))

  # Build: group_key => [user_key, user_key, ...]
  group_members_user_keys = {
    for g in local.referenced_group_keys :
    g => [
      for user_key, u in local.users_obj : user_key
      if contains(try(u.groups, []), g)
    ]
  }
}

resource "authentik_user" "users" {
  for_each = local.user_ids

  email    = local.users_obj[each.key].email
  username = local.users_obj[each.key].username
  name     = local.users_obj[each.key].name
}

resource "authentik_group" "groups" {
  for_each = local.referenced_group_keys

  name = each.key

  users = [
    for user_key in local.group_members_user_keys[each.key] :
    authentik_user.users[user_key].id
  ]

  # Only set superuser for the admin group
  is_superuser = each.key == "authentik-admins"
}
