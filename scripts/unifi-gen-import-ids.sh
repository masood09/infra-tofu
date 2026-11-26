#!/usr/bin/env bash
# Regenerate unifi/import_ids.auto.tfvars.json from live controller IDs.
#
# Unlike the inventory/capture scripts (which key objects by name-derived keys),
# this script keys every import ID by the map key used in the *.auto.tfvars.json
# config files, matching objects by their `name` field. The import blocks in
# imports.tf iterate over config keys, so only config-keyed IDs are usable.
#
# Usage: unifi-gen-import-ids.sh <credentials-file>
# Requires the decrypted config files (networks, wlans, dns, firewall) to sit
# next to the credentials file. JSON goes to stdout; match reports go to stderr.
set -euo pipefail

credentials_file=${1:?usage: $0 <credentials-file>}
dir=$(dirname "$credentials_file")

for f in networks wlans dns firewall; do
  [[ -f "$dir/$f.auto.tfvars.json" ]] || { echo "missing decrypted config: $dir/$f.auto.tfvars.json" >&2; exit 1; }
done

read_tfvar() {
  local key=$1
  awk -F'"' -v key="$key" '$1 ~ "^" key "[[:space:]]*=" { print $2; exit }' "$credentials_file"
}

api_url=$(read_tfvar unifi_api_url)
username=$(read_tfvar unifi_username)
password=$(read_tfvar unifi_password)
site=$(read_tfvar unifi_site)

cookie_file=$(mktemp)
login_response=$(mktemp)
networks_response=$(mktemp)
wlans_response=$(mktemp)
dns_response=$(mktemp)
zones_response=$(mktemp)
groups_response=$(mktemp)
policies_response=$(mktemp)
trap 'rm -f "$cookie_file" "$login_response" "$networks_response" "$wlans_response" "$dns_response" "$zones_response" "$groups_response" "$policies_response"' EXIT

login_payload=$(jq -cn --arg username "$username" --arg password "$password" '{username: $username, password: $password}')

curl -ksS -c "$cookie_file" -H 'Content-Type: application/json' \
  --data "$login_payload" "$api_url/api/auth/login" > "$login_response"
jq -e '(.meta.rc == "ok") or (.username != null and .unique_id != null)' "$login_response" >/dev/null

curl -ksS -b "$cookie_file" "$api_url/proxy/network/api/s/$site/rest/networkconf" > "$networks_response"
curl -ksS -b "$cookie_file" "$api_url/proxy/network/api/s/$site/rest/wlanconf" > "$wlans_response"
curl -ksS -b "$cookie_file" "$api_url/proxy/network/v2/api/site/$site/static-dns" > "$dns_response"
curl -ksS -b "$cookie_file" "$api_url/proxy/network/v2/api/site/$site/firewall/zone" > "$zones_response"
curl -ksS -b "$cookie_file" "$api_url/proxy/network/api/s/$site/rest/firewallgroup" > "$groups_response"
curl -ksS -b "$cookie_file" "$api_url/proxy/network/v2/api/site/$site/firewall-policies" > "$policies_response"

# Each live list is normalised to [{id, name}], each config map to {config_key: name}.
live_networks=$(jq -c '[.data[] | {id: ._id, name}]' "$networks_response")
live_wlans=$(jq -c '[.data[] | {id: ._id, name}]' "$wlans_response")
live_dns=$(jq -c '[.[] | {id: ._id, name: .key}]' "$dns_response")
live_zones=$(jq -c '[.[] | {id: ._id, name}]' "$zones_response")
live_groups=$(jq -c '[.data[] | select(.name != null) | {id: ._id, name}]' "$groups_response")
live_policies=$(jq -c '[.[] | select((.predefined // false) == false) | {id: ._id, name}]' "$policies_response")

cfg_networks=$(jq -c '[.unifi_networks | to_entries[] | {key, name: .value.name}]' "$dir/networks.auto.tfvars.json")
cfg_wlans=$(jq -c '[.unifi_wlans | to_entries[] | {key, name: .value.name}]' "$dir/wlans.auto.tfvars.json")
cfg_dns=$(jq -c '[.unifi_dns_records | to_entries[] | {key, name: .value.name}]' "$dir/dns.auto.tfvars.json")
cfg_zones=$(jq -c '[.unifi_firewall_zones | to_entries[] | {key, name: .value.name}]' "$dir/firewall.auto.tfvars.json")
cfg_groups=$(jq -c '[.unifi_firewall_groups | to_entries[] | {key, name: .value.name}]' "$dir/firewall.auto.tfvars.json")
cfg_policies=$(jq -c '[.unifi_firewall_policies | to_entries[] | {key, name: .value.name}]' "$dir/firewall.auto.tfvars.json")

jq -n \
  --argjson liveNetworks "$live_networks" \
  --argjson liveWlans "$live_wlans" \
  --argjson liveDns "$live_dns" \
  --argjson liveZones "$live_zones" \
  --argjson liveGroups "$live_groups" \
  --argjson livePolicies "$live_policies" \
  --argjson cfgNetworks "$cfg_networks" \
  --argjson cfgWlans "$cfg_wlans" \
  --argjson cfgDns "$cfg_dns" \
  --argjson cfgZones "$cfg_zones" \
  --argjson cfgGroups "$cfg_groups" \
  --argjson cfgPolicies "$cfg_policies" \
  '
    def name2id: map({(.name): .id}) | add // {};

    # config key -> live id, matched on name.
    # stderr warnings for config entries with no live object and for live
    # objects with no config entry (unmanaged); both are excluded from output.
    def ids($label; $cfg; $live):
      ($live | name2id) as $map
      | ($cfg | map(.name) | unique) as $cfgNames
      | (reduce ($cfg[] | select($map[.name] == null)) as $c (
           null; "\($label): no controller object named \"\($c.name)\" (config key: \($c.key))" | stderr | null)) as $_w1
      | (reduce ($live[] | .name as $n | select($n != null and (($cfgNames | index($n)) | not))) as $l (
           null; "\($label): on controller but not in config: \($l.name) [\($l.id)]" | stderr | null)) as $_w2
      | $cfg
      | map(select($map[.name] != null) | {key, value: $map[.name]})
      | from_entries;

    {
      unifi_import_ids: {
        networks: ids("network"; $cfgNetworks; $liveNetworks),
        wlans: ids("wlan"; $cfgWlans; $liveWlans),
        dns_records: ids("dns_record"; $cfgDns; $liveDns),
        firewall_zones: ids("firewall_zone"; $cfgZones; $liveZones),
        firewall_groups: ids("firewall_group"; $cfgGroups; $liveGroups),
        firewall_policies: ids("firewall_policy"; $cfgPolicies; $livePolicies)
      }
    }
  '
