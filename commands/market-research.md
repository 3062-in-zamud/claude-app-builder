---
name: market-research
description: |
  What: 競合調査と市場規模の概算を行う（Phase 0.5）
  When: idea-to-spec の前に実行。/market-research で起動
  How: ユーザーにヒアリング → 公開サイトをWebFetch → docs/market-research.md 生成
allowed-tools:
  - Read
  - Write
  - WebFetch
  - AskUserQuestion
---

$ARGUMENTS を market-research スキルに渡して実行してください。
~/.claude/skills/market-research/SKILL.md の手順に従い、
claude-sonnet-4-6 モデルを使用して市場調査を実行してください。
