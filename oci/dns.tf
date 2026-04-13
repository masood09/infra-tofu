# =============================================================================
# CloudFlare DNS Records for mantannest.com
#
# Records are organised into three sections:
#   1. Instance A records  – direct IP mappings for each OCI VM
#   2. Service CNAMEs      – user-facing subdomains pointing to instance records
#   3. Email (DKIM & SPF)  – OCI Email Delivery verification records
#
# All records use TTL=1 (CloudFlare automatic) and proxied=false (DNS-only).
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Instance A records & boot CNAMEs
# -----------------------------------------------------------------------------

# Authentik identity provider
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

# Matrix / Element chat, Nightscout, Karakeep
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

# Headscale mesh VPN coordinator
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

# Uptime Kuma monitoring
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

# -----------------------------------------------------------------------------
# 2. Service CNAMEs – user-facing subdomains
# -----------------------------------------------------------------------------

# Identity & authentication
resource "cloudflare_dns_record" "auth_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "auth.mantannest.com"
  content = cloudflare_dns_record.accesscontrolsystem_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

# Communication – Matrix/Element chat stack
resource "cloudflare_dns_record" "chat_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "chat.mantannest.com"
  content = cloudflare_dns_record.commrelay_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "mas_chat_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "mas.chat.mantannest.com"
  content = cloudflare_dns_record.commrelay_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "rtc_chat_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "rtc.chat.mantannest.com"
  content = cloudflare_dns_record.commrelay_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

# Health – Nightscout CGM dashboard
resource "cloudflare_dns_record" "nightscout_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "nightscout.mantannest.com"
  content = cloudflare_dns_record.commrelay_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

# Networking – Headscale VPN control plane
resource "cloudflare_dns_record" "headscale_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "headscale.mantannest.com"
  content = cloudflare_dns_record.meshcontrol_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

# Monitoring – Uptime Kuma
resource "cloudflare_dns_record" "uptime_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "uptime.mantannest.com"
  content = cloudflare_dns_record.watchfulsystem_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

# Bookmarks – Karakeep
resource "cloudflare_dns_record" "keep_mantannest_com" {
  zone_id = var.cloudflare_zone_id
  name    = "keep.mantannest.com"
  content = cloudflare_dns_record.commrelay_oci.name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

# -----------------------------------------------------------------------------
# 3. Email delivery – DKIM and SPF records for OCI Email Delivery
# -----------------------------------------------------------------------------

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
