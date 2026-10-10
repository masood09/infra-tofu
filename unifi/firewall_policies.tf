resource "unifi_firewall_policy" "managed" {
  for_each = var.unifi_firewall_policies

  name        = each.value.name
  description = try(each.value.description, null)
  action      = each.value.action
  source = merge(
    each.value.source,
    { zone_id = unifi_firewall_zone.managed[each.value.source.zone_key].id },
    try(each.value.source.ip_group_key, null) != null ? { ip_group_id = unifi_firewall_group.managed[each.value.source.ip_group_key].id } : {},
    try(each.value.source.port_group_key, null) != null ? { port_group_id = unifi_firewall_group.managed[each.value.source.port_group_key].id } : {},
    try(each.value.source.network_keys, null) != null ? { network_ids = [for network_key in each.value.source.network_keys : try(unifi_network.managed[network_key].id, network_key)] } : {}
  )
  destination = merge(
    each.value.destination,
    { zone_id = unifi_firewall_zone.managed[each.value.destination.zone_key].id },
    try(each.value.destination.ip_group_key, null) != null ? { ip_group_id = unifi_firewall_group.managed[each.value.destination.ip_group_key].id } : {},
    try(each.value.destination.port_group_key, null) != null ? { port_group_id = unifi_firewall_group.managed[each.value.destination.port_group_key].id } : {},
    try(each.value.destination.network_keys, null) != null ? { network_ids = [for network_key in each.value.destination.network_keys : try(unifi_network.managed[network_key].id, network_key)] } : {}
  )
  connection_state_type   = each.value.connection_state_type
  connection_states       = each.value.connection_states
  create_allow_respond    = each.value.create_allow_respond
  enabled                 = each.value.enabled
  ip_version              = each.value.ip_version
  logging                 = each.value.logging
  match_opposite_protocol = each.value.match_opposite_protocol
  protocol                = each.value.protocol

  lifecycle {
    prevent_destroy = true
  }
}

import {
  for_each = var.unifi_firewall_policies
  to       = unifi_firewall_policy.managed[each.key]
  id       = each.value.id
}
