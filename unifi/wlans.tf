resource "unifi_wlan" "managed" {
  for_each = var.unifi_wlans

  name              = each.value.name
  enabled           = each.value.enabled
  security          = each.value.security
  network_id        = each.value.network_id
  user_group_id     = each.value.user_group_id
  wlan_bands        = each.value.wlan_bands
  is_guest          = each.value.is_guest
  l2_isolation      = each.value.l2_isolation
  hide_ssid         = each.value.hide_ssid
  wpa               = try(each.value.wpa, null)
  wpa3              = try(each.value.wpa3, null)
  pmf_mode          = each.value.pmf_mode
  fast_roaming_enabled = each.value.fast_roaming_enabled
  passphrase_wo     = try(each.value.passphrase, null)

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      ap_group,
    ]
  }
}

import {
  for_each = var.unifi_wlans
  to       = unifi_wlan.managed[each.key]
  id       = each.value.id
}
