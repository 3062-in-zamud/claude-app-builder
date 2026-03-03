---
name: monitoring-setup
description: |
  What: Sentry・Vercel Analytics・Lighthouse CI を設定する
  When: Phase 6（release-checklist の前）
  How: 各サービスの SDK をインストール・設定ファイルを生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Bash
---

# monitoring-setup: 監視設定

## ワークフロー

### Step 1: Sentry 設定（エラートラッキング）

```bash
# Sentry インストール
npx @sentry/wizard@latest -i nextjs

# または手動インストール
npm install @sentry/nextjs
```

#### `sentry.client.config.ts`

```typescript
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  // 個人情報を含む可能性のあるデータはスクラブ
  beforeSend(event) {
    if (event.request?.cookies) {
      event.request.cookies = '[Scrubbed]'
    }
    return event
  },
})
```

#### `sentry.server.config.ts`

```typescript
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
})
```

### Step 2: Vercel Analytics 設定

```bash
npm install @vercel/analytics @vercel/speed-insights
```

#### `app/layout.tsx` への追加

```typescript
import { Analytics } from '@vercel/analytics/react'
import { SpeedInsights } from '@vercel/speed-insights/next'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  )
}
```

### Google Analytics 4（オプション）

Vercel Analytics との使い分け:
- **Vercel Analytics**: ページビュー・Core Web Vitals（プロジェクト固有）
- **Google Analytics 4**: より詳細なユーザー行動・カスタムイベント・クロスドメイン追跡

GA4の基本設定:

1. [Google Analytics](https://analytics.google.com) でプロパティ作成
2. 測定ID（G-XXXXXXXXXX）を取得
3. 環境変数に追加:
   ```
   NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
   ```
4. `src/app/layout.tsx` にスクリプト追加:
   ```typescript
   // Google Analytics
   {process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID && (
     <>
       <Script
         src={`https://www.googletagmanager.com/gtag/js?id=${process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID}`}
         strategy="afterInteractive"
       />
       <Script id="google-analytics" strategy="afterInteractive">
         {`
           window.dataLayer = window.dataLayer || [];
           function gtag(){dataLayer.push(arguments);}
           gtag('js', new Date());
           gtag('config', '${process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID}');
         `}
       </Script>
     </>
   )}
   ```

### Step 3: SLO/SLI/Error Budget 定義

サービスレベル目標を設定（詳細は `references/slo-sli-error-budget.md`）:

| SLI (指標) | SLO (目標) | Error Budget (月間) |
|------------|-----------|-------------------|
| 可用性 (成功リクエスト率) | 99.9% | 43.8分のダウンタイム |
| レイテンシ (p99) | < 500ms | 0.1% のリクエストが超過可能 |
| エラーレート | < 0.1% | 月間リクエスト数の0.1% |

**Error Budget ポリシー**:
- Budget 残 > 50%: 通常開発（機能追加優先）
- Budget 残 25-50%: 信頼性改善を並行実施
- Budget 残 < 25%: 機能追加を凍結、信頼性改善に集中
- Budget 消費: デプロイ頻度を下げ、ロールバック基準を厳格化

### Step 4: アラート設計（P0-P3 4段階）

詳細は `references/alert-design-guide.md`:

| 優先度 | 対応時間 | 条件例 | 通知先 |
|--------|---------|--------|--------|
| **P0 Critical** | 即時（5分以内） | サービス全面停止・データ漏洩 | PagerDuty + Slack + 電話 |
| **P1 High** | 1時間以内 | 主要機能障害・エラー率5%超 | Slack + メール |
| **P2 Medium** | 4時間以内 | パフォーマンス劣化・部分障害 | Slack |
| **P3 Low** | 翌営業日 | 軽微な問題・閾値接近 | メール（日次ダイジェスト） |

**Sentry アラート設定例**:
```typescript
// sentry.server.config.ts に追加
Sentry.init({
  // ... 既存設定
  // P0: 1分間に50件以上のエラー
  // P1: 1分間に10件以上のエラー
  // P2: 1時間に50件以上のエラー
  // → Sentry Dashboard > Alerts で設定
})
```

### Step 5: 4 Golden Signals ダッシュボード

Vercel Analytics + Sentry で以下を監視:

| Signal | 計測方法 | 閾値 |
|--------|---------|------|
| **Latency** | Vercel Speed Insights (p50/p95/p99) | p99 < 500ms |
| **Traffic** | Vercel Analytics (リクエスト数/分) | ベースラインの200%超でアラート |
| **Errors** | Sentry エラーレート | > 0.1% でアラート |
| **Saturation** | Vercel Functions 実行時間・メモリ | 80%超でアラート |

### Step 6: 構造化ログ設計

```typescript
// src/lib/logger.ts
type LogLevel = 'debug' | 'info' | 'warn' | 'error'

interface StructuredLog {
  level: LogLevel
  message: string
  timestamp: string
  correlationId: string  // リクエスト横断の追跡ID
  requestId: string      // 個別リクエストID
  service: string
  [key: string]: unknown
}

export function createLogger(service: string) {
  return {
    info: (message: string, meta?: Record<string, unknown>) =>
      console.log(JSON.stringify({
        level: 'info',
        message,
        timestamp: new Date().toISOString(),
        service,
        ...meta,
      })),
    error: (message: string, error?: Error, meta?: Record<string, unknown>) =>
      console.error(JSON.stringify({
        level: 'error',
        message,
        timestamp: new Date().toISOString(),
        service,
        error: error ? { name: error.name, message: error.message, stack: error.stack } : undefined,
        ...meta,
      })),
  }
}
```

**Correlation ID の伝播**:
```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server'
import { randomUUID } from 'crypto'

export function middleware(request: NextRequest) {
  const correlationId = request.headers.get('x-correlation-id') || randomUUID()
  const requestId = randomUUID()

  const response = NextResponse.next()
  response.headers.set('x-correlation-id', correlationId)
  response.headers.set('x-request-id', requestId)
  return response
}
```

### Step 7: Lighthouse CI 設定

```bash
npm install -D @lhci/cli
```

#### `.lighthouserc.js`

```javascript
module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3000', 'http://localhost:3000/'],
      startServerCommand: 'npm start',
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],      // 90+
        'categories:accessibility': ['error', { minScore: 0.95 }],  // 95+
        'categories:best-practices': ['error', { minScore: 0.9 }],  // 90+
        'categories:seo': ['error', { minScore: 0.9 }],              // 90+
        // Core Web Vitals
        'first-contentful-paint': ['error', { maxNumericValue: 2000 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['error', { maxNumericValue: 300 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',  // CI で結果を共有
    },
  },
}
```

#### GitHub Actions に追加（`.github/workflows/lighthouse.yml`）

```yaml
name: Lighthouse CI

on:
  pull_request:
    branches: [main]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - run: npx lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

### 出力ファイル

- `sentry.client.config.ts`
- `sentry.server.config.ts`
- `.lighthouserc.js`
- `.github/workflows/lighthouse.yml`

### 品質チェック

- [ ] Sentry DSN が環境変数で設定されているか
- [ ] Vercel Analytics が `app/layout.tsx` に追加されているか
- [ ] Lighthouse 閾値が Performance 90+, Accessibility 95+ か
- [ ] Core Web Vitals が設定されているか
- [ ] GitHub Dependabot が有効か
- [ ] SLO/SLI が定義され `docs/slo.md` に記載されているか
- [ ] P0-P3 アラートルールが Sentry に設定されているか
- [ ] 4 Golden Signals のダッシュボードが構成されているか
- [ ] 構造化ログ（JSON + Correlation ID）が実装されているか
- [ ] Error Budget ポリシーが定義されているか
