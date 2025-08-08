provider "proxmox" {
  endpoint  = var.pve_conn_endpoint
  api_token = var.pve_conn_api_token
  insecure  = var.pve_conn_insecure

  ssh {
    agent       = false
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}
