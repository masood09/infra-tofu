resource "cloudflare_dns_record" "accesscontrolsystem_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "accesscontrolsystem.oci.mantannest.com"
  content = oci_core_instance.accesscontrolsystem_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "boot_accesscontrolsystem_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "boot.accesscontrolsystem.oci.mantannest.com"
  content = cloudflare_dns_record.accesscontrolsystem_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "commrelay_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "commrelay.oci.mantannest.com"
  content = oci_core_instance.commrelay_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "boot_commrelay_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "boot.commrelay.oci.mantannest.com"
  content = cloudflare_dns_record.commrelay_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "meshcontrol_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "meshcontrol.oci.mantannest.com"
  content = oci_core_instance.meshcontrol_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "boot_meshcontrol_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "boot.meshcontrol.oci.mantannest.com"
  content = cloudflare_dns_record.meshcontrol_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "watchfulsystem_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "watchfulsystem.oci.mantannest.com"
  content = oci_core_instance.watchfulsystem_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "boot_watchfulsystem_oci" {
  zone_id = var.cloudflare_zone_id
  name    = "boot.watchfulsystem.oci.mantannest.com"
  content = cloudflare_dns_record.watchfulsystem_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "mantannest.com"
  content = oci_core_instance.commrelay_instance.public_ip
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "www_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "www.mantannest.com"
  content = cloudflare_dns_record.mantannest_com.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "auth_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "auth.mantannest.com"
  content = cloudflare_dns_record.accesscontrolsystem_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "headscale_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "headscale.mantannest.com"
  content = cloudflare_dns_record.meshcontrol_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "matrix_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "matrix.mantannest.com"
  content = cloudflare_dns_record.mantannest_com.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "uptime_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "uptime.mantannest.com"
  content = cloudflare_dns_record.watchfulsystem_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "oci_email_dkim" {
  zone_id = var.cloudflare_zone_id
  name    = "${oci_email_dkim.mantannest_com.name}._domainkey"
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
