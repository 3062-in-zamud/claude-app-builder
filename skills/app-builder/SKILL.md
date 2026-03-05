---
name: app-builder
description: |
  What: アイデアを0からMVPリリースまで全自動で実現するメインオーケストレーター
  When: /app-builder "アイデア" で起動。新規アプリの0→1開発時
  How: 8フェーズ（要件定義〜デプロイ）を順次実行し、G1〜G3ゲートで品質を担保する
model: claude-opus-4-6
allowed-tools:
  - Task
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# App Builder - メインオーケストレーター

## 体験契約

このオーケストレーターは、以下の体験を保証する:
1. 要件承認なしで実装を進めない（G1）
2. セキュリティを満たさずにデプロイに進めない（G2）
3. 本番検証を満たさずに完了報告しない（G3）

## ユーザー介入ポイント

1. アイデア入力（起動時）
2. 競合サービス名の入力（Phase 0.5）
3. Phase 1後の要件承認（G1）
4. Phase 2での deployment_provider 制約確認
5. `.env.local` の値入力（Phase 7前）
6. 本番確認（G3後）

## 起動前チェック

```bash
# GitHub ログイン確認
gh auth status >/dev/null 2>&1 || {
  echo "⚠️ GitHub CLI にログインしていません"
  echo "   gh auth login を実行してください"
  exit 1
}

# Supabase ログイン確認
supabase projects list >/dev/null 2>&1 || {
  echo "⚠️ Supabase にログインしていません"
  echo "   supabase login を実行してください"
  exit 1
}
```

## フェーズ実行ワークフロー

### Phase 0: ユーザーリサーチ（推奨）

- `user-research` [Sonnet] → `docs/personas.md` + `docs/interview-guide.md` + `docs/hypothesis.md`

### Phase 0.5: 市場調査（推奨）

- `market-research` [Sonnet] → `docs/market-research.md`

### Phase 1: 要件定義 + ブランディング

1. `idea-to-spec` [Sonnet] → `docs/requirements.md`
2. `brand-foundation` [Opus] → `docs/brand-brief.md`

### G1: 要件承認ゲート（必須）

```
📋 G1 - 要件承認ゲート

[requirements.md サマリー]
[brand-brief.md サマリー]

✅ 承認 -> Phase 2へ進む
✏️ 修正 -> Phase 1を再実行
```

### Phase 2: 設計 + ブランドアセット

- `stack-selector` [Sonnet] → `docs/tech-stack.md`
- `visual-designer` [Opus] → `docs/design-system.md`

`docs/tech-stack.md` の契約キーを検証する。

```bash
extract_value() {
  local key="$1"
  grep -E "^[[:space:]-]*${key}:" docs/tech-stack.md 2>/dev/null | head -1 | sed -E "s/^[[:space:]-]*${key}:[[:space:]]*//" | tr -d '\r'
}

APP_TYPE="$(extract_value app_type)"
DEPLOYMENT_PROVIDER="$(extract_value deployment_provider)"
APP_DOMAIN="$(extract_value app_domain)"

[ -n "$APP_TYPE" ] || { echo "❌ app_type が未定義です"; exit 1; }
[ -n "$DEPLOYMENT_PROVIDER" ] || { echo "❌ deployment_provider が未定義です"; exit 1; }
[ -n "$APP_DOMAIN" ] || { echo "❌ app_domain が未定義です"; exit 1; }

if [ "$DEPLOYMENT_PROVIDER" = "vercel" ]; then
  vercel whoami >/dev/null 2>&1 || {
    echo "⚠️ Vercel にログインしていません"
    echo "   vercel login を実行してください"
    exit 1
  }
elif [ "$DEPLOYMENT_PROVIDER" = "cloudflare-pages" ]; then
  CF_PROJECT="$(extract_value cloudflare_pages_project)"
  CF_BUILD_COMMAND="$(extract_value cloudflare_build_command)"
  CF_BUILD_DIR="$(extract_value cloudflare_build_dir)"

  [ -n "$CF_PROJECT" ] || { echo "❌ cloudflare_pages_project が未定義です"; exit 1; }
  [ -n "$CF_BUILD_COMMAND" ] || { echo "❌ cloudflare_build_command が未定義です"; exit 1; }
  [ -n "$CF_BUILD_DIR" ] || { echo "❌ cloudflare_build_dir が未定義です"; exit 1; }

  wrangler whoami >/dev/null 2>&1 || {
    echo "⚠️ Cloudflare にログインしていません"
    echo "   wrangler login を実行してください"
    exit 1
  }
else
  echo "❌ 未対応の deployment_provider: $DEPLOYMENT_PROVIDER"
  exit 1
fi
```

### Phase 3: リポジトリ準備

1. `project-scaffold` [Haiku]
2. `ci-setup` [Sonnet]
3. `github-repo-setup` [Haiku+Sonnet]

### Phase 4: ドキュメント + LP + 法務 + SEO + Cookie

- `documentation-suite`
- `landing-page-builder`
- `legal-docs-generator`
- `seo-setup`
- `cookie-consent`

### Phase 5: 実装 + テスト

- `implementation` [Sonnet]（TDD + Coverage 80%+）
- `analytics-events` [Sonnet]（provider別イベント基盤）

### Phase 5.5: セキュリティ強化

- `security-hardening` [Opus]

### G2: セキュリティゲート（必須）

以下を満たさない場合、Phase 6へ進めない:

- CRITICAL 脆弱性 0
- `npm audit` HIGH 0
- IDOR / RLS / Secret / CSRF チェック完了

### Phase 6: デプロイ準備

- `monitoring-setup` [Sonnet]
- `release-checklist` [Sonnet]

### Phase 7: デプロイ実行

- `deploy-setup` [Haiku→Sonnet]
  - Supabase migration
  - provider別デプロイ（vercel / cloudflare-pages）
  - スモークテスト

### G3: MVP品質ゲート（必須）

以下を満たさない場合、完了報告しない:

- `/api/health` が HTTP 200
- テストカバレッジ 80%+
- Lighthouse: Performance 90+, Accessibility 95+
- 本番スモークテスト PASS

### Phase 8: リリース報告 + フィードバック設計

- `feedback-loop` [Sonnet]
- 本番URL/運用チェック/次アクションを報告

## ゲート定義（app-builder）

| ゲート | 位置 | 条件 |
|--------|------|------|
| G1 | Phase 1 後 | 要件承認 |
| G2 | Phase 5.5 後 | セキュリティ必須条件を満たす |
| G3 | Phase 7 後 | MVP品質条件を満たす |

## モデル割り当て

| タスク | モデル |
|--------|--------|
| リーダー統括 | `claude-opus-4-6` |
| 要件定義・実装・運用 | `claude-sonnet-4-6` |
| テンプレ展開 | `claude-haiku-4-5-20251001` |
| セキュリティレビュー | `claude-opus-4-6` |

## エラーハンドリング

3回失敗した場合は自動でエスカレーションし、次の選択肢を提示:
1. 手動修正して続行
2. 中断して後で再開
3. 前フェーズへ戻って再実行
