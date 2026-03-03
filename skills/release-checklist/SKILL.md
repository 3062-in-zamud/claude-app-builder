---
name: release-checklist
description: |
  What: リリース前の50項目チェックリストを実行する
  When: Phase 6（monitoring-setup 後、deploy-setup 前）
  How: 全項目を順次確認 → 未完了項目を修正 → 全 ✅ でリリース許可
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Bash
---

# release-checklist: リリース前50項目チェック

## チェックリスト実行手順

`references/checklist-50items.md` の全50項目を以下の手順で確認:

1. 各項目を順番に確認
2. ✅（問題なし）/ ❌（要修正）/ ⏭️（スキップ）をマーク
3. ❌ の項目は即座に修正を試みる
4. 全 CRITICAL 項目が ✅ になってから deploy-setup へ進む

## Go/No-Go 判断

`references/go-no-go-criteria.md` に従い、リリース可否を判断する:

| カテゴリ | Go 条件 |
|----------|---------|
| CRITICAL 項目 | 全項目 ✅ |
| HIGH 項目 | 90% 以上 ✅ |
| MEDIUM 項目 | 70% 以上 ✅（残りは Issue 登録で可） |
| LOW 項目 | 50% 以上 ✅（残りは次スプリントで対応可） |

## チェック実行スクリプト（拡張版）

```bash
echo "=== リリース前自動チェック ==="
PASS=0
FAIL=0

# TypeScript エラー確認
echo -n "📋 TypeScript... "
if npx tsc --noEmit 2>/dev/null; then
  echo "✅ OK"; PASS=$((PASS+1))
else
  echo "❌ エラーあり"; FAIL=$((FAIL+1))
fi

# ESLint 確認
echo -n "📋 ESLint... "
if npx eslint src/ 2>/dev/null; then
  echo "✅ OK"; PASS=$((PASS+1))
else
  echo "❌ エラーあり"; FAIL=$((FAIL+1))
fi

# テスト実行
echo -n "📋 テスト... "
if npm test 2>/dev/null; then
  echo "✅ PASS"; PASS=$((PASS+1))
else
  echo "❌ 失敗"; FAIL=$((FAIL+1))
fi

# ビルド確認
echo -n "📋 ビルド... "
if npm run build 2>/dev/null; then
  echo "✅ 成功"; PASS=$((PASS+1))
else
  echo "❌ 失敗"; FAIL=$((FAIL+1))
fi

# npm audit
echo -n "📋 セキュリティ... "
if npm audit --audit-level=high 2>/dev/null; then
  echo "✅ OK"; PASS=$((PASS+1))
else
  echo "❌ HIGH以上の脆弱性あり"; FAIL=$((FAIL+1))
fi

# .env チェック
echo -n "📋 .env.example... "
if [ -f .env.example ]; then
  echo "✅ 存在"; PASS=$((PASS+1))
else
  echo "❌ 不在"; FAIL=$((FAIL+1))
fi

# SECURITY.md チェック
echo -n "📋 SECURITY.md... "
if [ -f SECURITY.md ]; then
  echo "✅ 存在"; PASS=$((PASS+1))
else
  echo "❌ 不在"; FAIL=$((FAIL+1))
fi

echo ""
echo "=== 結果: ✅ ${PASS} / ❌ ${FAIL} ==="
```

### 出力

`docs/release-report.md`（チェック結果レポート）
