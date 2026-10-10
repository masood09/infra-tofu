variable "unifi_api_url" {
  description = "Base URL of the local UniFi Network API, without an /api suffix."
  type        = string
  sensitive   = true
}

variable "unifi_username" {
  description = "Dedicated UniFi local-admin username used by OpenTofu."
  type        = string
  sensitive   = true
}

variable "unifi_password" {
  description = "Password for the dedicated UniFi local-admin account."
  type        = string
  sensitive   = true
}

variable "unifi_site" {
  description = "UniFi site to inspect."
  type        = string
  default     = "default"
}

variable "unifi_allow_insecure" {
  description = "Whether to skip TLS certificate verification for a self-signed local certificate."
  type        = bool
  default     = false
}

variable "unifi_networks" {
  description = "UniFi network definitions loaded from the encrypted network tfvars file."
  type = map(object({
    id                = string
    name              = string
    domain_name       = string
    enabled           = bool
    gateway_type      = string
    internet_access   = bool
    multicast_dns     = bool
    network_isolation = bool
    purpose           = string
    subnet            = string
    vlan              = optional(number)
    dhcp = object({
      start       = string
      stop        = string
      dns_enabled = bool
      dns_servers = optional(list(string))
    })
  }))
}
