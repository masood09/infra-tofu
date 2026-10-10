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
dns_response=$(mktemp)
trap 'rm -f "$cookie_file" "$login_response" "$dns_response"' EXIT

login_payload=$(jq -cn --arg username "$username" --arg password "$password" '{username: $username, password: $password}')

curl -ksS \
  -c "$cookie_file" \
  -H 'Content-Type: application/json' \
  --data "$login_payload" \
  "$api_url/api/auth/login" > "$login_response"

jq -e '(.meta.rc == "ok") or (.username != null and .unique_id != null)' "$login_response" >/dev/null

curl -ksS \
  -b "$cookie_file" \
  "$api_url/proxy/network/v2/api/site/$site/static-dns" > "$dns_response"

jq '[.[] | {
  id: ._id,
  enabled,
  name: .key,
  record_type,
  value,
  port,
  priority,
  ttl,
  weight
}] | sort_by(.name)' "$dns_response"
