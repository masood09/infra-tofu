# UniFi OpenTofu configuration

This root manages selected UniFi Network configuration and imports existing
controller objects before making them declarative. Networks, WLANs, firewall
objects, DNS records, and fixed client IPs are supported.

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

The command initializes the provider, refreshes client and network inventory,
and prints the inventory outputs as JSON.
