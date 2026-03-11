#!/usr/bin/env bats
# install.sh smoke tests

setup() {
  load test_helper
  INSTALL_SH="${PROJECT_ROOT}/install.sh"
}

@test "install.sh exists and is executable" {
  [ -f "$INSTALL_SH" ]
  [ -x "$INSTALL_SH" ]
}

@test "install.sh contains set -euo pipefail" {
  grep -q 'set -euo pipefail' "$INSTALL_SH"
}

@test "install.sh defines cleanup_on_error function" {
  grep -q 'cleanup_on_error()' "$INSTALL_SH"
}

@test "install.sh passes syntax check" {
  bash -n "$INSTALL_SH"
}
