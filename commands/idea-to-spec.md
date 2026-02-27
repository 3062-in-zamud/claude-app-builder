---
name: idea-to-spec
description: |
  What: アイデアをヒアリングして要件定義書（requirements.md）を生成する
  When: 新規アプリ開発の最初のステップ。/idea-to-spec "アイデア" で起動
  How: 5つの質問でヒアリング → requirements.md を生成
argument-hint: "\"アプリのアイデアを日本語または英語で説明\""
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

$ARGUMENTS を idea-to-spec スキルに渡して実行してください。
~/.claude/skills/idea-to-spec/SKILL.md の手順に従い、
claude-sonnet-4-6 モデルを使用してアイデアから要件定義書を生成してください。
