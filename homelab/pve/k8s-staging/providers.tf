terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.81.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.8.1"
    }
  }
}
