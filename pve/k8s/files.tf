resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = var.pve_download_file_datastore_id
  node_name               = var.pve_download_file_node_name

  file_name               = "talos-v${var.talos_version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/${var.talos_schematic_id}/v${var.talos_version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}
