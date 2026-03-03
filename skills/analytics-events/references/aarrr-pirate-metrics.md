# AARRR Pirate Metrics イベント定義テンプレート

## AARRR フレームワークとは

Dave McClure が提唱したスタートアップメトリクスフレームワーク。
ユーザーのライフサイクルを5段階に分け、各段階で計測すべき指標を定義する。

```
Acquisition → Activation → Retention → Revenue → Referral
  獲得          活性化       継続利用     収益化      紹介
```

## 1. Acquisition（獲得）

**目的**: ユーザーがどこから来て、サービスを知ったかを計測

### イベント定義

```typescript
// Acquisition イベント
const AcquisitionEvents = {
  // ページビュー（流入元トラッキング）
  pageViewed: (page: string, utm?: UTMParams) =>
    track('page_viewed', {
      page,
      utm_source: utm?.source ?? 'direct',
      utm_medium: utm?.medium ?? 'none',
      utm_campaign: utm?.campaign ?? 'none',
      referrer: document.referrer || 'direct',
    }),

  // LP CTA クリック
  ctaClicked: (ctaId: string, ctaText: string) =>
    track('cta_clicked', { cta_id: ctaId, cta_text: ctaText }),

  // 登録フォーム表示
  signupFormViewed: () =>
    track('signup_form_viewed', {}),
}

// UTM パラメータ型
interface UTMParams {
  source: string    // utm_source: google, twitter, email
  medium: string    // utm_medium: cpc, social, newsletter
  campaign: string  // utm_campaign: spring2024, launch
}
```

### 計測ダッシュボード項目

| 指標 | 計算式 | 目標 |
|------|--------|------|
| 流入数 | `page_viewed` count | - |
| チャネル別流入 | `page_viewed` GROUP BY utm_source | - |
| LP → 登録フォーム率 | `signup_form_viewed` / `page_viewed` | > 30% |
| CTA クリック率 | `cta_clicked` / `page_viewed` | > 5% |

## 2. Activation（活性化）

**目的**: 初回体験で「価値を感じた瞬間」（Aha Moment）を計測

### イベント定義

```typescript
const ActivationEvents = {
  // 登録開始
  signUpStarted: (source: string) =>
    track('sign_up_started', { source }),

  // 登録完了
  signUpCompleted: (method: 'email' | 'google' | 'github') =>
    track('sign_up_completed', {
      method,
      signup_date: new Date().toISOString().split('T')[0],
    }),

  // オンボーディング各ステップ
  onboardingStepCompleted: (step: number, totalSteps: number) =>
    track('onboarding_step_completed', {
      step,
      total_steps: totalSteps,
      completion_rate: step / totalSteps,
    }),

  // オンボーディング完了
  onboardingCompleted: (daysToComplete: number) =>
    track('onboarding_completed', {
      days_to_complete: daysToComplete,
    }),

  // Aha Moment（サービス固有の「価値を感じた瞬間」）
  firstValueMoment: (action: string) =>
    track('first_value_moment', {
      action,  // 例: 'first_post_created', 'first_analysis_run'
    }),
}
```

### Aha Moment の特定方法

```
1. リテンション率が高いユーザーの共通行動を分析
2. 「X日以内にYを行ったユーザー」のリテンションを比較
3. 最もリテンションに相関する行動 = Aha Moment

例:
- Slack: 「2000メッセージを送信したチーム」が定着
- Dropbox: 「1ファイルをアップロード」で価値を実感
- Twitter: 「30人フォロー」で情報フィードの価値を実感
```

### 計測ダッシュボード項目

| 指標 | 計算式 | 目標 |
|------|--------|------|
| 登録コンバージョン率 | `sign_up_completed` / `signup_form_viewed` | > 50% |
| オンボーディング完了率 | `onboarding_completed` / `sign_up_completed` | > 60% |
| Aha Moment 到達率 | `first_value_moment` / `sign_up_completed` | > 40% |
| 登録→活性化期間 | AVG(days_to_complete) | < 1日 |

## 3. Retention（継続利用）

**目的**: ユーザーが継続的にサービスを利用しているか計測

### イベント定義

```typescript
const RetentionEvents = {
  // セッション開始
  sessionStarted: (daysSinceSignup: number) =>
    track('session_started', {
      days_since_signup: daysSinceSignup,
      is_return_visit: daysSinceSignup > 0,
    }),

  // 機能利用
  featureUsed: (featureName: string, metadata?: Record<string, unknown>) =>
    track('feature_used', {
      feature_name: featureName,
      ...metadata,
    }),

  // 再訪問（2回目以降）
  returnVisit: (daysSinceSignup: number, visitCount: number) =>
    track('return_visit', {
      days_since_signup: daysSinceSignup,
      visit_count: visitCount,
    }),
}
```

### リテンションコホート分析

```
         Day 0  Day 1  Day 7  Day 14  Day 30
Week 1:  100%   45%    30%    25%     20%
Week 2:  100%   48%    32%    27%     22%
Week 3:  100%   50%    35%    28%     24%
```

### 計測ダッシュボード項目

| 指標 | 計算式 | 目標 |
|------|--------|------|
| DAU/MAU 比率 | ユニーク日次ユーザー / 月次ユーザー | > 20% |
| Day 1 リテンション | Day 1 にアクティブ / 登録数 | > 40% |
| Day 7 リテンション | Day 7 にアクティブ / 登録数 | > 25% |
| Day 30 リテンション | Day 30 にアクティブ / 登録数 | > 15% |

## 4. Revenue（収益化）

**目的**: 無料→有料への転換と収益の計測

### イベント定義

```typescript
const RevenueEvents = {
  // アップグレードページ表示
  pricingViewed: (source: string) =>
    track('pricing_viewed', { source }),

  // アップグレードボタンクリック
  upgradeClicked: (plan: string, trigger: string) =>
    track('upgrade_clicked', { plan, trigger }),

  // 購入完了
  purchaseCompleted: (plan: string, amount: number, currency: string) =>
    track('purchase_completed', {
      plan,
      amount,
      currency,
      is_first_purchase: true, // 初回購入フラグ
    }),

  // サブスクリプション開始
  subscriptionStarted: (plan: string, interval: 'monthly' | 'yearly') =>
    track('subscription_started', { plan, interval }),

  // サブスクリプション解約
  subscriptionCancelled: (plan: string, reason: string, monthsActive: number) =>
    track('subscription_cancelled', {
      plan,
      reason,
      months_active: monthsActive,
    }),
}
```

### 計測ダッシュボード項目

| 指標 | 計算式 | 目標 |
|------|--------|------|
| 無料→有料転換率 | `purchase_completed` / `sign_up_completed` | > 3% |
| 月間解約率 (Churn) | 解約数 / 月初有料ユーザー数 | < 5% |
| ARPU | 月間売上 / 有料ユーザー数 | - |
| LTV | ARPU / 月間解約率 | - |

## 5. Referral（紹介）

**目的**: ユーザーが他者にサービスを紹介しているか計測

### イベント定義

```typescript
const ReferralEvents = {
  // シェアボタンクリック
  shareClicked: (platform: string, contentType: string) =>
    track('share_clicked', { platform, content_type: contentType }),

  // 招待送信
  inviteSent: (method: 'email' | 'link' | 'social', count: number) =>
    track('invite_sent', { method, invite_count: count }),

  // 招待経由の登録完了
  referralCompleted: (referrerId: string) =>
    track('referral_completed', { referrer_id: referrerId }),
}
```

### 計測ダッシュボード項目

| 指標 | 計算式 | 目標 |
|------|--------|------|
| NPS (Net Promoter Score) | Promoters% - Detractors% | > 50 |
| バイラル係数 | 招待経由の登録数 / 招待送信ユーザー数 | > 1.0 |
| シェア率 | `share_clicked` / DAU | > 10% |

## ファネル分析用イベント一覧

```
page_viewed              ─┐
  cta_clicked             │ Acquisition
  signup_form_viewed     ─┘
  sign_up_started        ─┐
  sign_up_completed       │ Activation
  onboarding_completed    │
  first_value_moment     ─┘
  session_started        ─┐
  feature_used            │ Retention
  return_visit           ─┘
  pricing_viewed         ─┐
  upgrade_clicked         │ Revenue
  purchase_completed     ─┘
  share_clicked          ─┐
  invite_sent             │ Referral
  referral_completed     ─┘
```

## 実装チェックリスト

- [ ] 各 AARRR ステージに少なくとも2つのイベントが定義されている
- [ ] Aha Moment が特定・計測されている
- [ ] コホート分析用のプロパティ（signup_date, days_since_signup）が含まれている
- [ ] ファネルの各段階でコンバージョン率が計測可能
- [ ] 解約理由が構造化データとして収集されている
