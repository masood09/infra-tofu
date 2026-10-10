resource "unifi_network" "managed" {
  for_each = var.unifi_networks

  name        = each.value.name
  domain_name = each.value.domain_name
  dhcp_server = {
    boot = {
      enabled = false
    }
    conflict_checking = true
    dns = {
      enabled = each.value.dhcp.dns_enabled
      servers = try(each.value.dhcp.dns_servers, null)
    }
    enabled         = true
    gateway_enabled = false
    leasetime       = "24h0m0s"
    ntp = {
      enabled = false
    }
    start = each.value.dhcp.start
    stop  = each.value.dhcp.stop
    time_offset_enabled = false
    wins = {
      enabled = false
    }
  }
  enabled           = each.value.enabled
  gateway_type      = each.value.gateway_type
  internet_access   = each.value.internet_access
  multicast_dns     = each.value.multicast_dns
  network_isolation = each.value.network_isolation
  purpose           = each.value.purpose
  subnet            = each.value.subnet
  vlan              = try(each.value.vlan, null)

  lifecycle {
    prevent_destroy = true
  }
}

import {
  for_each = var.unifi_networks
  to       = unifi_network.managed[each.key]
  id       = each.value.id
}
