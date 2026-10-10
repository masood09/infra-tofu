resource "unifi_client" "fixed_ip" {
  for_each = var.unifi_fixed_ips

  mac      = each.value.mac
  fixed_ip = each.value.fixed_ip

  lifecycle {
    prevent_destroy = true
  }
}

import {
  for_each = var.unifi_fixed_ips
  to       = unifi_client.fixed_ip[each.key]
  id       = each.value.mac
}
