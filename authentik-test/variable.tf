variable "authentik_token" {
  description = "Authentik Token"
  sensitive   = true
  type        = string
}

variable "authentik_grafana_client_secret" {
  sensitive   = true
  type        = string
}

variable "authentik_headscale_client_secret" {
  sensitive   = true
  type        = string
}

variable "authentik_immich_client_secret" {
  sensitive   = true
  type        = string
}

variable "authentik_karakeep_client_secret" {
  sensitive   = true
  type        = string
}
