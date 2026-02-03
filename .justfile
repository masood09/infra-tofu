set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# -----------------------------
# Config
# -----------------------------
SOPS := "sops"
INPUT_TYPE := "binary"
OUTPUT_TYPE := "binary"

OCI_DIR := "oci"
AK_TEST_DIR := "authentik/envs/test"

OCI_PLAIN := OCI_DIR + "/sensitive.auto.tfvars"
OCI_ENC   := OCI_DIR + "/sensitive.auto.tfvars.enc"

AK_TEST_PLAIN := AK_TEST_DIR + "/sensitive.auto.tfvars"
AK_TEST_ENC   := AK_TEST_DIR + "/sensitive.auto.tfvars.enc"

# -----------------------------
# Helpers
# -----------------------------
_check-tools:
	@command -v {{SOPS}} >/dev/null || { echo "❌ sops not found in PATH"; exit 1; }

_check-dirs:
	@mkdir -p {{OCI_DIR}} {{AK_TEST_DIR}}

# -----------------------------
# Encrypt
# -----------------------------
encrypt-oci: _check-tools _check-dirs
	@echo "🔐 Encrypting {{OCI_PLAIN}} -> {{OCI_ENC}} (binary)"
	{{SOPS}} -e --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} {{OCI_PLAIN}} > {{OCI_ENC}}
	@echo "✅ Wrote {{OCI_ENC}}"

encrypt-ak-test: _check-tools _check-dirs
	@echo "🔐 Encrypting {{AK_TEST_PLAIN}} -> {{AK_TEST_ENC}} (binary)"
	{{SOPS}} -e --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} {{AK_TEST_PLAIN}} > {{AK_TEST_ENC}}
	@echo "✅ Wrote {{AK_TEST_ENC}}"

encrypt: encrypt-oci encrypt-ak-test
	@echo "✅ Encrypted all"

# -----------------------------
# Decrypt
# -----------------------------
decrypt-oci: _check-tools _check-dirs
	@echo "🔓 Decrypting {{OCI_ENC}} -> {{OCI_PLAIN}} (binary)"
	{{SOPS}} -d --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} {{OCI_ENC}} > {{OCI_PLAIN}}
	@echo "✅ Wrote {{OCI_PLAIN}}"
	@echo "⚠️  Do NOT commit {{OCI_PLAIN}}"

decrypt-ak-test: _check-tools _check-dirs
	@echo "🔓 Decrypting {{AK_TEST_ENC}} -> {{AK_TEST_PLAIN}} (binary)"
	{{SOPS}} -d --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} {{AK_TEST_ENC}} > {{AK_TEST_PLAIN}}
	@echo "✅ Wrote {{AK_TEST_PLAIN}}"
	@echo "⚠️  Do NOT commit {{AK_TEST_PLAIN}}"

decrypt: decrypt-oci decrypt-ak-test
	@echo "✅ Decrypted all"

# -----------------------------
# Clean plaintext files
# -----------------------------
clean-oci:
	@echo "🧹 Removing {{OCI_PLAIN}}"
	rm -f {{OCI_PLAIN}}
	@echo "✅ Clean"

clean-ak-test:
	@echo "🧹 Removing {{AK_TEST_PLAIN}}"
	rm -f {{AK_TEST_PLAIN}}
	@echo "✅ Clean"

clean: clean-oci clean-ak-test
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

plan-ak-test: decrypt-ak-test
	cd {{AK_TEST_DIR}} && tofu plan
	just clean-ak-test

apply-ak-test: decrypt-ak-test
	cd {{AK_TEST_DIR}} && tofu apply
	just clean-ak-test


# -----------------------------
# SOPS maintenance
# -----------------------------
# Re-encrypt in-place (useful after changing .sops.yaml recipients/rules)
update-oci: _check-tools _check-dirs
	@echo "♻️  Updating (re-encrypting) {{OCI_ENC}}"
	{{SOPS}} -r --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{OCI_ENC}}
	@echo "✅ Updated {{OCI_ENC}}"

update-ak-test: _check-tools _check-dirs
	@echo "♻️  Updating (re-encrypting) {{AK_TEST_ENC}}"
	{{SOPS}} -r --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{AK_TEST_ENC}}
	@echo "✅ Updated {{AK_TEST_ENC}}"

update: update-oci update-ak-test
	@echo "✅ Updated all encrypted files"

# Rotate data key in-place (and re-encrypt)
rotate-oci: _check-tools _check-dirs
	@echo "🔁 Rotating data key for {{OCI_ENC}}"
	{{SOPS}} --rotate --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{OCI_ENC}}
	@echo "✅ Rotated {{OCI_ENC}}"

rotate-ak-test: _check-tools _check-dirs
	@echo "🔁 Rotating data key for {{AK_TEST_ENC}}"
	{{SOPS}} --rotate --input-type {{INPUT_TYPE}} --output-type {{OUTPUT_TYPE}} -i {{AK_TEST_ENC}}
	@echo "✅ Rotated {{AK_TEST_ENC}}"

rotate: rotate-oci rotate-ak-test
	@echo "✅ Rotated all encrypted files"
