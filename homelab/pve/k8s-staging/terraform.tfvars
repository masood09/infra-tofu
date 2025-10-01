vm_cp_nodes = [
  {
    vm_id       = 7111
    target_node = "pve-02"
    node_name   = "homelab-staging-cp-01"
    cpu_cores   = 6
    cpu_type    = "x86-64-v2-AES"
    memory      = 4096
    disk_size   = "40"
    mac_address = "bc:24:11:7a:31:e4"
  }
]

vm_worker_nodes = [
  {
    vm_id       = 7112
    target_node = "pve-03"
    node_name   = "homelab-staging-worker-01"
    cpu_cores   = 6
    cpu_type    = "x86-64-v2-AES"
    memory      = 6144
    disk_size   = "40"
    mac_address = "bc:24:11:79:ed:49"
  }
]

talos_cluster_name = "homelab-staging"
talos_cluster_endpoint = "https://cp-01.staging.homelab.mantannest.com:6443"
talos_cluster_vip_ip = "10.0.20.110"

talos_node_data = {
  controlplanes = {
    "10.0.20.111" = {
      install_disk = "/dev/sda"
      hostname     = "homelab-staging-cp-01"
    }
  },
  workers = {
    "10.0.20.112" = {
      install_disk = "/dev/sda"
      hostname     = "homelab-staging-worker-01"
    }
  }
}

git_sync_path = "clusters/homelab-staging"
