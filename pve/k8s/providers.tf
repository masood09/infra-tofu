terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "1.6.4"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.80.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.8.0"
    }
  }
}
