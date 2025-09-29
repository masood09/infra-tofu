terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.84.1"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.9.0"
    }
  }
}
