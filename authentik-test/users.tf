resource "authentik_user" "akadmin" {
  email    = "admin@ahmedmasood.com"
  username = "akadmin"
  name     = "Admin User"
}

resource "authentik_user" "masood" {
  email    = "me@ahmedmasood.com"
  username = "masood"
  name     = "Masood Ahmed"
}

resource "authentik_group" "authentik_admins" {
  name         = "authentik Admins"
  users        = [authentik_user.akadmin.id]
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
  users        = [authentik_user.masood.id]
}

resource "authentik_group" "kids" {
  name         = "kids"
  users        = []
}

resource "authentik_group" "parents" {
  name         = "parents"
  users        = [authentik_user.masood.id]
}
