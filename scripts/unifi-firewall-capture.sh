#!/usr/bin/env bash
set -euo pipefail

credentials_file=${1:?usage: $0 <credentials-file>}

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
zones_response=$(mktemp)
groups_response=$(mktemp)
policies_response=$(mktemp)
networks_response=$(mktemp)
trap 'rm -f "$cookie_file" "$login_response" "$zones_response" "$groups_response" "$policies_response" "$networks_response"' EXIT

login_payload=$(jq -cn --arg username "$username" --arg password "$password" '{username: $username, password: $password}')

curl -ksS -c "$cookie_file" -H 'Content-Type: application/json' \
  --data "$login_payload" "$api_url/api/auth/login" > "$login_response"
jq -e '(.meta.rc == "ok") or (.username != null and .unique_id != null)' "$login_response" >/dev/null

curl -ksS -b "$cookie_file" "$api_url/proxy/network/v2/api/site/$site/firewall/zone" > "$zones_response"
curl -ksS -b "$cookie_file" "$api_url/proxy/network/api/s/$site/rest/firewallgroup" > "$groups_response"
curl -ksS -b "$cookie_file" "$api_url/proxy/network/v2/api/site/$site/firewall-policies" > "$policies_response"
curl -ksS -b "$cookie_file" "$api_url/proxy/network/api/s/$site/rest/networkconf" > "$networks_response"

jq -n \
  --argjson zones "$(jq '[.[] | {id: ._id, name, network_ids, default_zone, zone_key}]' "$zones_response")" \
  --argjson groups "$(jq '[.data[] | {id: ._id, name, type: .group_type, members: .group_members}]' "$groups_response")" \
  --argjson networks "$(jq '[.data[] | {id: ._id, name}]' "$networks_response")" \
  --argjson policies "$(jq '[.[] | select((.predefined // false) == false) | {id: ._id, name, description, action, source: (.source | del(.matching_target_type)), destination: (.destination | del(.matching_target_type)), connection_state_type, connection_states, create_allow_respond, enabled, ip_version, logging, match_opposite_protocol, protocol}]' "$policies_response")" \
  '
    def keyify:
      ascii_downcase
      | gsub("^[0-9]+"; "")
      | gsub("[^a-z0-9]+"; "_")
      | gsub("^_+|_+$"; "");
    def key_for($items; $id): ($items[] | select(.id == $id) | .key);
    ($zones | map(. + {key: (.name | keyify)})) as $zone_map |
    ($groups | map(. + {key: (.name | keyify)})) as $group_map |
    ($networks | map(. + {key: (.name | keyify)}) | map(select(.key | startswith("internet") | not))) as $network_map |
    def endpoint:
      .zone_key = key_for($zone_map; .zone_id)
      | del(.zone_id)
      | if has("ip_group_id") then .ip_group_key = key_for($group_map; .ip_group_id) | del(.ip_group_id) else . end
      | if has("port_group_id") then .port_group_key = key_for($group_map; .port_group_id) | del(.port_group_id) else . end
      | if has("network_ids") then .network_keys = [.network_ids[] as $id | (key_for($network_map; $id) // $id)] | del(.network_ids) else . end;
    {
      unifi_firewall_zones: ($zone_map | map({key: .key, value: {id, name, network_keys: [.network_ids[] as $id | (key_for($network_map; $id) // $id)], default_zone, zone_key}}) | from_entries),
      unifi_firewall_groups: ($group_map | map({key: .key, value: {id, name, type, members}}) | from_entries),
      unifi_firewall_policies: ($policies | map({key: (.name | keyify), value: (. + {source: (.source | endpoint), destination: (.destination | endpoint)})}) | from_entries)
    }
  '
