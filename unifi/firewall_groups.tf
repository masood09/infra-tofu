resource "unifi_firewall_group" "managed" {
  for_each = var.unifi_firewall_groups

  name    = each.value.name
  type    = each.value.type
  members = each.value.members

  lifecycle {
    prevent_destroy = true
  }
}
