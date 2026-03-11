#!/usr/bin/env bats
# marketplace.json schema validation tests

setup() {
  load test_helper
  MARKETPLACE_JSON="${PLUGIN_DIR}/marketplace.json"
  PLUGIN_JSON="${PLUGIN_DIR}/plugin.json"
}

@test "marketplace.json is valid JSON" {
  jq empty "$MARKETPLACE_JSON"
}

@test "marketplace.json has name field" {
  result="$(jq -r '.name' "$MARKETPLACE_JSON")"
  [ -n "$result" ] && [ "$result" != "null" ]
}

@test "marketplace.json has plugins array" {
  result="$(jq -r '.plugins | type' "$MARKETPLACE_JSON")"
  [ "$result" = "array" ]
}

@test "marketplace.json plugins[0].version matches plugin.json version" {
  mp_version="$(jq -r '.plugins[0].version' "$MARKETPLACE_JSON")"
  pl_version="$(jq -r '.version' "$PLUGIN_JSON")"
  [ "$mp_version" = "$pl_version" ]
}

@test "marketplace.json plugins[0].name matches plugin.json name" {
  mp_name="$(jq -r '.plugins[0].name' "$MARKETPLACE_JSON")"
  pl_name="$(jq -r '.name' "$PLUGIN_JSON")"
  [ "$mp_name" = "$pl_name" ]
}
