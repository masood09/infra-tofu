resource "unifi_dns_record" "managed" {
  for_each = var.unifi_dns_records

  name        = each.value.name
  enabled     = each.value.enabled
  record_type = each.value.record_type
  value       = each.value.value
  port        = each.value.port
  priority    = each.value.priority
  ttl         = each.value.ttl
  weight      = each.value.weight

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      port,
      priority,
      ttl,
      weight,
    ]
  }
}

import {
  for_each = var.unifi_dns_records
  to       = unifi_dns_record.managed[each.key]
  id       = each.value.id
}
