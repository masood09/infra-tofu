locals {
  # Only networks that already have a controller ID (imported or created) are readable
  # from the controller; newly declared networks appear after the next regen-import-ids.
  unifi_network_names = toset([
    for key, network in var.unifi_networks : network.name
    if try(var.unifi_import_ids.networks[key], null) != null
  ])
}

data "unifi_network" "all" {
  for_each = local.unifi_network_names

  name = each.value
  site = var.unifi_site
}

locals {
  network_inventory = [
    for name in sort(keys(data.unifi_network.all)) : {
      id                = data.unifi_network.all[name].id
      name              = data.unifi_network.all[name].name
      vlan              = data.unifi_network.all[name].vlan
      subnet            = data.unifi_network.all[name].subnet
      purpose           = data.unifi_network.all[name].purpose
      enabled           = data.unifi_network.all[name].enabled
      gateway_type      = data.unifi_network.all[name].gateway_type
      domain_name       = data.unifi_network.all[name].domain_name
      network_group     = data.unifi_network.all[name].network_group
      network_isolation = data.unifi_network.all[name].network_isolation
      multicast_dns     = data.unifi_network.all[name].multicast_dns
      internet_access   = data.unifi_network.all[name].internet_access
    }
  ]
}
