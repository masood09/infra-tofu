resource "unifi_dns_record" "managed" {
  for_each = var.unifi_dns_records

  name        = each.value.name
  enabled     = each.value.enabled
  record_type = each.value.record_type
  value       = each.value.value
  port        = try(each.value.port, null)
  priority    = try(each.value.priority, null)
  ttl         = try(each.value.ttl, null)
  weight      = try(each.value.weight, null)

  lifecycle {
    ignore_changes = [
      port,
      priority,
      ttl,
      weight,
    ]
  }
}
