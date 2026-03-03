---
name: analytics-events
description: |
  What: 成功指標から計測イベントを逆算し、Vercel Analytics カスタムイベントとして実装する
  When: Phase 5（implementation完了後）または独立して呼び出し可能
  How: requirements.md の成功指標 → イベント設計 → analytics.ts 生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
---

# analytics-events: 計測イベント設計・実装

## 概要

「計測できないものは改善できない」。成功指標から逆算して計測すべきイベントを設計し、
Vercel Analytics カスタムイベントとして実装します。

## ワークフロー

### Step 1: 成功指標の確認

`docs/requirements.md` を読み込み、以下を抽出:
- KPI（Key Performance Indicators）
- 成功の定義（3ヶ月後にどうなっていれば成功か）
- MVP機能（P0）

### Step 2: AARRR Pirate Metrics 対応イベント設計

成功指標を AARRR フレームワークで整理し、各ステージのイベントを定義（詳細は `references/aarrr-pirate-metrics.md`）:

| ステージ | 意味 | 主要イベント |
|---------|------|------------|
| **Acquisition** | ユーザー獲得 | `page_viewed`, `utm_tracked`, `referral_landed` |
| **Activation** | 初期体験 | `sign_up_completed`, `onboarding_completed`, `first_value_moment` |
| **Retention** | 継続利用 | `return_visit`, `session_started`, `feature_used` |
| **Revenue** | 収益化 | `upgrade_clicked`, `purchase_completed`, `subscription_started` |
| **Referral** | 紹介 | `share_clicked`, `invite_sent`, `referral_completed` |

### Step 2.5: イベントスキーマガバナンス

イベント命名規則とスキーマバージョニングを定義（詳細は `references/event-schema-governance.md`）:

**命名規則**:
- フォーマット: `{object}_{action}` (snake_case)
- 例: `sign_up_completed`, `post_created`, `upgrade_clicked`
- 禁止: camelCase、ハイフン区切り、動詞始まり

**スキーマバージョニング**:
```typescript
// イベントスキーマ型定義
interface EventSchema {
  schemaVersion: '1.0'
  event: string
  timestamp: string
  properties: Record<string, string | number | boolean>
}
```

### Step 2.6: コホート分析用イベント設計

リテンション分析に必要なコホート識別プロパティを付与:

```typescript
// コホート識別に必要なプロパティ
interface CohortProperties {
  signup_date: string      // YYYY-MM-DD（登録日コホート）
  signup_source: string    // 流入元コホート
  plan_type: string        // プラン別コホート
  first_feature: string    // 初回利用機能コホート
}
```

### Step 3: 計測イベントの詳細設計

成功指標から逆算して計測すべきイベントを定義:

```markdown
# Analytics イベント設計

## ビジネス指標 → 計測イベントのマッピング

| ビジネス指標 | 計測イベント | プロパティ |
|------------|------------|----------|
| ユーザー登録率 | `sign_up_completed` | method, source |
| 機能利用率 | `feature_used` | feature_name, user_id |
| リテンション | `session_started` | days_since_signup |
| コンバージョン | `upgrade_clicked` | plan, trigger |
| エンゲージメント | `content_created` | type, count |

## ファネル分析用イベント

1. `page_viewed` - ページビュー（LPからの離脱率）
2. `cta_clicked` - CTAボタンクリック（LP → 登録への転換）
3. `sign_up_started` - 登録開始
4. `sign_up_completed` - 登録完了（ファネルの底）
5. `onboarding_completed` - オンボーディング完了（初期体験）
6. `feature_used` - 主要機能の利用（エンゲージメント）
7. `return_visit` - 2回目以降の訪問（リテンション）
```

### Step 3: analytics.ts の実装

`src/lib/analytics.ts` を生成:

```typescript
/**
 * analytics.ts - Vercel Analytics カスタムイベント
 *
 * 使用方法:
 *   import { track } from '@/lib/analytics'
 *   track('sign_up_completed', { method: 'email' })
 */
import { track as vercelTrack } from '@vercel/analytics'

type EventProperties = Record<string, string | number | boolean>

/**
 * カスタムイベントを記録する
 * 開発環境ではコンソールに出力のみ（Vercel Analytics は本番のみ動作）
 */
export function track(event: string, properties?: EventProperties): void {
  if (process.env.NODE_ENV === 'development') {
    console.log('[Analytics]', event, properties)
    return
  }
  vercelTrack(event, properties)
}

// ===== 型付きイベントヘルパー =====
// （requirements.md の機能に合わせて生成）

export const Analytics = {
  // 認証イベント
  signUpStarted: (source: string) =>
    track('sign_up_started', { source }),

  signUpCompleted: (method: 'email' | 'google' | 'github') =>
    track('sign_up_completed', { method }),

  // オンボーディング
  onboardingCompleted: (daysToComplete: number) =>
    track('onboarding_completed', { days_to_complete: daysToComplete }),

  // 主要機能（requirements.md の P0 機能に合わせて追加）
  featureUsed: (featureName: string, metadata?: EventProperties) =>
    track('feature_used', { feature_name: featureName, ...metadata }),

  // エンゲージメント
  returnVisit: (daysSinceSignup: number) =>
    track('return_visit', { days_since_signup: daysSinceSignup }),

  // コンバージョン
  upgradeClicked: (plan: string, trigger: string) =>
    track('upgrade_clicked', { plan, trigger }),
} as const
```

### Step 3.5: プライバシーファースト計測

Cookie同意状態に応じて計測レベルを切り替える（`cookie-consent` スキルと連携）:

```typescript
// src/lib/analytics.ts に追加
type ConsentLevel = 'essential' | 'analytics' | 'marketing'

let currentConsent: ConsentLevel = 'essential'

export function setConsentLevel(level: ConsentLevel): void {
  currentConsent = level
}

export function track(event: string, properties?: EventProperties): void {
  // essential のみ同意: 計測しない
  if (currentConsent === 'essential') return

  // analytics 同意: 匿名化して計測
  if (currentConsent === 'analytics') {
    const anonymized = { ...properties }
    // PII を除外
    delete anonymized.email
    delete anonymized.name
    delete anonymized.user_id
    vercelTrack(event, anonymized)
    return
  }

  // marketing 同意: フル計測
  vercelTrack(event, properties)
}
```

**プライバシーチェックリスト**:
- [ ] Cookie同意バナーとの連携が実装されている
- [ ] 同意前にトラッキングが発火しない
- [ ] analytics レベルでは PII が除外される
- [ ] GDPR/個人情報保護法に準拠している

### Step 4: Vercel Analytics のセットアップ確認

```bash
# パッケージ確認
npm list @vercel/analytics 2>/dev/null || npm install @vercel/analytics
```

`src/app/layout.tsx` に Analytics コンポーネントを追加:

```typescript
import { Analytics } from '@vercel/analytics/react'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />  {/* ← 追加 */}
      </body>
    </html>
  )
}
```

### Step 5: analytics-plan.md の生成

`docs/analytics-plan.md` を生成:

```markdown
# Analytics 計測計画

## 計測の目的

[サービス名] の成功を以下の指標で計測します:

## KPI ダッシュボード（Vercel Analytics で確認）

| KPI | 計測方法 | 目標値 | 確認頻度 |
|-----|----------|--------|----------|
| 週次アクティブユーザー（WAU） | `session_started` イベント | [目標数] | 毎週月曜 |
| 機能利用率 | `feature_used` / ユーザー数 | 60%以上 | 週次 |
| 登録コンバージョン率 | `sign_up_completed` / `page_viewed` | 5%以上 | 週次 |
| 7日リテンション | `return_visit` (7日以内) | 20%以上 | 隔週 |

## イベント一覧

[Step 2 で設計したイベントの詳細を記載]

## 改善サイクル

1. **週次レビュー**: Vercel Analytics でファネルを確認
2. **仮説を立てる**: 離脱ポイントの原因を3つ仮説化
3. **A/Bテスト**: 最も影響が大きそうな変更を1つ実施
4. **2週間計測**: 十分なサンプルが集まるまで待つ
5. **判断**: 改善 → 次の仮説へ / 悪化 → ロールバック
```

### 出力ファイル

- `src/lib/analytics.ts` - カスタムイベント実装
- `docs/analytics-plan.md` - 計測計画書

## 完了条件

- [ ] `src/lib/analytics.ts` が生成されている
- [ ] `docs/analytics-plan.md` が生成されている
- [ ] `@vercel/analytics` がインストールされている
- [ ] `layout.tsx` に `<Analytics />` が追加されている
- [ ] requirements.md の P0 機能に対応するイベントが定義されている
- [ ] 型付きヘルパー関数でタイポを防げる構造になっているか

## 品質チェック

- [ ] ビジネス指標と計測イベントのマッピングが明確か
- [ ] 開発環境でのデバッグログが含まれているか
- [ ] イベントプロパティが過剰でないか（個人情報を含めない）
- [ ] ファネル分析に必要なイベントが網羅されているか
- [ ] AARRR 各ステージのイベントが定義されているか
- [ ] コホート分析用プロパティ（signup_date, signup_source）が含まれているか
- [ ] Cookie同意レベルに応じた計測制御が実装されているか
- [ ] イベント命名規則が `{object}_{action}` (snake_case) に統一されているか
- [ ] イベントスキーマバージョンが定義されているか
