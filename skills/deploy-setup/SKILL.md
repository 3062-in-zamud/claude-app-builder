---
name: deploy-setup
description: |
  What: Supabase + deployment_provider（Vercel / Cloudflare Pages）への本番デプロイを実行し、ローンチ素材を生成する
  When: Phase 7（release-checklist 全項目 ✅ 後）
  How: tech-stack契約検証 → デプロイ前チェック → provider別デプロイ → スモークテスト → ローンチ素材
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Bash
---

# deploy-setup: デプロイ実行

## 重要方針

- `docs/tech-stack.md` の契約キー未定義時は即失敗（暗黙フォールバック禁止）
- DB/Auth は Supabase 前提
- `deployment_provider=cloudflare-pages` の場合、Cloudflare用ビルドを明示実行

## ワークフロー

### Step 0: tech-stack 契約検証（必須）

```bash
extract_value() {
  local key="$1"
  grep -E "^[[:space:]-]*${key}:" docs/tech-stack.md 2>/dev/null | head -1 | sed -E "s/^[[:space:]-]*${key}:[[:space:]]*//" | tr -d '\r'
}

DEPLOYMENT_PROVIDER="$(extract_value deployment_provider)"
APP_DOMAIN="$(extract_value app_domain)"
CF_PAGES_PROJECT="$(extract_value cloudflare_pages_project)"
CF_BUILD_COMMAND="$(extract_value cloudflare_build_command)"
CF_BUILD_DIR="$(extract_value cloudflare_build_dir)"

[ -n "$DEPLOYMENT_PROVIDER" ] || { echo "❌ deployment_provider が未定義です"; exit 1; }
[ -n "$APP_DOMAIN" ] || { echo "❌ app_domain が未定義です"; exit 1; }

if [ "$DEPLOYMENT_PROVIDER" = "cloudflare-pages" ]; then
  [ -n "$CF_PAGES_PROJECT" ] || { echo "❌ cloudflare_pages_project が未定義です"; exit 1; }
  [ -n "$CF_BUILD_COMMAND" ] || { echo "❌ cloudflare_build_command が未定義です"; exit 1; }
  [ -n "$CF_BUILD_DIR" ] || { echo "❌ cloudflare_build_dir が未定義です"; exit 1; }
fi

echo "📦 deployment_provider: $DEPLOYMENT_PROVIDER"
echo "🌐 app_domain: $APP_DOMAIN"
```

### Step 1: デプロイ前チェック（必須）

```bash
echo "=== デプロイ前チェック ==="

echo "📋 Supabase マイグレーション差分..."
supabase db diff 2>/dev/null | head -20 || echo "⚠️ diff取得に失敗"

echo "📋 ビルドチェック..."
npm run build >/dev/null
```

### Step 2: ログイン確認（必須）

```bash
supabase projects list >/dev/null 2>&1 || {
  echo "❌ supabase login が必要です"
  exit 1
}

if [ "$DEPLOYMENT_PROVIDER" = "vercel" ]; then
  vercel whoami >/dev/null 2>&1 || {
    echo "❌ vercel login が必要です"
    exit 1
  }
elif [ "$DEPLOYMENT_PROVIDER" = "cloudflare-pages" ]; then
  wrangler whoami >/dev/null 2>&1 || {
    echo "❌ wrangler login が必要です"
    exit 1
  }
else
  echo "❌ 未対応 provider: $DEPLOYMENT_PROVIDER"
  exit 1
fi
```

### Step 3: 環境変数反映（provider別）

```bash
if [ ! -f ".env.local" ]; then
  echo "⚠️ .env.local が見つかりません。手動設定してください"
else
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$line" ]] && continue
    key="${line%%=*}"
    value="${line#*=}"
    [ -z "$key" ] && continue

    if [ "$DEPLOYMENT_PROVIDER" = "vercel" ]; then
      printf '%s' "$value" | vercel env add "$key" production >/dev/null 2>&1 || true
    else
      printf '%s' "$value" | wrangler pages secret put "$key" --project-name "$CF_PAGES_PROJECT" >/dev/null 2>&1 || true
    fi
  done < .env.local
fi
```

### Step 4: Supabase マイグレーション適用

```bash
supabase db status
supabase db diff 2>/dev/null | grep -iE "DROP|ALTER.*RENAME|ALTER.*DROP" && {
  echo "⚠️ 破壊的変更を検知。Expand-Contractを確認してください"
}
supabase db push
supabase db status
```

### Step 5: provider別デプロイ

```bash
if [ "$DEPLOYMENT_PROVIDER" = "vercel" ]; then
  PREVIEW_URL=$(vercel --yes 2>/dev/null | grep -E "^https://" | tail -1)
  [ -n "$PREVIEW_URL" ] && echo "🔍 Preview URL: $PREVIEW_URL"

  DEPLOY_URL=$(vercel --prod --yes 2>/dev/null | grep -E "^https://" | tail -1)
else
  echo "📦 Cloudflare build command 実行: $CF_BUILD_COMMAND"
  eval "$CF_BUILD_COMMAND"

  if [ ! -d "$CF_BUILD_DIR" ]; then
    echo "❌ build成果物ディレクトリが存在しません: $CF_BUILD_DIR"
    exit 1
  fi

  DEPLOY_URL=$(wrangler pages deploy "$CF_BUILD_DIR" --project-name "$CF_PAGES_PROJECT" 2>/dev/null | grep -Eo 'https://[^ ]+' | tail -1)
fi

[ -n "$DEPLOY_URL" ] || { echo "❌ デプロイURL取得に失敗しました"; exit 1; }
echo "🚀 デプロイ URL: $DEPLOY_URL"
```

### Step 6: スモークテスト

```bash
check() {
  local name="$1"; local url="$2"; local expected="$3"
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
  if [ "$status" != "$expected" ]; then
    echo "❌ $name -> HTTP $status (expected $expected)"
    return 1
  fi
  echo "✅ $name -> HTTP $status"
  return 0
}

check "health" "$DEPLOY_URL/api/health" "200"
check "top" "$DEPLOY_URL" "200"
check "favicon" "$DEPLOY_URL/favicon.ico" "200" || true
```

### Step 7: ロールバック方針

```bash
if [ "$DEPLOYMENT_PROVIDER" = "vercel" ]; then
  echo "vercel rollback で即時切り戻し"
else
  echo "wrangler pages deployment list/promote で切り戻し"
fi

echo "Supabase は forward-only。逆マイグレーションで戻す"
```

### Step 8: ローンチ素材生成

`docs/requirements.md` と `docs/brand-brief.md` を元に以下を生成:
- Product Hunt 投稿文
- X 投稿文
- LinkedIn 投稿文

## 出力

- デプロイ完了報告（`DEPLOY_URL` + スモークテスト結果）
- `docs/launch-materials.md`

## 品質チェック

- [ ] `docs/tech-stack.md` 契約キーが揃っている
- [ ] providerログイン確認が通る
- [ ] Supabase マイグレーション適用済み
- [ ] provider別デプロイが成功
- [ ] スモークテストが成功
- [ ] ロールバック手順を確認済み
