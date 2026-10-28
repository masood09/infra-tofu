import {
  for_each = var.unifi_networks
  to       = unifi_network.managed[each.key]
  id       = var.unifi_import_ids.networks[each.key]
}

import {
  for_each = var.unifi_wlans
  to       = unifi_wlan.managed[each.key]
  id       = var.unifi_import_ids.wlans[each.key]
}

import {
  for_each = var.unifi_dns_records
  to       = unifi_dns_record.managed[each.key]
  id       = var.unifi_import_ids.dns_records[each.key]
}

import {
  for_each = var.unifi_firewall_zones
  to       = unifi_firewall_zone.managed[each.key]
  id       = var.unifi_import_ids.firewall_zones[each.key]
}

import {
  for_each = {
    for key, group in var.unifi_firewall_groups : key => group
    if try(var.unifi_import_ids.firewall_groups[key], null) != null
  }
  to       = unifi_firewall_group.managed[each.key]
  id       = var.unifi_import_ids.firewall_groups[each.key]
}

import {
  for_each = {
    for key, policy in var.unifi_firewall_policies : key => policy
    if try(var.unifi_import_ids.firewall_policies[key], null) != null
  }
  to       = unifi_firewall_policy.managed[each.key]
  id       = var.unifi_import_ids.firewall_policies[each.key]
}
