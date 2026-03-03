---
name: payment-integration
description: |
  What: Stripe決済統合 - Checkout・Webhook・サブスクリプション管理の実装（Phase 9.5）
  When: pricing-strategy完了後、growth-engine の Stage D で実行
  How: pricing-strategy.md を基に Stripe Checkout + Webhook + Supabase サブスク状態管理を実装
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# payment-integration: Stripe決済統合

## 概要

pricing-strategy で設計した価格プランを Stripe で実装します。
Checkout Session、Webhook 処理、Customer Portal、トライアル、Dunning（課金失敗リトライ）を
一貫して設定し、Supabase でサブスクリプション状態を管理します。

## ワークフロー

### Step 1: インプット読み込み

- `docs/pricing-strategy.md` - プラン設計・価格・機能分割マトリクス
- `docs/requirements.md` - 技術スタック確認
- `docs/tech-stack.md`（存在する場合）- フレームワーク確認

### Step 2: Stripe Checkout 統合

```bash
npm install stripe @stripe/stripe-js
```

#### `src/lib/stripe.ts` - Stripe クライアント初期化

```typescript
import Stripe from 'stripe'

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
  typescript: true,
})
```

#### `src/app/api/checkout/route.ts` - Checkout Session 作成

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { stripe } from '@/lib/stripe'
import { createClient } from '@/lib/supabase/server'

export async function POST(req: NextRequest) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { priceId } = await req.json()

  const session = await stripe.checkout.sessions.create({
    customer_email: user.email,
    metadata: { userId: user.id },
    line_items: [{ price: priceId, quantity: 1 }],
    mode: 'subscription',
    subscription_data: {
      trial_period_days: 14,
      metadata: { userId: user.id },
    },
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?checkout=success`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing?checkout=cancelled`,
    allow_promotion_codes: true,
  })

  return NextResponse.json({ url: session.url })
}
```

### Step 3: Stripe Webhook 処理

#### `src/app/api/webhooks/stripe/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { stripe } from '@/lib/stripe'
import { createClient } from '@supabase/supabase-js'
import Stripe from 'stripe'

// Webhook は Supabase Admin Client を使用（RLS バイパス）
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
)

export async function POST(req: NextRequest) {
  const body = await req.text()
  const signature = req.headers.get('stripe-signature')!

  let event: Stripe.Event

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!,
    )
  } catch (err) {
    console.error('Webhook signature verification failed:', err)
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 })
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object as Stripe.Checkout.Session)
        break
      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object as Stripe.Subscription)
        break
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object as Stripe.Subscription)
        break
      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object as Stripe.Invoice)
        break
    }
  } catch (err) {
    console.error(`Error processing ${event.type}:`, err)
    return NextResponse.json({ error: 'Webhook handler failed' }, { status: 500 })
  }

  return NextResponse.json({ received: true })
}

async function handleCheckoutCompleted(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.userId
  if (!userId) return

  const subscription = await stripe.subscriptions.retrieve(session.subscription as string)

  await supabaseAdmin.from('subscriptions').upsert({
    user_id: userId,
    stripe_customer_id: session.customer as string,
    stripe_subscription_id: subscription.id,
    status: subscription.status,
    price_id: subscription.items.data[0].price.id,
    current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
    current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
    trial_end: subscription.trial_end
      ? new Date(subscription.trial_end * 1000).toISOString()
      : null,
    cancel_at: null,
    cancelled_at: null,
  }, { onConflict: 'user_id' })
}

async function handleSubscriptionUpdated(subscription: Stripe.Subscription) {
  const userId = subscription.metadata?.userId
  if (!userId) return

  await supabaseAdmin.from('subscriptions').update({
    status: subscription.status,
    price_id: subscription.items.data[0].price.id,
    current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
    current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
    cancel_at: subscription.cancel_at
      ? new Date(subscription.cancel_at * 1000).toISOString()
      : null,
    cancelled_at: subscription.canceled_at
      ? new Date(subscription.canceled_at * 1000).toISOString()
      : null,
  }).eq('user_id', userId)
}

async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  const userId = subscription.metadata?.userId
  if (!userId) return

  await supabaseAdmin.from('subscriptions').update({
    status: 'canceled',
    cancelled_at: new Date().toISOString(),
  }).eq('user_id', userId)
}

async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const subscriptionId = invoice.subscription as string
  if (!subscriptionId) return

  await supabaseAdmin.from('subscriptions').update({
    status: 'past_due',
  }).eq('stripe_subscription_id', subscriptionId)
}
```

### Step 4: Supabase サブスクリプション状態管理

#### `supabase/migrations/YYYYMMDD_create_subscriptions.sql`

```sql
-- サブスクリプション状態管理テーブル
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT UNIQUE,
  status TEXT NOT NULL DEFAULT 'free'
    CHECK (status IN ('free', 'trialing', 'active', 'past_due', 'canceled', 'incomplete')),
  price_id TEXT,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  trial_end TIMESTAMPTZ,
  cancel_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

-- RLS 有効化
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分のサブスクリプションのみ参照可能
CREATE POLICY "Users can view own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- サービスロールのみ更新可能（Webhook経由）
CREATE POLICY "Service role can manage subscriptions"
  ON subscriptions FOR ALL
  USING (auth.role() = 'service_role');

-- updated_at 自動更新トリガー
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

### Step 5: Customer Portal 統合

#### `src/app/api/billing/portal/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { stripe } from '@/lib/stripe'
import { createClient } from '@/lib/supabase/server'

export async function POST(req: NextRequest) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { data: subscription } = await supabase
    .from('subscriptions')
    .select('stripe_customer_id')
    .eq('user_id', user.id)
    .single()

  if (!subscription?.stripe_customer_id) {
    return NextResponse.json({ error: 'No subscription found' }, { status: 404 })
  }

  const session = await stripe.billingPortal.sessions.create({
    customer: subscription.stripe_customer_id,
    return_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/settings`,
  })

  return NextResponse.json({ url: session.url })
}
```

### Step 6: トライアル14日設定

Checkout Session 作成時に `trial_period_days: 14` を設定（Step 2 に含む）。

追加で `src/lib/subscription.ts` にヘルパー関数を生成:

```typescript
import { createClient } from '@/lib/supabase/server'

export type PlanType = 'free' | 'pro' | 'team'

export async function getUserPlan(): Promise<PlanType> {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) return 'free'

  const { data: subscription } = await supabase
    .from('subscriptions')
    .select('status, price_id, trial_end')
    .eq('user_id', user.id)
    .single()

  if (!subscription) return 'free'

  const isActive = ['active', 'trialing'].includes(subscription.status)
  if (!isActive) return 'free'

  // price_id からプランを判定（pricing-strategy.md の設定に合わせて調整）
  const proPriceIds = [
    process.env.STRIPE_PRO_MONTHLY_PRICE_ID,
    process.env.STRIPE_PRO_YEARLY_PRICE_ID,
  ]
  const teamPriceIds = [
    process.env.STRIPE_TEAM_MONTHLY_PRICE_ID,
    process.env.STRIPE_TEAM_YEARLY_PRICE_ID,
  ]

  if (teamPriceIds.includes(subscription.price_id ?? '')) return 'team'
  if (proPriceIds.includes(subscription.price_id ?? '')) return 'pro'

  return 'free'
}

export async function isTrialing(): Promise<boolean> {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) return false

  const { data: subscription } = await supabase
    .from('subscriptions')
    .select('status, trial_end')
    .eq('user_id', user.id)
    .single()

  return subscription?.status === 'trialing'
}
```

### Step 7: 課金失敗リトライ（Dunning）設定

Stripe Dashboard での設定ガイドを含む:

```markdown
## Dunning（課金失敗リトライ）設定ガイド

### Stripe Dashboard 設定
1. Stripe Dashboard → Settings → Billing → Subscriptions and emails
2. Manage failed payments:
   - Smart Retries: ON（Stripe の機械学習によるリトライ最適化）
   - Retry schedule: 3回（1日後、3日後、5日後）
   - After all retries fail: Cancel subscription

### メール通知設定
1. Payment failed → 即時通知
2. Upcoming renewal → 3日前通知
3. Subscription canceled → 即時通知

### アプリ内対応
- `past_due` 状態のユーザーにバナー表示
- 支払い方法更新への導線を設置
```

### Step 8: テスト用 Stripe キー設定ガイド

```markdown
## テスト環境セットアップ

### 1. Stripe テストキーの取得
1. [Stripe Dashboard](https://dashboard.stripe.com) にログイン
2. テストモードを ON にする（右上のトグル）
3. Developers → API keys からキーをコピー

### 2. 環境変数設定（.env.local）
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRO_MONTHLY_PRICE_ID=price_...
STRIPE_PRO_YEARLY_PRICE_ID=price_...
STRIPE_TEAM_MONTHLY_PRICE_ID=price_...
STRIPE_TEAM_YEARLY_PRICE_ID=price_...

### 3. Stripe CLI で Webhook テスト
stripe listen --forward-to localhost:3000/api/webhooks/stripe
# 出力される whsec_... を STRIPE_WEBHOOK_SECRET に設定

### 4. テスト用カード番号
- 成功: 4242 4242 4242 4242
- 失敗: 4000 0000 0000 0002
- 3Dセキュア: 4000 0025 0000 3155
```

## 出力ファイル

- `src/lib/stripe.ts` - Stripe クライアント初期化
- `src/lib/subscription.ts` - サブスクリプションヘルパー
- `src/app/api/checkout/route.ts` - Checkout Session API
- `src/app/api/webhooks/stripe/route.ts` - Webhook ハンドラー
- `src/app/api/billing/portal/route.ts` - Customer Portal API
- `supabase/migrations/YYYYMMDD_create_subscriptions.sql` - DB マイグレーション
- `docs/payment-integration.md` - 設定ガイド（Dunning + テスト手順）

## 品質チェック

- [ ] Webhook 署名検証が実装されているか（`stripe.webhooks.constructEvent`）
- [ ] Webhook ハンドラーがべき等（idempotent）か（upsert 使用）
- [ ] サブスクリプション状態が Supabase と Stripe で同期されているか
- [ ] RLS ポリシーが設定されているか（ユーザーは自分のサブスクのみ参照可能）
- [ ] Customer Portal でプラン変更・キャンセル・請求書確認が可能か
- [ ] トライアル期間が設定されているか
- [ ] テスト用 Stripe キーの設定ガイドが含まれているか
- [ ] 課金失敗時のリトライ設定ガイドが含まれているか
- [ ] 環境変数にシークレットキーがハードコードされていないか
