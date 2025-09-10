variable "pve_conn_endpoint" {
  type    = string
  default = "https://pve-01.homelab.mantannest.com:8006/"
}

variable "pve_conn_api_token" {
  type = string
}

variable "pve_conn_insecure" {
  type    = bool
  default = false
}

variable "pve_download_file_datastore_id" {
  type    = string
  default = "pve-nas-storage"
}

variable "pve_disk_storage" {
  type    = string
  default = "pve-storage"
}

variable "pve_download_file_node_name" {
  type    = string
  default = "pve-01"
}

variable "vm_cp_nodes" {
  type = list(object({
    vm_id       = number
    target_node = string
    node_name   = string
    cpu_cores   = number
    cpu_type    = string
    memory      = number
    disk_size   = string
    mac_address = string
  }))
}

variable "vm_worker_nodes" {
  type = list(object({
    vm_id       = number
    target_node = string
    node_name   = string
    cpu_cores   = number
    cpu_type    = string
    memory      = number
    disk_size   = string
    mac_address = string
  }))
}

# see https://github.com/siderolabs/talos/releases
# see https://www.talos.dev/v1.10/introduction/support-matrix/
variable "talos_version" {
  type = string
  # renovate: datasource=github-releases depName=talos packageName=siderolabs/talos
  default = "1.10.6"
  validation {
    condition     = can(regex("^\\d+(\\.\\d+)+", var.talos_version))
    error_message = "Must be a version number."
  }
}

# see https://github.com/siderolabs/kubelet/pkgs/container/kubelet
# see https://www.talos.dev/v1.10/introduction/support-matrix/
variable "kubernetes_version" {
  type = string
  # renovate: datasource=github-releases depName=kubelet packageName=siderolabs/kubelet
  default = "1.34.1"
  validation {
    condition     = can(regex("^\\d+(\\.\\d+)+", var.kubernetes_version))
    error_message = "Must be a version number."
  }
}

variable "talos_schematic_id" {
  type    = string
  default = "dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586"
}

variable "talos_cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "talos_cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
}

variable "talos_cluster_vip_ip" {
  description = "The VIP for the cluster"
  type        = string
}

variable "talos_node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
    workers = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
  })
}

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
  default = "v2.6.4"
}

variable "flux_registry" {
  type    = string
  default = "ghcr.io/fluxcd"
}
