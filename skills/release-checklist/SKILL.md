---
name: release-checklist
description: |
  What: リリース前の34項目チェックリストを実行する
  When: Phase 6（monitoring-setup 後、deploy-setup 前）
  How: 全項目を順次確認 → 未完了項目を修正 → 全 ✅ でリリース許可
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Bash
---

# release-checklist: リリース前34項目チェック

## チェックリスト実行手順

`references/checklist-34items.md` の全34項目を以下の手順で確認:

1. 各項目を順番に確認
2. ✅（問題なし）/ ❌（要修正）/ ⏭️（スキップ）をマーク
3. ❌ の項目は即座に修正を試みる
4. 全 CRITICAL 項目が ✅ になってから deploy-setup へ進む

## チェック実行スクリプト

```bash
# TypeScript エラー確認
npx tsc --noEmit && echo "✅ TypeScript OK" || echo "❌ TypeScript エラーあり"

# ESLint 確認
npx eslint src/ && echo "✅ ESLint OK" || echo "❌ ESLint エラーあり"

# テスト実行
npm test && echo "✅ テスト PASS" || echo "❌ テスト失敗"

# ビルド確認
npm run build && echo "✅ ビルド成功" || echo "❌ ビルド失敗"

# OGP タグ確認（ローカルサーバー起動後）
curl -s http://localhost:3000 | grep -E "og:|twitter:" | head -20
```

### 出力

`docs/release-report.md`（チェック結果レポート）
