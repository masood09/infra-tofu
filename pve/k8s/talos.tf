resource "talos_machine_secrets" "machine_secrets" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = var.talos_cluster_endpoint
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = "v${var.talos_version}"
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = var.talos_cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = "v${var.talos_version}"
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [for k, v in var.talos_node_data.controlplanes : k]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on                  = [
    proxmox_virtual_environment_vm.vm_cp_nodes
  ]

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  for_each                    = var.talos_node_data.controlplanes
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/files/machine-disk-network.yaml.tmpl", {
      hostname     = each.value.hostname == null ? format("%s-cp-%s", var.talos_cluster_name, index(keys(var.talos_node_data.controlplanes), each.key)) : each.value.hostname
      install_disk = each.value.install_disk
    }),
    file("${path.module}/files/machine-ntp.yaml"),
    file("${path.module}/files/machine-kubePrism.yaml"),
    file("${path.module}/files/machine-hostDNS.yaml"),
    templatefile("${path.module}/files/machine-VIP.yaml.tmpl", {
      vip_ip = var.talos_cluster_vip_ip
    }),
    file("${path.module}/files/cluster-scheduling.yaml"),
    file("${path.module}/files/cluster-controllerManager.yaml"),
    file("${path.module}/files/cluster-metrics-bind.yaml"),
    file("${path.module}/files/cluster-etcd-metrics-url.yaml"),
    file("${path.module}/files/cluster-discovery.yaml"),
    file("${path.module}/files/cluster-network-proxy.yaml"),
    yamlencode({
      cluster = {
        inlineManifests = [
          {
            name = "cilium",
            contents = data.helm_template.cilium.manifest
          }
        ]
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on                  = [
    proxmox_virtual_environment_vm.vm_worker_nodes
  ]

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each                    = var.talos_node_data.workers
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/files/machine-disk-network.yaml.tmpl", {
      hostname     = each.value.hostname == null ? format("%s-worker-%s", var.talos_cluster_name, index(keys(var.talos_node_data.workers), each.key)) : each.value.hostname
      install_disk = each.value.install_disk
    }),
    file("${path.module}/files/machine-ntp.yaml"),
    file("${path.module}/files/machine-kubePrism.yaml"),
    file("${path.module}/files/machine-hostDNS.yaml")
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = [for k, v in var.talos_node_data.controlplanes : k][0]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [
    talos_machine_bootstrap.bootstrap
  ]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = [for k, v in var.talos_node_data.controlplanes : k][0]
}

output "talosconfig" {
  value = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
