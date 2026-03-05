---
name: analytics-events
description: |
  What: 成功指標から計測イベントを逆算し、provider別（Vercel / Cloudflare）イベント計測を実装する
  When: Phase 5（implementation完了後）または独立呼び出し
  How: KPI抽出 → イベント設計 → analytics adapter生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
---

# analytics-events: 計測イベント設計・実装

## 概要

「計測できないものは改善できない」。
成功指標から逆算し、`deployment_provider` に依存しない計測APIを生成する。

## Step 0: tech-stack 契約確認

- `docs/tech-stack.md` から `deployment_provider` を取得
- 未定義なら失敗（デフォルト禁止）

## Step 1: 成功指標の確認

`docs/requirements.md` から以下を抽出:
- KPI
- 成功条件
- MVP機能（P0）

## Step 2: AARRRイベント設計

| ステージ | 主要イベント |
|---------|-------------|
| Acquisition | `page_viewed`, `utm_tracked` |
| Activation | `sign_up_completed`, `first_value_moment` |
| Retention | `return_visit`, `feature_used` |
| Revenue | `upgrade_clicked`, `purchase_completed` |
| Referral | `share_clicked`, `invite_sent` |

## Step 3: Provider非依存 adapter 実装

`src/lib/analytics.ts` を生成:

```typescript
type AnalyticsProvider = 'vercel' | 'cloudflare-pages'
type EventProps = Record<string, string | number | boolean>

const provider = process.env.NEXT_PUBLIC_DEPLOYMENT_PROVIDER as AnalyticsProvider

function trackWithVercel(event: string, props?: EventProps) {
  // dynamic import で provider依存を隔離
  import('@vercel/analytics').then(({ track }) => track(event, props)).catch(() => {
    console.warn('[analytics] vercel track failed', event)
  })
}

function trackWithCloudflare(event: string, props?: EventProps) {
  // Cloudflareでは Web Analytics + 任意の custom endpoint を利用
  fetch('/api/analytics', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ event, props }),
    keepalive: true,
  }).catch(() => {
    console.warn('[analytics] cloudflare track failed', event)
  })
}

export function trackEvent(event: string, props?: EventProps) {
  if (process.env.NODE_ENV === 'development') {
    console.log('[analytics]', event, props)
    return
  }

  if (provider === 'vercel') {
    trackWithVercel(event, props)
  } else if (provider === 'cloudflare-pages') {
    trackWithCloudflare(event, props)
  }
}
```

## Step 4: 型付きイベントヘルパー生成

```typescript
export const Analytics = {
  signUpCompleted: (method: 'email' | 'google' | 'github') =>
    trackEvent('sign_up_completed', { method }),
  onboardingCompleted: (daysToComplete: number) =>
    trackEvent('onboarding_completed', { days_to_complete: daysToComplete }),
  featureUsed: (featureName: string) =>
    trackEvent('feature_used', { feature_name: featureName }),
  returnVisit: (daysSinceSignup: number) =>
    trackEvent('return_visit', { days_since_signup: daysSinceSignup }),
  upgradeClicked: (plan: string) =>
    trackEvent('upgrade_clicked', { plan }),
} as const
```

## Step 5: プライバシー保護

- 同意前トラッキング禁止
- `analytics` レベル同意では PII 除外
- 同意撤回時は即停止

## Step 6: ダッシュボード運用

- `vercel`: Vercel Analytics + Sentry
- `cloudflare-pages`: Cloudflare Web Analytics + Sentry + `/api/analytics` 集計

## 出力

- `src/lib/analytics.ts`
- `docs/analytics-plan.md`

## 完了条件

- [ ] `deployment_provider` を参照して分岐している
- [ ] provider非依存の `trackEvent` API がある
- [ ] 同意状態とPII除外を実装
- [ ] P0機能に対応した型付きイベントがある
