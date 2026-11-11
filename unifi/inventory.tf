# Read-only client inventory: data sources only, no resources declared here. just discover-unifi
# refreshes it from the controller without changing configuration; the managed resources declared
# elsewhere in this root are only applied by apply-unifi.
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
