#!/usr/bin/env bash
# test_helper.bash — 共通ヘルパー関数

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="${PROJECT_ROOT}/.claude-plugin"
SKILLS_DIR="${PROJECT_ROOT}/skills"

# SKILL.md から YAML frontmatter の値を取得
# Usage: get_frontmatter_field <file> <field>
get_frontmatter_field() {
  local file="$1"
  local field="$2"
  sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//"
}

# skills/ 配下のスキルディレクトリ一覧（不正なディレクトリ名を除外）
list_skill_dirs() {
  find "${SKILLS_DIR}" -mindepth 1 -maxdepth 1 -type d | grep -v '/\*$' | sort
}

# スキルディレクトリの数を返す
count_skills() {
  list_skill_dirs | wc -l | tr -d ' '
}
