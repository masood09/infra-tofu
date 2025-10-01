variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
  default     = "masood09"
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
  default     = "infra-flux"
}

variable "git_sync_path" {
  description = "The path within repository pointing to our cluster"
  type        = string
}

variable "flux_version" {
  type = string

  # renovate: datasource=github-releases depName=flux2 packageName=fluxcd/flux2
  default = "v2.7.0"
}

variable "flux_registry" {
  type    = string
  default = "ghcr.io/fluxcd"
}
