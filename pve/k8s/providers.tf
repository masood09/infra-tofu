terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "1.6.3"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.79.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.8.0"
    }
  }
}
