set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# -----------------------------
# Config
# -----------------------------
SOPS := "sops"
INPUT_TYPE := "binary"
OUTPUT_TYPE := "binary"

OCI_DIR := "oci"
AK_PROD_DIR := "authentik/envs/prod"
AK_TEST_DIR := "authentik/envs/test"
UNIFI_DIR := "unifi"

OCI_PLAIN := OCI_DIR + "/sensitive.auto.tfvars"
OCI_ENC   := OCI_DIR + "/sensitive.auto.tfvars.enc"

AK_PROD_PLAIN := AK_PROD_DIR + "/sensitive.auto.tfvars"
AK_PROD_ENC   := AK_PROD_DIR + "/sensitive.auto.tfvars.enc"
AK_TEST_PLAIN := AK_TEST_DIR + "/sensitive.auto.tfvars"
AK_TEST_ENC   := AK_TEST_DIR + "/sensitive.auto.tfvars.enc"
UNIFI_PLAIN   := UNIFI_DIR + "/sensitive.auto.tfvars"
UNIFI_ENC     := UNIFI_DIR + "/sensitive.auto.tfvars.enc"
UNIFI_NETWORKS_PLAIN := UNIFI_DIR + "/networks.auto.tfvars.json"
UNIFI_NETWORKS_ENC   := UNIFI_DIR + "/networks.auto.tfvars.json.enc"
UNIFI_WLANS_PLAIN := UNIFI_DIR + "/wlans.auto.tfvars.json"
UNIFI_WLANS_ENC   := UNIFI_DIR + "/wlans.auto.tfvars.json.enc"
UNIFI_DNS_PLAIN := UNIFI_DIR + "/dns.auto.tfvars.json"
UNIFI_DNS_ENC   := UNIFI_DIR + "/dns.auto.tfvars.json.enc"
UNIFI_FIXED_IPS_PLAIN := UNIFI_DIR + "/fixed_ips.auto.tfvars.json"
UNIFI_FIXED_IPS_ENC   := UNIFI_DIR + "/fixed_ips.auto.tfvars.json.enc"
UNIFI_FIREWALL_PLAIN := UNIFI_DIR + "/firewall.auto.tfvars.json"
UNIFI_FIREWALL_ENC   := UNIFI_DIR + "/firewall.auto.tfvars.json.enc"

# -----------------------------
# Helpers
# -----------------------------
_check-tools:
	@command -v {{SOPS}} >/dev/null || { echo "❌ sops not found in PATH"; exit 1; }

_check-dirs:
	@mkdir -p {{OCI_DIR}} {{AK_PROD_DIR}} {{AK_TEST_DIR}} {{UNIFI_DIR}}

# -----------------------------
# Encrypt
# -----------------------------
encrypt-oci: _check-tools _check-dirs
	@echo "🔐 Encrypting {{OCI_PLAIN}} -> {{OCI_ENC}} (binary)"
	{{SOPS}} -e --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} --output {{OCI_ENC}} {{OCI_PLAIN}}
	@echo "✅ Wrote {{OCI_ENC}}"

encrypt-ak-prod: _check-tools _check-dirs
	@echo "🔐 Encrypting {{AK_PROD_PLAIN}} -> {{AK_PROD_ENC}} (binary)"
	{{SOPS}} -e --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} --output {{AK_PROD_ENC}} {{AK_PROD_PLAIN}}
	@echo "✅ Wrote {{AK_PROD_ENC}}"

encrypt-ak-test: _check-tools _check-dirs
	@echo "🔐 Encrypting {{AK_TEST_PLAIN}} -> {{AK_TEST_ENC}} (binary)"
	{{SOPS}} -e --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} --output {{AK_TEST_ENC}} {{AK_TEST_PLAIN}}
	@echo "✅ Wrote {{AK_TEST_ENC}}"

encrypt-unifi: _check-tools _check-dirs
	@echo "🔐 Encrypting {{UNIFI_PLAIN}} -> {{UNIFI_ENC}} (binary)"
	{{SOPS}} -e --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} --output {{UNIFI_ENC}} {{UNIFI_PLAIN}}
	@echo "✅ Wrote {{UNIFI_ENC}}"

encrypt-unifi-wlans: _check-tools _check-dirs
	@echo "🔐 Encrypting {{UNIFI_WLANS_PLAIN}} -> {{UNIFI_WLANS_ENC}} (JSON)"
	{{SOPS}} -e --output {{UNIFI_WLANS_ENC}} {{UNIFI_WLANS_PLAIN}}
	@echo "✅ Wrote {{UNIFI_WLANS_ENC}}"

encrypt-unifi-dns: _check-tools _check-dirs
	@echo "🔐 Encrypting {{UNIFI_DNS_PLAIN}} -> {{UNIFI_DNS_ENC}} (JSON)"
	{{SOPS}} -e --output {{UNIFI_DNS_ENC}} {{UNIFI_DNS_PLAIN}}
	@echo "✅ Wrote {{UNIFI_DNS_ENC}}"

encrypt-unifi-fixed-ips: _check-tools _check-dirs
	@echo "🔐 Encrypting {{UNIFI_FIXED_IPS_PLAIN}} -> {{UNIFI_FIXED_IPS_ENC}} (JSON)"
	{{SOPS}} -e --output {{UNIFI_FIXED_IPS_ENC}} {{UNIFI_FIXED_IPS_PLAIN}}
	@echo "✅ Wrote {{UNIFI_FIXED_IPS_ENC}}"

encrypt-unifi-firewall: _check-tools _check-dirs
	@echo "🔐 Encrypting {{UNIFI_FIREWALL_PLAIN}} -> {{UNIFI_FIREWALL_ENC}} (JSON)"
	{{SOPS}} -e --output {{UNIFI_FIREWALL_ENC}} {{UNIFI_FIREWALL_PLAIN}}
	@echo "✅ Wrote {{UNIFI_FIREWALL_ENC}}"

encrypt: encrypt-oci encrypt-ak-prod encrypt-ak-test
	@echo "✅ Encrypted all"

# -----------------------------
# Decrypt
# -----------------------------
decrypt-oci: _check-tools _check-dirs
	@echo "🔓 Decrypting {{OCI_ENC}} -> {{OCI_PLAIN}} (binary)"
	{{SOPS}} -d --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} {{OCI_ENC}} > {{OCI_PLAIN}}
	@echo "✅ Wrote {{OCI_PLAIN}}"
	@echo "⚠️  Do NOT commit {{OCI_PLAIN}}"

decrypt-ak-prod: _check-tools _check-dirs
	@echo "🔓 Decrypting {{AK_PROD_ENC}} -> {{AK_PROD_PLAIN}} (binary)"
	{{SOPS}} -d --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} {{AK_PROD_ENC}} > {{AK_PROD_PLAIN}}
	@echo "✅ Wrote {{AK_PROD_PLAIN}}"
	@echo "⚠️  Do NOT commit {{AK_PROD_PLAIN}}"

decrypt-ak-test: _check-tools _check-dirs
	@echo "🔓 Decrypting {{AK_TEST_ENC}} -> {{AK_TEST_PLAIN}} (binary)"
	{{SOPS}} -d --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} {{AK_TEST_ENC}} > {{AK_TEST_PLAIN}}
	@echo "✅ Wrote {{AK_TEST_PLAIN}}"
	@echo "⚠️  Do NOT commit {{AK_TEST_PLAIN}}"

decrypt-unifi: _check-tools _check-dirs
	@echo "🔓 Decrypting {{UNIFI_ENC}} -> {{UNIFI_PLAIN}} (binary)"
	{{SOPS}} -d --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} {{UNIFI_ENC}} > {{UNIFI_PLAIN}}
	@echo "✅ Wrote {{UNIFI_PLAIN}}"
	@echo "⚠️  Do NOT commit {{UNIFI_PLAIN}}"

decrypt-unifi-networks: _check-tools _check-dirs
	@echo "🔓 Decrypting {{UNIFI_NETWORKS_ENC}} -> {{UNIFI_NETWORKS_PLAIN}} (JSON)"
	{{SOPS}} -d --output-type json {{UNIFI_NETWORKS_ENC}} > {{UNIFI_NETWORKS_PLAIN}}
	@echo "✅ Wrote {{UNIFI_NETWORKS_PLAIN}}"
	@echo "⚠️  Do NOT commit {{UNIFI_NETWORKS_PLAIN}}"

decrypt-unifi-wlans: _check-tools _check-dirs
	@echo "🔓 Decrypting {{UNIFI_WLANS_ENC}} -> {{UNIFI_WLANS_PLAIN}} (JSON)"
	{{SOPS}} -d --output-type json {{UNIFI_WLANS_ENC}} > {{UNIFI_WLANS_PLAIN}}
	@echo "✅ Wrote {{UNIFI_WLANS_PLAIN}}"
	@echo "⚠️  Do NOT commit {{UNIFI_WLANS_PLAIN}}"

decrypt-unifi-dns: _check-tools _check-dirs
	@echo "🔓 Decrypting {{UNIFI_DNS_ENC}} -> {{UNIFI_DNS_PLAIN}} (JSON)"
	{{SOPS}} -d --output-type json {{UNIFI_DNS_ENC}} > {{UNIFI_DNS_PLAIN}}
	@echo "✅ Wrote {{UNIFI_DNS_PLAIN}}"
	@echo "⚠️  Do NOT commit {{UNIFI_DNS_PLAIN}}"

decrypt-unifi-fixed-ips: _check-tools _check-dirs
	@echo "🔓 Decrypting {{UNIFI_FIXED_IPS_ENC}} -> {{UNIFI_FIXED_IPS_PLAIN}} (JSON)"
	{{SOPS}} -d --output-type json {{UNIFI_FIXED_IPS_ENC}} > {{UNIFI_FIXED_IPS_PLAIN}}
	@echo "✅ Wrote {{UNIFI_FIXED_IPS_PLAIN}}"
	@echo "⚠️  Do NOT commit {{UNIFI_FIXED_IPS_PLAIN}}"

decrypt-unifi-firewall: _check-tools _check-dirs
	@echo "🔓 Decrypting {{UNIFI_FIREWALL_ENC}} -> {{UNIFI_FIREWALL_PLAIN}} (JSON)"
	{{SOPS}} -d --output-type json {{UNIFI_FIREWALL_ENC}} > {{UNIFI_FIREWALL_PLAIN}}
	@echo "✅ Wrote {{UNIFI_FIREWALL_PLAIN}}"
	@echo "⚠️  Do NOT commit {{UNIFI_FIREWALL_PLAIN}}"

decrypt: decrypt-oci decrypt-ak-prod decrypt-ak-test
	@echo "✅ Decrypted all"

# -----------------------------
# Clean plaintext files
# -----------------------------
clean-oci:
	@echo "🧹 Removing {{OCI_PLAIN}}"
	rm -f {{OCI_PLAIN}}
	@echo "✅ Clean"

clean-ak-prod:
	@echo "🧹 Removing {{AK_PROD_PLAIN}}"
	rm -f {{AK_PROD_PLAIN}}
	@echo "✅ Clean"

clean-ak-test:
	@echo "🧹 Removing {{AK_TEST_PLAIN}}"
	rm -f {{AK_TEST_PLAIN}}
	@echo "✅ Clean"

clean-unifi:
	@echo "🧹 Removing {{UNIFI_PLAIN}}"
	rm -f {{UNIFI_PLAIN}}
	@echo "✅ Clean"

clean-unifi-networks:
	@echo "🧹 Removing {{UNIFI_NETWORKS_PLAIN}}"
	rm -f {{UNIFI_NETWORKS_PLAIN}}
	@echo "✅ Clean"

clean-unifi-wlans:
	@echo "🧹 Removing {{UNIFI_WLANS_PLAIN}}"
	rm -f {{UNIFI_WLANS_PLAIN}}
	@echo "✅ Clean"

clean-unifi-dns:
	@echo "🧹 Removing {{UNIFI_DNS_PLAIN}}"
	rm -f {{UNIFI_DNS_PLAIN}}
	@echo "✅ Clean"

clean-unifi-fixed-ips:
	@echo "🧹 Removing {{UNIFI_FIXED_IPS_PLAIN}}"
	rm -f {{UNIFI_FIXED_IPS_PLAIN}}
	@echo "✅ Clean"

clean-unifi-firewall:
	@echo "🧹 Removing {{UNIFI_FIREWALL_PLAIN}}"
	rm -f {{UNIFI_FIREWALL_PLAIN}}
	@echo "✅ Clean"

clean: clean-oci clean-ak-prod clean-ak-test clean-unifi
	@echo "✅ Cleaned all"

# -----------------------------
# OpenTofu convenience (optional)
# -----------------------------
plan-oci: decrypt-oci
	cd {{OCI_DIR}} && tofu plan
	just clean-oci

apply-oci: decrypt-oci
	cd {{OCI_DIR}} && tofu apply
	just clean-oci

plan-ak-prod: decrypt-ak-prod
	cd {{AK_PROD_DIR}} && tofu plan
	just clean-ak-prod

apply-ak-prod: decrypt-ak-prod
	cd {{AK_PROD_DIR}} && tofu apply
	just clean-ak-prod

plan-ak-test: decrypt-ak-test
	cd {{AK_TEST_DIR}} && tofu plan
	just clean-ak-test

apply-ak-test: decrypt-ak-test
	cd {{AK_TEST_DIR}} && tofu apply
	just clean-ak-test

discover-unifi: decrypt-unifi
	cd {{UNIFI_DIR}} && tofu init -upgrade -input=false && tofu apply -refresh-only -auto-approve -input=false
	cd {{UNIFI_DIR}} && tofu output -json inventory
	just clean-unifi

inventory-unifi-wifi: decrypt-unifi
	bash scripts/unifi-wifi-inventory.sh {{UNIFI_PLAIN}}
	just clean-unifi

inventory-unifi-dns: decrypt-unifi
	bash scripts/unifi-dns-inventory.sh {{UNIFI_PLAIN}}
	just clean-unifi

inventory-unifi-firewall: decrypt-unifi
	bash scripts/unifi-firewall-capture.sh {{UNIFI_PLAIN}} | jq '{zones: (.unifi_firewall_zones | length), groups: (.unifi_firewall_groups | length), user_policies: (.unifi_firewall_policies | length)}'
	just clean-unifi

capture-unifi-firewall: decrypt-unifi
	bash scripts/unifi-firewall-capture.sh {{UNIFI_PLAIN}} > {{UNIFI_FIREWALL_PLAIN}}
	just encrypt-unifi-firewall
	just clean-unifi clean-unifi-firewall

plan-unifi: decrypt-unifi decrypt-unifi-networks decrypt-unifi-wlans decrypt-unifi-dns decrypt-unifi-fixed-ips decrypt-unifi-firewall
	cd {{UNIFI_DIR}} && tofu plan -input=false
	just clean-unifi clean-unifi-networks clean-unifi-wlans clean-unifi-dns clean-unifi-fixed-ips clean-unifi-firewall

apply-unifi: decrypt-unifi decrypt-unifi-networks decrypt-unifi-wlans decrypt-unifi-dns decrypt-unifi-fixed-ips decrypt-unifi-firewall
	cd {{UNIFI_DIR}} && tofu init -upgrade -input=false && tofu apply
	just clean-unifi clean-unifi-networks clean-unifi-wlans clean-unifi-dns clean-unifi-fixed-ips clean-unifi-firewall


# -----------------------------
# SOPS maintenance
# -----------------------------
# Re-encrypt in-place (useful after changing .sops.yaml recipients/rules)
update-oci: _check-tools _check-dirs
	@echo "♻️  Updating (re-encrypting) {{OCI_ENC}}"
	{{SOPS}} -r --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{OCI_ENC}}
	@echo "✅ Updated {{OCI_ENC}}"

update-ak-prod: _check-tools _check-dirs
	@echo "♻️  Updating (re-encrypting) {{AK_PROD_ENC}}"
	{{SOPS}} -r --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{AK_PROD_ENC}}
	@echo "✅ Updated {{AK_PROD_ENC}}"

update-ak-test: _check-tools _check-dirs
	@echo "♻️  Updating (re-encrypting) {{AK_TEST_ENC}}"
	{{SOPS}} -r --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{AK_TEST_ENC}}
	@echo "✅ Updated {{AK_TEST_ENC}}"

update: update-oci update-ak-prod update-ak-test
	@echo "✅ Updated all encrypted files"

# Rotate data key in-place (and re-encrypt)
rotate-oci: _check-tools _check-dirs
	@echo "🔁 Rotating data key for {{OCI_ENC}}"
	{{SOPS}} --rotate --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{OCI_ENC}}
	@echo "✅ Rotated {{OCI_ENC}}"

rotate-ak-prod: _check-tools _check-dirs
	@echo "🔁 Rotating data key for {{AK_PROD_ENC}}"
	{{SOPS}} --rotate --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{AK_PROD_ENC}}
	@echo "✅ Rotated {{AK_PROD_ENC}}"

rotate-ak-test: _check-tools _check-dirs
	@echo "🔁 Rotating data key for {{AK_TEST_ENC}}"
	{{SOPS}} --rotate --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{AK_TEST_ENC}}
	@echo "✅ Rotated {{AK_TEST_ENC}}"

rotate: rotate-oci rotate-ak-prod rotate-ak-test
	@echo "✅ Rotated all encrypted files"
