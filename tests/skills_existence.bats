#!/usr/bin/env bats
# Skill directory and SKILL.md existence checks

setup() {
  load test_helper
}

@test "all skill directories contain SKILL.md" {
  local missing=()
  while IFS= read -r dir; do
    if [ ! -f "${dir}/SKILL.md" ]; then
      missing+=("$(basename "$dir")")
    fi
  done < <(list_skill_dirs)

  if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing SKILL.md in: ${missing[*]}" >&2
    return 1
  fi
}

@test "at least one skill directory exists" {
  local count
  count="$(count_skills)"
  [ "$count" -gt 0 ]
}
