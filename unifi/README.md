# UniFi inventory

This root is the read-only bootstrap for bringing the UniFi Network controller
under OpenTofu management. It currently declares data sources only and does not
create or update UniFi configuration.

## Credentials

Create a dedicated UniFi local account with access to the target site. Copy
`sensitive.auto.tfvars.example` to `sensitive.auto.tfvars`, fill in the local
controller URL and credentials, and encrypt it with:

```bash
sops -e --input-type binary --output-type binary \
  sensitive.auto.tfvars > sensitive.auto.tfvars.enc
rm sensitive.auto.tfvars
```

The encrypted file is the only credentials file that should be committed.

## Discovery

```bash
just discover-unifi
```

The command initializes the provider, refreshes read-only client data, and
prints the inventory outputs as JSON. Later management resources should be
added incrementally and imported from the existing controller configuration.
