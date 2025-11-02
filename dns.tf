resource "cloudflare_dns_record" "auth-server_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "auth-server.oci.mantannest.com"
  content = oci_core_instance.oci-auth-server_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "vpn-server_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "vpn-server.oci.mantannest.com"
  content = oci_core_instance.oci-vpn-server_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "peer-server_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "peer-server.oci.mantannest.com"
  content = oci_core_instance.oci-peer-server_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "auth_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "auth.mantannest.com"
  content = cloudflare_dns_record.auth-server_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "headscale_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "headscale.mantannest.com"
  content = cloudflare_dns_record.vpn-server_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "oci_email_dkim" {
  zone_id = var.cloudflare_zone_id
  name    = oci_email_dkim.mantannest_com.dns_subdomain_name
  content = oci_email_dkim.mantannest_com.cname_record_value
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "oci_spf" {
  zone_id = var.cloudflare_zone_id
  name    = "mantannest.com"
  content = "v=spf1 include:rp.oracleemaildelivery.com ~all"
  type    = "TXT"
  ttl     = 1
}
