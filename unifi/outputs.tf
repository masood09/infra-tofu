output "inventory" {
  description = "Read-only UniFi client inventory for the configured site."
  sensitive   = true
  value = {
    site          = var.unifi_site
    known_clients = local.known_clients
  }
}

output "known_client_count" {
  description = "Number of known clients returned by UniFi."
  value       = length(local.known_clients)
}
