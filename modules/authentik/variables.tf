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
