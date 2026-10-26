resource "unifi_client" "fixed_ip" {
  for_each = var.unifi_fixed_ips

  mac              = each.value.mac
  fixed_ip         = each.value.fixed_ip
  local_dns_record = try(each.value.local_dns_record, null)
}

import {
  for_each = var.unifi_fixed_ips
  to       = unifi_client.fixed_ip[each.key]
  id       = each.value.mac
}
