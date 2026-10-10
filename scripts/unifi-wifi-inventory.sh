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
wlan_response=$(mktemp)
trap 'rm -f "$cookie_file" "$login_response" "$wlan_response"' EXIT

login_payload=$(jq -cn --arg username "$username" --arg password "$password" '{username: $username, password: $password}')

curl -ksS \
  -c "$cookie_file" \
  -H 'Content-Type: application/json' \
  --data "$login_payload" \
  "$api_url/api/auth/login" > "$login_response"

jq -e '(.meta.rc == "ok") or (.username != null and .unique_id != null)' "$login_response" >/dev/null

curl -ksS \
  -b "$cookie_file" \
  "$api_url/proxy/network/api/s/$site/rest/wlanconf" > "$wlan_response"

jq -e '.meta.rc == "ok"' "$wlan_response" >/dev/null

# Deliberately project fields instead of returning the controller response. This
# prevents x_passphrase, private_preshared_keys, and other secret fields from
# entering inventory output or Terraform state.
jq '[.data[] | {
  id: ._id,
  name,
  enabled,
  security,
  network_id: .networkconf_id,
  user_group_id: .usergroup_id,
  wlan_band,
  wlan_bands,
  is_guest,
  l2_isolation,
  hide_ssid,
  wpa_mode,
  wpa_enc,
  wpa3_support,
  wpa3_transition,
  pmf_mode,
  fast_roaming_enabled
}] | sort_by(.name)' "$wlan_response"
