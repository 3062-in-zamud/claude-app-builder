# セキュリティヘッダー設定テンプレート

## Next.js での設定方法

### 方法1: next.config.js（推奨）

```javascript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self'",
              "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://va.vercel-scripts.com",
              "style-src 'self' 'unsafe-inline'",
              "img-src 'self' data: https:",
              "font-src 'self'",
              "connect-src 'self' https://*.supabase.co https://*.sentry.io wss://*.supabase.co",
              "frame-ancestors 'none'",
              "base-uri 'self'",
              "form-action 'self'",
            ].join('; '),
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=(), browsing-topics=()',
          },
        ],
      },
    ]
  },
}

module.exports = nextConfig
```

### 方法2: middleware.ts（動的制御が必要な場合）

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  // CSP（ノンスを使う場合）
  const nonce = Buffer.from(crypto.randomUUID()).toString('base64')
  const csp = [
    `default-src 'self'`,
    `script-src 'self' 'nonce-${nonce}' https://va.vercel-scripts.com`,
    `style-src 'self' 'unsafe-inline'`,
    `img-src 'self' data: https:`,
    `font-src 'self'`,
    `connect-src 'self' https://*.supabase.co https://*.sentry.io wss://*.supabase.co`,
    `frame-ancestors 'none'`,
    `base-uri 'self'`,
    `form-action 'self'`,
  ].join('; ')

  response.headers.set('Content-Security-Policy', csp)
  response.headers.set('Strict-Transport-Security', 'max-age=63072000; includeSubDomains; preload')
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')
  response.headers.set('Permissions-Policy', 'camera=(), microphone=(), geolocation=(), browsing-topics=()')

  // ノンスをリクエストヘッダーに伝播（Script コンポーネント用）
  response.headers.set('x-nonce', nonce)

  return response
}
```

## 各ヘッダーの詳細

### 1. Content-Security-Policy (CSP)

XSS やデータインジェクション攻撃を防止する。

| ディレクティブ | 目的 | 推奨設定 |
|--------------|------|---------|
| `default-src` | フォールバック | `'self'` |
| `script-src` | JavaScript | `'self'` + 必要な外部スクリプト |
| `style-src` | CSS | `'self' 'unsafe-inline'`（Tailwind 用） |
| `img-src` | 画像 | `'self' data: https:` |
| `connect-src` | API/WebSocket | `'self'` + Supabase/Sentry |
| `frame-ancestors` | iframe 埋め込み制御 | `'none'` |
| `base-uri` | `<base>` タグ制御 | `'self'` |
| `form-action` | フォーム送信先 | `'self'` |

**CSP レベル分け**:
- **開発時**: `'unsafe-inline' 'unsafe-eval'` を許可（HMR用）
- **本番**: nonce ベースに移行し `'unsafe-inline'` を除去

### 2. Strict-Transport-Security (HSTS)

HTTPS 接続を強制する。

```
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

| パラメータ | 値 | 説明 |
|-----------|-----|------|
| `max-age` | 63072000 (2年) | ブラウザがHTTPS接続を記憶する期間 |
| `includeSubDomains` | - | サブドメインにも適用 |
| `preload` | - | ブラウザのプリロードリストに登録申請可能 |

### 3. X-Frame-Options

クリックジャッキング攻撃を防止。

```
X-Frame-Options: DENY
```

| 値 | 動作 |
|-----|------|
| `DENY` | iframe 埋め込み完全禁止（推奨） |
| `SAMEORIGIN` | 同一オリジンからのみ許可 |

### 4. X-Content-Type-Options

MIME タイプスニッフィングを防止。

```
X-Content-Type-Options: nosniff
```

ブラウザが Content-Type を無視してファイルの中身から型を推測する動作を防ぐ。

### 5. Referrer-Policy

リファラー情報の送信を制御。

```
Referrer-Policy: strict-origin-when-cross-origin
```

| 値 | 動作 |
|-----|------|
| `no-referrer` | リファラーを一切送らない |
| `strict-origin-when-cross-origin` | 同一オリジン: フルURL / クロスオリジン: オリジンのみ（推奨） |
| `same-origin` | 同一オリジンのみリファラー送信 |

### 6. Permissions-Policy

ブラウザ機能へのアクセスを制御。

```
Permissions-Policy: camera=(), microphone=(), geolocation=(), browsing-topics=()
```

使わない機能は明示的に無効化する。

| 機能 | 設定 | 説明 |
|------|------|------|
| `camera` | `()` | カメラ無効 |
| `microphone` | `()` | マイク無効 |
| `geolocation` | `()` | 位置情報無効 |
| `browsing-topics` | `()` | Topics API 無効（トラッキング防止） |
| `payment` | `(self)` | 決済機能を使う場合は self 許可 |

## 検証方法

```bash
# ローカルで確認
curl -I http://localhost:3000 2>/dev/null | grep -iE "content-security|strict-transport|x-frame|x-content-type|referrer-policy|permissions-policy"

# 本番で確認
curl -I https://your-domain.com 2>/dev/null | grep -iE "content-security|strict-transport|x-frame|x-content-type|referrer-policy|permissions-policy"

# SecurityHeaders.com でスキャン（A+ を目指す）
# https://securityheaders.com/?q=your-domain.com
```

## チェックリスト

- [ ] CSP が設定され、不要な `unsafe-*` がないか
- [ ] HSTS が `includeSubDomains` 付きで設定されているか
- [ ] X-Frame-Options が `DENY` に設定されているか
- [ ] X-Content-Type-Options が `nosniff` に設定されているか
- [ ] Referrer-Policy が適切に設定されているか
- [ ] Permissions-Policy で不要な機能が無効化されているか
- [ ] SecurityHeaders.com で A+ 評価を取得しているか
