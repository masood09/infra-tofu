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
