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

### Step 3: Lighthouse CI 設定

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
