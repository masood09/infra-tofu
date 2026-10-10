resource "unifi_firewall_zone" "managed" {
  for_each = var.unifi_firewall_zones

  name = each.value.name
  network_ids = [
    for network_key in each.value.network_keys : try(unifi_network.managed[network_key].id, network_key)
  ]

  lifecycle {
    prevent_destroy = true
  }
}

import {
  for_each = var.unifi_firewall_zones
  to       = unifi_firewall_zone.managed[each.key]
  id       = each.value.id
}
