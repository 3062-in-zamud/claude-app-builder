#!/usr/bin/env bats
# SKILL.md required fields validation tests

setup() {
  load test_helper
}

@test "all SKILL.md files have name in frontmatter" {
  local missing=()
  while IFS= read -r dir; do
    local skill_md="${dir}/SKILL.md"
    [ -f "$skill_md" ] || continue
    local name
    name="$(get_frontmatter_field "$skill_md" "name")"
    if [ -z "$name" ]; then
      missing+=("$(basename "$dir")")
    fi
  done < <(list_skill_dirs)

  if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing name field in: ${missing[*]}" >&2
    return 1
  fi
}

@test "all SKILL.md files have description in frontmatter" {
  local missing=()
  while IFS= read -r dir; do
    local skill_md="${dir}/SKILL.md"
    [ -f "$skill_md" ] || continue
    local desc
    desc="$(get_frontmatter_field "$skill_md" "description")"
    if [ -z "$desc" ]; then
      missing+=("$(basename "$dir")")
    fi
  done < <(list_skill_dirs)

  if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing description field in: ${missing[*]}" >&2
    return 1
  fi
}
