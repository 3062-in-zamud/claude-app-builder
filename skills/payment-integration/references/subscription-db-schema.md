# サブスクリプション DB スキーマ設計（Supabase）

## 概要

Stripe サブスクリプションと Supabase を同期するためのデータベース設計。
RLS（Row Level Security）でマルチテナント分離を実現。

---

## テーブル設計

### ER 図（概要）

```
users (Supabase Auth)
  │
  ├── 1:1 ── customers (Stripe Customer 連携)
  │              │
  │              ├── 1:N ── subscriptions (サブスクリプション)
  │              │              │
  │              │              └── 1:N ── subscription_items (プランアイテム)
  │              │
  │              └── 1:N ── invoices (請求書)
  │
  └── 1:1 ── user_entitlements (機能アクセス権)
```

---

### customers テーブル

```sql
CREATE TABLE public.customers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  stripe_customer_id TEXT UNIQUE NOT NULL,
  email TEXT,
  name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT customers_user_id_key UNIQUE (user_id)
);

-- インデックス
CREATE INDEX idx_customers_stripe_id ON public.customers(stripe_customer_id);
CREATE INDEX idx_customers_user_id ON public.customers(user_id);

-- RLS
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own customer record"
  ON public.customers
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage customers"
  ON public.customers
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');
```

---

### subscriptions テーブル

```sql
CREATE TABLE public.subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  stripe_subscription_id TEXT UNIQUE NOT NULL,
  stripe_customer_id TEXT NOT NULL,
  stripe_price_id TEXT,
  status TEXT NOT NULL DEFAULT 'incomplete',
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN NOT NULL DEFAULT false,
  cancel_at TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  trial_start TIMESTAMPTZ,
  trial_end TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- インデックス
CREATE INDEX idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe_id ON public.subscriptions(stripe_subscription_id);
CREATE INDEX idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX idx_subscriptions_customer ON public.subscriptions(stripe_customer_id);

-- RLS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscriptions"
  ON public.subscriptions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage subscriptions"
  ON public.subscriptions
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');
```

---

### invoices テーブル

```sql
CREATE TABLE public.invoices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  stripe_invoice_id TEXT UNIQUE NOT NULL,
  stripe_subscription_id TEXT,
  stripe_customer_id TEXT NOT NULL,
  amount INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'jpy',
  status TEXT NOT NULL DEFAULT 'draft',
  invoice_url TEXT,
  invoice_pdf TEXT,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- インデックス
CREATE INDEX idx_invoices_stripe_id ON public.invoices(stripe_invoice_id);
CREATE INDEX idx_invoices_subscription ON public.invoices(stripe_subscription_id);
CREATE INDEX idx_invoices_customer ON public.invoices(stripe_customer_id);

-- RLS
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own invoices"
  ON public.invoices
  FOR SELECT
  USING (
    stripe_customer_id IN (
      SELECT stripe_customer_id FROM public.customers
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Service role can manage invoices"
  ON public.invoices
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');
```

---

### user_entitlements テーブル

```sql
CREATE TABLE public.user_entitlements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan TEXT NOT NULL DEFAULT 'free',
  features JSONB NOT NULL DEFAULT '{}',
  usage_limits JSONB NOT NULL DEFAULT '{}',
  is_active BOOLEAN NOT NULL DEFAULT true,
  valid_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT user_entitlements_user_id_key UNIQUE (user_id)
);

-- インデックス
CREATE INDEX idx_entitlements_user_id ON public.user_entitlements(user_id);
CREATE INDEX idx_entitlements_plan ON public.user_entitlements(plan);

-- RLS
ALTER TABLE public.user_entitlements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own entitlements"
  ON public.user_entitlements
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage entitlements"
  ON public.user_entitlements
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');
```

### entitlements の使用例

```typescript
// features JSONB の構造例
{
  "max_projects": 10,
  "max_team_members": 5,
  "api_access": true,
  "priority_support": false,
  "custom_domain": false,
  "analytics": "basic"      // "basic" | "advanced" | "enterprise"
}

// usage_limits JSONB の構造例
{
  "api_calls_monthly": 10000,
  "storage_mb": 1024,
  "ai_tokens_monthly": 100000
}
```

---

### stripe_events テーブル（べき等性管理）

```sql
CREATE TABLE public.stripe_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  stripe_event_id TEXT UNIQUE NOT NULL,
  event_type TEXT,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_stripe_events_event_id ON public.stripe_events(stripe_event_id);

-- 古いイベントの自動削除（90日）
-- Supabase の pg_cron 拡張で設定
-- SELECT cron.schedule('cleanup-stripe-events', '0 3 * * *',
--   $$DELETE FROM public.stripe_events WHERE created_at < now() - interval '90 days'$$
-- );

-- RLS: サービスロールのみアクセス
ALTER TABLE public.stripe_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role only"
  ON public.stripe_events
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');
```

---

## サブスクリプション ステータス遷移

### Stripe のステータス定義

```
                    ┌─────────────┐
                    │ incomplete  │ ← 初回支払い未完了
                    └──────┬──────┘
                           │ 支払い成功
                           ▼
    ┌──────────┐    ┌─────────────┐    ┌──────────────────┐
    │ trialing │───▶│   active    │───▶│ past_due         │
    └──────────┘    └──────┬──────┘    │(支払い失敗)       │
     トライアル終了         │           └────────┬─────────┘
     → active へ           │                    │
                           │                    │ リトライ全失敗
                           │                    ▼
                           │           ┌──────────────────┐
                           │           │   unpaid         │
                           │           └────────┬─────────┘
                           │                    │
                           ▼                    ▼
                    ┌─────────────┐    ┌──────────────────┐
                    │  canceled   │    │ incomplete_      │
                    └─────────────┘    │ expired          │
                                       └──────────────────┘

特殊遷移:
  active → paused (一時停止、手動設定)
  任意のステータス → canceled (即時キャンセル)
```

### アプリケーションでの判定ロジック

```typescript
// lib/subscription/check-access.ts
type SubscriptionStatus =
  | "trialing"
  | "active"
  | "past_due"
  | "canceled"
  | "unpaid"
  | "incomplete"
  | "incomplete_expired"
  | "paused";

export function hasActiveSubscription(
  status: SubscriptionStatus | null
): boolean {
  if (!status) return false;
  return ["trialing", "active"].includes(status);
}

export function hasGracePeriodAccess(
  status: SubscriptionStatus | null
): boolean {
  if (!status) return false;
  return ["trialing", "active", "past_due"].includes(status);
}

export function shouldShowPaymentWarning(
  status: SubscriptionStatus | null
): boolean {
  return status === "past_due";
}

export function shouldBlockAccess(
  status: SubscriptionStatus | null
): boolean {
  if (!status) return true;
  return ["canceled", "unpaid", "incomplete_expired"].includes(status);
}
```

---

## Stripe 同期パターン

### Webhook → DB 同期フロー

```
Stripe Event
    │
    ▼
Webhook Handler (app/api/webhooks/stripe/route.ts)
    │
    ├── 署名検証
    ├── べき等性チェック (stripe_events)
    │
    ├── customer.subscription.created/updated
    │   └── subscriptions テーブル UPSERT
    │       └── user_entitlements テーブル UPDATE
    │
    ├── customer.subscription.deleted
    │   └── subscriptions テーブル UPDATE (status → canceled)
    │       └── user_entitlements テーブル UPDATE (plan → free)
    │
    ├── invoice.payment_succeeded
    │   └── invoices テーブル INSERT
    │
    └── invoice.payment_failed
        └── invoices テーブル UPSERT
            └── 通知送信
```

### entitlements 同期の実装

```typescript
// lib/stripe/sync-entitlements.ts
import { createClient } from "@/lib/supabase/server";

interface PlanConfig {
  plan: string;
  features: Record<string, unknown>;
  usageLimits: Record<string, number>;
}

const PLAN_MAP: Record<string, PlanConfig> = {
  price_free: {
    plan: "free",
    features: {
      max_projects: 3,
      max_team_members: 1,
      api_access: false,
      priority_support: false,
    },
    usageLimits: {
      api_calls_monthly: 1000,
      storage_mb: 100,
    },
  },
  price_pro_monthly: {
    plan: "pro",
    features: {
      max_projects: 50,
      max_team_members: 10,
      api_access: true,
      priority_support: false,
    },
    usageLimits: {
      api_calls_monthly: 50000,
      storage_mb: 5120,
    },
  },
  price_enterprise_monthly: {
    plan: "enterprise",
    features: {
      max_projects: -1,
      max_team_members: -1,
      api_access: true,
      priority_support: true,
    },
    usageLimits: {
      api_calls_monthly: -1,
      storage_mb: -1,
    },
  },
};

export async function syncEntitlements(
  userId: string,
  stripePriceId: string | null,
  subscriptionStatus: string
) {
  const supabase = await createClient();

  const isActive = ["trialing", "active", "past_due"].includes(
    subscriptionStatus
  );

  const planConfig = stripePriceId
    ? PLAN_MAP[stripePriceId] ?? PLAN_MAP["price_free"]
    : PLAN_MAP["price_free"];

  const { error } = await supabase.from("user_entitlements").upsert(
    {
      user_id: userId,
      plan: isActive ? planConfig.plan : "free",
      features: isActive
        ? planConfig.features
        : PLAN_MAP["price_free"].features,
      usage_limits: isActive
        ? planConfig.usageLimits
        : PLAN_MAP["price_free"].usageLimits,
      is_active: isActive,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" }
  );

  if (error) throw error;
}
```

---

## ミドルウェアでのアクセス制御

```typescript
// middleware.ts（該当部分のみ）
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function middleware(request: NextRequest) {
  // ... Supabase セッション確認 ...

  if (request.nextUrl.pathname.startsWith("/app/pro")) {
    const supabase = createServerClient(/* ... */);

    const { data: entitlement } = await supabase
      .from("user_entitlements")
      .select("plan, is_active")
      .eq("user_id", user.id)
      .single();

    if (!entitlement?.is_active || entitlement.plan === "free") {
      return NextResponse.redirect(new URL("/pricing", request.url));
    }
  }

  return NextResponse.next();
}
```

---

## マイグレーション実行手順

```bash
# 1. Supabase CLI でマイグレーション作成
supabase migration new create_subscription_tables

# 2. 生成されたファイルに上記 SQL を記述
# supabase/migrations/YYYYMMDDHHMMSS_create_subscription_tables.sql

# 3. ローカルで適用・テスト
supabase db reset

# 4. 本番適用
supabase db push
```

### 初期データ投入

```sql
-- 既存ユーザーにフリープランの entitlements を付与
INSERT INTO public.user_entitlements (user_id, plan, features, usage_limits)
SELECT
  id,
  'free',
  '{"max_projects": 3, "max_team_members": 1, "api_access": false}'::jsonb,
  '{"api_calls_monthly": 1000, "storage_mb": 100}'::jsonb
FROM auth.users
WHERE id NOT IN (SELECT user_id FROM public.user_entitlements)
ON CONFLICT (user_id) DO NOTHING;
```
