resource "proxmox_virtual_environment_vm" "vm_cp_nodes" {
  count          = length(var.vm_cp_nodes)

  vm_id          = var.vm_cp_nodes[count.index].vm_id
  node_name      = var.vm_cp_nodes[count.index].target_node
  name           = var.vm_cp_nodes[count.index].node_name 
  description    = "Managed by OpenTofu"
  tags           = ["k8s", "cp_node", "opentofu", "talos", "staging"]
  on_boot        = true

  agent {
    enabled      = true
  }

  cpu {
    cores        = var.vm_cp_nodes[count.index].cpu_cores
    type         = var.vm_cp_nodes[count.index].cpu_type
    numa         = true
  }

  memory {
    dedicated    = var.vm_cp_nodes[count.index].memory 
    floating     = var.vm_cp_nodes[count.index].memory
  }

  scsi_hardware  = "virtio-scsi-single"

  disk {
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    datastore_id = var.pve_disk_storage
    size         = var.vm_cp_nodes[count.index].disk_size
    file_format  = "raw"
    interface    = "scsi0"
    iothread     = true
  }

  network_device {
    bridge       = "vmbr1"
    mac_address  = var.vm_cp_nodes[count.index].mac_address
    model        = "virtio"
  }
}

resource "proxmox_virtual_environment_vm" "vm_worker_nodes" {
  count          = length(var.vm_worker_nodes)

  vm_id          = var.vm_worker_nodes[count.index].vm_id
  node_name      = var.vm_worker_nodes[count.index].target_node
  name           = var.vm_worker_nodes[count.index].node_name 
  description    = "Managed by OpenTofu"
  tags           = ["k8s", "worker_node", "opentofu", "talos", "staging"]
  on_boot        = true

  agent {
    enabled      = true
  }

  cpu {
    cores        = var.vm_worker_nodes[count.index].cpu_cores
    type         = var.vm_worker_nodes[count.index].cpu_type
    numa         = true
  }

  memory {
    dedicated    = var.vm_worker_nodes[count.index].memory 
    floating     = var.vm_worker_nodes[count.index].memory
  }

  scsi_hardware  = "virtio-scsi-single"

  disk {
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    datastore_id = var.pve_disk_storage
    size         = var.vm_worker_nodes[count.index].disk_size
    file_format  = "raw"
    interface    = "scsi0"
    iothread     = true
  }

  network_device {
    bridge       = "vmbr1"
    mac_address  = var.vm_worker_nodes[count.index].mac_address
    model        = "virtio"
  }
}
