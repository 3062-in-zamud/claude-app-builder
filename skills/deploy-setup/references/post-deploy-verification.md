# デプロイ後検証ガイド

## スモークテスト項目

### 必須（全プロジェクト共通）

| # | テスト項目 | エンドポイント | 期待値 | 重要度 |
|---|-----------|---------------|--------|--------|
| 1 | ヘルスチェック | `/api/health` | HTTP 200 | CRITICAL |
| 2 | トップページ表示 | `/` | HTTP 200 | CRITICAL |
| 3 | 認証ページ | `/login` or `/auth` | HTTP 200 | HIGH |
| 4 | 静的アセット | `/favicon.ico` | HTTP 200 | MEDIUM |
| 5 | OGP メタタグ | `/` のHTML | og:title 存在 | MEDIUM |

### 認証付き（Supabase Auth 使用時）

| # | テスト項目 | 確認方法 | 期待値 |
|---|-----------|---------|--------|
| 6 | サインアップ | テストユーザーで登録 | 成功 |
| 7 | ログイン | テストユーザーでログイン | セッション取得 |
| 8 | 保護ルート | 未認証で `/dashboard` | リダイレクト |

### API（REST エンドポイント使用時）

| # | テスト項目 | 確認方法 | 期待値 |
|---|-----------|---------|--------|
| 9 | GET リクエスト | 主要API | HTTP 200 or 401 |
| 10 | POST リクエスト | テストデータ送信 | HTTP 201 or 401 |
| 11 | レート制限 | 連続リクエスト | HTTP 429 |

## スモークテスト自動実行スクリプト

```bash
#!/bin/bash
# smoke-test.sh - デプロイ後自動スモークテスト
# Usage: ./smoke-test.sh <deploy-url>

DEPLOY_URL="${1:?Usage: smoke-test.sh <deploy-url>}"
PASS=0
FAIL=0
WARN=0

check() {
  local name="$1" url="$2" expected="$3" severity="$4"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
  if [ "$STATUS" = "$expected" ]; then
    echo "  ✅ $name → HTTP $STATUS"
    PASS=$((PASS + 1))
  elif [ "$severity" = "CRITICAL" ]; then
    echo "  ❌ $name → HTTP $STATUS (expected $expected)"
    FAIL=$((FAIL + 1))
  else
    echo "  ⚠️  $name → HTTP $STATUS (expected $expected)"
    WARN=$((WARN + 1))
  fi
}

echo "=== スモークテスト: $DEPLOY_URL ==="
check "ヘルスチェック" "$DEPLOY_URL/api/health" "200" "CRITICAL"
check "トップページ" "$DEPLOY_URL" "200" "CRITICAL"
check "プライバシーポリシー" "$DEPLOY_URL/privacy" "200" "HIGH"
check "利用規約" "$DEPLOY_URL/terms" "200" "HIGH"
check "favicon" "$DEPLOY_URL/favicon.ico" "200" "MEDIUM"

echo ""
echo "=== 結果 ==="
echo "  ✅ Pass: $PASS"
echo "  ❌ Fail: $FAIL"
echo "  ⚠️  Warn: $WARN"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "❌ CRITICAL な失敗があります。ロールバックを検討してください"
  exit 1
fi
```

## ヘルスチェックエンドポイント拡張例

基本のヘルスチェック（`/api/health`）に加え、依存サービスの状態も確認する。

```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function GET() {
  const checks: Record<string, 'ok' | 'error'> = {};

  // 1. アプリケーション自体
  checks.app = 'ok';

  // 2. Supabase 接続
  try {
    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!
    );
    const { error } = await supabase.from('_health').select('*').limit(1);
    checks.database = error ? 'error' : 'ok';
  } catch {
    checks.database = 'error';
  }

  const allOk = Object.values(checks).every(v => v === 'ok');
  return NextResponse.json(
    { status: allOk ? 'healthy' : 'degraded', checks },
    { status: allOk ? 200 : 503 }
  );
}
```

## 監視ダッシュボード確認

デプロイ後に以下のダッシュボードを確認:

1. **Vercel Analytics**: リアルタイムトラフィック・Web Vitals
2. **Sentry**: エラー率・新規エラーの発生
3. **Supabase Dashboard**: DB接続数・クエリ性能
4. **Vercel Logs**: サーバーサイドエラーログ

### 確認タイミング

| タイミング | 確認項目 |
|-----------|---------|
| デプロイ直後 | ヘルスチェック、スモークテスト |
| 5分後 | Sentry エラー率、Vercel ログ |
| 30分後 | Analytics トラフィック正常性 |
| 2時間後 | Web Vitals 劣化なし |
| 24時間後 | 全体的な安定性確認 |
