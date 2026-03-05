# デプロイ後検証ガイド

## 前提

- `deployment_provider` は `docs/tech-stack.md` で定義済み
- DB/Auth は Supabase

## スモークテスト項目

| # | 項目 | エンドポイント | 期待値 | 重要度 |
|---|------|---------------|--------|--------|
| 1 | ヘルスチェック | `/api/health` | 200 | CRITICAL |
| 2 | トップページ | `/` | 200 | CRITICAL |
| 3 | 認証ページ | `/login` or `/auth` | 200 | HIGH |
| 4 | 静的アセット | `/favicon.ico` | 200 | MEDIUM |

## provider別監視確認

### Vercel
1. Vercel Analytics（トラフィック）
2. Vercel Logs（サーバーログ）
3. Sentry（エラー）

### Cloudflare Pages
1. Cloudflare Web Analytics（トラフィック）
2. Cloudflare Pages/Functions Logs
3. Sentry（エラー）

## 推奨確認タイミング

| タイミング | 確認内容 |
|-----------|---------|
| 直後 | ヘルスチェック、主要ページ |
| 5分後 | エラー率、ログ |
| 30分後 | トラフィック正常性 |
| 2時間後 | レイテンシ劣化の有無 |
| 24時間後 | 全体安定性 |

## 自動スモークテストスクリプト

```bash
#!/bin/bash
DEPLOY_URL="${1:?Usage: smoke-test.sh <deploy-url>}"

check() {
  local name="$1"; local path="$2"; local expected="$3"
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL$path" 2>/dev/null || echo "000")
  if [ "$status" = "$expected" ]; then
    echo "✅ $name: $status"
  else
    echo "❌ $name: $status (expected $expected)"
    return 1
  fi
}

check "health" "/api/health" "200"
check "top" "/" "200"
check "auth" "/login" "200" || true
check "favicon" "/favicon.ico" "200" || true
```
