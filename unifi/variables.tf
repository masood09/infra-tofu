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

variable "unifi_wlans" {
  description = "UniFi WLAN definitions loaded from the encrypted WLAN tfvars file."
  type = map(object({
    id                  = string
    name                = string
    enabled             = bool
    security            = string
    network_id          = string
    user_group_id       = string
    wlan_bands          = set(string)
    is_guest            = bool
    l2_isolation        = bool
    hide_ssid           = bool
    wpa                 = optional(object({
      mode = optional(string)
      enc  = optional(string)
    }))
    wpa3                = optional(object({
      support       = optional(bool)
      transition    = optional(bool)
      fast_roaming  = optional(bool)
      enhanced_192  = optional(bool)
    }))
    pmf_mode            = string
    fast_roaming_enabled = bool
    passphrase          = optional(string)
  }))
}

variable "unifi_dns_records" {
  description = "UniFi local DNS records loaded from the encrypted DNS tfvars file."
  type = map(object({
    id          = string
    name        = string
    enabled     = bool
    record_type = string
    value       = string
    port        = number
    priority    = number
    ttl         = string
    weight      = number
  }))
}
