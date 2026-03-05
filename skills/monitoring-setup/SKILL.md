---
name: monitoring-setup
description: |
  What: Sentry・provider別Analytics（Vercel / Cloudflare）・Lighthouse CI を設定する
  When: Phase 6（release-checklist の前）
  How: tech-stack契約を読み、共通監視 + provider別監視を設定する
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Bash
---

# monitoring-setup: 監視設定

## Step 0: tech-stack 契約を確認

```bash
extract_value() {
  local key="$1"
  grep -E "^[[:space:]-]*${key}:" docs/tech-stack.md 2>/dev/null | head -1 | sed -E "s/^[[:space:]-]*${key}:[[:space:]]*//" | tr -d '\r'
}

DEPLOYMENT_PROVIDER="$(extract_value deployment_provider)"
[ -n "$DEPLOYMENT_PROVIDER" ] || { echo "❌ deployment_provider が未定義です"; exit 1; }
```

## Step 1: 共通監視（Sentry）

```bash
npx @sentry/wizard@latest -i nextjs || npm install @sentry/nextjs
```

`dsn` と `environment` を設定し、PIIスクラブを有効化する。

## Step 2: provider別 Analytics

### `deployment_provider=vercel`

- `@vercel/analytics` と `@vercel/speed-insights` を導入
- `layout.tsx` に `<Analytics />`, `<SpeedInsights />` を追加

### `deployment_provider=cloudflare-pages`

- Cloudflare Web Analytics を設定
- 必要に応じて GA4/PostHog を併用
- `layout.tsx` へ Cloudflare Insights スクリプトを追加

## Step 3: SLO / SLI / Error Budget

- 可用性 99.9%
- p99 レイテンシ < 500ms
- エラー率 < 0.1%

Budget ポリシー:
- >50%: 通常開発
- 25-50%: 信頼性改善を並行
- <25%: 機能追加を凍結

## Step 4: アラート設計

- P0: 5分以内
- P1: 1時間以内
- P2: 4時間以内
- P3: 翌営業日

## Step 5: 4 Golden Signals

| Signal | Vercel | Cloudflare Pages | 閾値 |
|--------|--------|------------------|------|
| Latency | Vercel Speed Insights | Cloudflare Analytics + Sentry | p99 < 500ms |
| Traffic | Vercel Analytics | Cloudflare Web Analytics | baseline x2でアラート |
| Errors | Sentry | Sentry | >0.1% |
| Saturation | Vercel Functions | Cloudflare Functions | 80%超 |

## Step 6: Lighthouse CI

- `@lhci/cli` を導入
- Performance 90+, Accessibility 95+ を閾値化

## 出力

- `sentry.client.config.ts`
- `sentry.server.config.ts`
- `.lighthouserc.js`
- `.github/workflows/lighthouse.yml`

## 品質チェック

- [ ] `deployment_provider` が定義されている
- [ ] providerに応じた Analytics が設定されている
- [ ] Sentry DSN が環境変数経由
- [ ] Lighthouse 閾値を満たす
- [ ] SLO/SLI/Error Budget が docs に明記されている
