#!/usr/bin/env bats
# plugin.json schema validation tests

setup() {
  load test_helper
  PLUGIN_JSON="${PLUGIN_DIR}/plugin.json"
}

@test "plugin.json is valid JSON" {
  jq empty "$PLUGIN_JSON"
}

@test "plugin.json has name field" {
  result="$(jq -r '.name' "$PLUGIN_JSON")"
  [ -n "$result" ] && [ "$result" != "null" ]
}

@test "plugin.json has version field" {
  result="$(jq -r '.version' "$PLUGIN_JSON")"
  [ -n "$result" ] && [ "$result" != "null" ]
}

@test "plugin.json version is semver format" {
  version="$(jq -r '.version' "$PLUGIN_JSON")"
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "plugin.json has description field" {
  result="$(jq -r '.description' "$PLUGIN_JSON")"
  [ -n "$result" ] && [ "$result" != "null" ]
}

@test "plugin.json has license field" {
  result="$(jq -r '.license' "$PLUGIN_JSON")"
  [ -n "$result" ] && [ "$result" != "null" ]
}
