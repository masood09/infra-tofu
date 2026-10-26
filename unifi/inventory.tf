# Read-only discovery only. This root intentionally declares no UniFi resources.
# The first milestone must not change controller configuration.
data "unifi_client_list" "all" {
  site = var.unifi_site
}

locals {
  known_clients = [
    for client in data.unifi_client_list.all.clients : {
      mac              = client.mac
      name             = client.name
      hostname         = client.hostname
      fixed_ip         = client.fixed_ip
      local_dns_record = client.local_dns_record
      vendor           = client.oui
      blocked          = client.blocked
    }
  ]
}
