# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

OpenTofu/Terraform infrastructure-as-code repository managing Oracle Cloud Infrastructure (OCI) and Authentik identity management services. Uses SOPS with age encryption for secrets management.

## Commands

All commands use the Just command runner (`.justfile`):

```bash
# Planning and applying infrastructure
just plan-oci          # Plan OCI infrastructure changes
just apply-oci         # Apply OCI infrastructure changes
just plan-ak-prod      # Plan Authentik production changes
just apply-ak-prod     # Apply Authentik production changes

# Secrets management (SOPS + age encryption)
just decrypt           # Decrypt all sensitive terraform variables
just encrypt           # Encrypt all sensitive terraform variables
just decrypt-oci       # Decrypt OCI secrets only
just decrypt-ak-prod   # Decrypt Authentik prod secrets only

# Maintenance
just update            # Re-encrypt all files after config changes
just rotate            # Rotate encryption data keys
just clean             # Remove plaintext sensitive files
```

## Architecture

```
infra-tofu/
├── oci/                     # OCI infrastructure (VMs, networking, DNS, email, storage)
├── authentik/
│   └── envs/
│       └── prod/            # Production Authentik (users, groups, OAuth2 apps)
└── modules/
    └── authentik/           # Shared Authentik module for users/apps management
```

**OCI (`oci/`)**: Manages Oracle Cloud resources - Ubuntu VM instances, VCN with public/private subnets, CloudFlare DNS records, OCI email delivery, and object storage buckets.

**Authentik (`authentik/envs/prod`)**: Uses the shared module. Manages users, groups (authentik-admins, kids, parents, guests, homelab-admins), and OAuth2 providers for services like Grafana, Headscale, Immich, and Vaultwarden.

**Secrets**: Sensitive tfvars are SOPS-encrypted (`.enc` suffix). Configuration in `.sops.yaml` uses age encryption. Always run `just decrypt-*` before planning/applying.

## Conventions

- Conventional commit messages: `feat(scope):`, `fix(scope):`, `chore(scope):`
- Never leak network identifiers (IP addresses, MAC addresses, hostnames/DNS names) into commit messages, code comments, or anything sent outside the repo. Keep them only in the (encrypted) tfvars files and state.
- Provider versions locked via `.terraform.lock.hcl` files
- Renovate bot handles automated dependency updates
- Encrypted secrets in `secrets/` directories and `sensitive.auto.tfvars.enc` files
