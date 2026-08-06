variable "users_obj" {
  type = map(object({
    username = string
    email    = string
    name     = string
    groups   = optional(list(string), [])
  }))
}

variable "apps_obj" {
  type = map(any) # easiest while iterating; you can strongly type later
}

variable "ldap_obj" {
  type    = any # { base_dn = string, access_groups = list(string) }
  default = null
}

variable "proxy_apps_obj" {
  type    = any # map of { name, slug, access = [{group, order}], provider = { name, external_host, internal_host } }
  default = {}
}
