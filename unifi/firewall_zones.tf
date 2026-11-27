resource "unifi_firewall_zone" "managed" {
  for_each = var.unifi_firewall_zones

  name = each.value.name
  # The controller returns zone membership sorted by network ID, so sort here too
  # to keep plans drift-free regardless of the order in network_keys.
  network_ids = sort([
    for network_key in each.value.network_keys : try(unifi_network.managed[network_key].id, network_key)
  ])

  lifecycle {
    prevent_destroy = true
  }
}
