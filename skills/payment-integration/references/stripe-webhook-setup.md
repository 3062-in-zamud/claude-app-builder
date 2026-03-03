# Stripe Webhook セットアップガイド

## 概要

Stripe Webhook は決済イベントをリアルタイムでアプリケーションに通知する仕組み。
サブスクリプション管理、支払い確認、請求書発行などの自動処理に必須。

---

## 必須イベント一覧

### サブスクリプションビジネスの推奨イベント

| イベント | 用途 | 優先度 |
|---------|------|--------|
| `checkout.session.completed` | Checkout完了後の処理 | **必須** |
| `customer.subscription.created` | サブスク作成時のDB同期 | **必須** |
| `customer.subscription.updated` | プラン変更・ステータス変更 | **必須** |
| `customer.subscription.deleted` | 解約処理 | **必須** |
| `invoice.payment_succeeded` | 支払い成功の記録 | **必須** |
| `invoice.payment_failed` | 支払い失敗の通知・リトライ | **必須** |
| `customer.created` | 顧客レコード同期 | 推奨 |
| `customer.updated` | 顧客情報の変更同期 | 推奨 |
| `invoice.finalized` | 請求書確定 | 任意 |
| `charge.refunded` | 返金処理 | 任意 |
| `payment_intent.payment_failed` | 決済失敗の詳細取得 | 任意 |

---

## Next.js Webhook Handler（TypeScript）

### App Router (Route Handler)

```typescript
// app/api/webhooks/stripe/route.ts
import { headers } from "next/headers";
import { NextResponse } from "next/server";
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: "2024-12-18.acacia",
});

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

export async function POST(request: Request) {
  const body = await request.text();
  const headersList = await headers();
  const signature = headersList.get("stripe-signature");

  if (!signature) {
    return NextResponse.json(
      { error: "Missing stripe-signature header" },
      { status: 400 }
    );
  }

  // --- 署名検証 ---
  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error";
    console.error(`Webhook signature verification failed: ${message}`);
    return NextResponse.json(
      { error: "Invalid signature" },
      { status: 400 }
    );
  }

  // --- べき等性チェック ---
  const idempotencyKey = event.id;
  const alreadyProcessed = await checkProcessed(idempotencyKey);
  if (alreadyProcessed) {
    return NextResponse.json({ received: true });
  }

  // --- イベント処理 ---
  try {
    switch (event.type) {
      case "checkout.session.completed":
        await handleCheckoutCompleted(
          event.data.object as Stripe.Checkout.Session
        );
        break;

      case "customer.subscription.created":
      case "customer.subscription.updated":
        await handleSubscriptionChange(
          event.data.object as Stripe.Subscription
        );
        break;

      case "customer.subscription.deleted":
        await handleSubscriptionDeleted(
          event.data.object as Stripe.Subscription
        );
        break;

      case "invoice.payment_succeeded":
        await handlePaymentSucceeded(
          event.data.object as Stripe.Invoice
        );
        break;

      case "invoice.payment_failed":
        await handlePaymentFailed(
          event.data.object as Stripe.Invoice
        );
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    // 処理済みとして記録
    await markProcessed(idempotencyKey);

    return NextResponse.json({ received: true });
  } catch (err) {
    console.error(`Webhook handler error: ${err}`);
    return NextResponse.json(
      { error: "Webhook handler failed" },
      { status: 500 }
    );
  }
}
```

### イベントハンドラーの実装例

```typescript
// lib/stripe/webhook-handlers.ts
import { createClient } from "@/lib/supabase/server";
import type Stripe from "stripe";

export async function handleCheckoutCompleted(
  session: Stripe.Checkout.Session
) {
  const supabase = await createClient();
  const userId = session.metadata?.user_id;

  if (!userId) {
    throw new Error("Missing user_id in session metadata");
  }

  if (session.subscription) {
    const { error } = await supabase
      .from("subscriptions")
      .upsert({
        user_id: userId,
        stripe_subscription_id: session.subscription as string,
        stripe_customer_id: session.customer as string,
        status: "active",
        updated_at: new Date().toISOString(),
      });

    if (error) throw error;
  }
}

export async function handleSubscriptionChange(
  subscription: Stripe.Subscription
) {
  const supabase = await createClient();

  const { error } = await supabase
    .from("subscriptions")
    .update({
      status: subscription.status,
      stripe_price_id: subscription.items.data[0]?.price.id,
      current_period_start: new Date(
        subscription.current_period_start * 1000
      ).toISOString(),
      current_period_end: new Date(
        subscription.current_period_end * 1000
      ).toISOString(),
      cancel_at_period_end: subscription.cancel_at_period_end,
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_subscription_id", subscription.id);

  if (error) throw error;
}

export async function handleSubscriptionDeleted(
  subscription: Stripe.Subscription
) {
  const supabase = await createClient();

  const { error } = await supabase
    .from("subscriptions")
    .update({
      status: "canceled",
      canceled_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_subscription_id", subscription.id);

  if (error) throw error;
}

export async function handlePaymentSucceeded(invoice: Stripe.Invoice) {
  const supabase = await createClient();

  const { error } = await supabase.from("invoices").insert({
    stripe_invoice_id: invoice.id,
    stripe_subscription_id: invoice.subscription as string,
    stripe_customer_id: invoice.customer as string,
    amount: invoice.amount_paid,
    currency: invoice.currency,
    status: "paid",
    paid_at: new Date().toISOString(),
  });

  if (error) throw error;
}

export async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const supabase = await createClient();

  await supabase.from("invoices").upsert({
    stripe_invoice_id: invoice.id,
    stripe_subscription_id: invoice.subscription as string,
    stripe_customer_id: invoice.customer as string,
    amount: invoice.amount_due,
    currency: invoice.currency,
    status: "failed",
    updated_at: new Date().toISOString(),
  });

  const subscription = await supabase
    .from("subscriptions")
    .select("user_id")
    .eq("stripe_subscription_id", invoice.subscription as string)
    .single();

  if (subscription.data) {
    console.log(
      `Payment failed for user: ${subscription.data.user_id}`
    );
  }
}
```

---

## 署名検証の重要性

```
なぜ署名検証が必要か:

1. なりすまし防止
   - Webhook URL を知っている誰でもリクエストを送信できる
   - 署名なしでは偽のイベントを処理してしまう

2. 改ざん防止
   - リクエストボディが中間で改ざんされていないことを保証

3. リプレイ攻撃防止
   - タイムスタンプ検証により古いイベントの再送を拒否
   - Stripe SDK はデフォルトで300秒の許容範囲
```

### 注意点

```typescript
// NG: body を JSON パースしてから署名検証
const body = await request.json(); // これだと署名検証に失敗する

// OK: 生のテキストで受け取ってから署名検証
const body = await request.text();
const event = stripe.webhooks.constructEvent(body, signature, secret);
```

---

## べき等性（Idempotency）の実装

```
なぜべき等性が必要か:

- Stripe は配信失敗時にリトライする（最大3日間）
- ネットワーク障害で同じイベントが複数回届くことがある
- 2xx 以外のレスポンスで自動リトライされる
```

### 実装パターン

```typescript
// lib/stripe/idempotency.ts
import { createClient } from "@/lib/supabase/server";

export async function checkProcessed(eventId: string): Promise<boolean> {
  const supabase = await createClient();

  const { data } = await supabase
    .from("stripe_events")
    .select("id")
    .eq("stripe_event_id", eventId)
    .single();

  return !!data;
}

export async function markProcessed(eventId: string): Promise<void> {
  const supabase = await createClient();

  await supabase.from("stripe_events").insert({
    stripe_event_id: eventId,
    processed_at: new Date().toISOString(),
  });
}
```

### イベントログテーブル

```sql
CREATE TABLE stripe_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  stripe_event_id TEXT UNIQUE NOT NULL,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_stripe_events_event_id ON stripe_events(stripe_event_id);
```

---

## ローカルテスト

### Stripe CLI セットアップ

```bash
# インストール（macOS）
brew install stripe/stripe-cli/stripe

# ログイン
stripe login

# Webhook のローカル転送
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# 出力される Webhook Secret をメモ
# > Ready! Your webhook signing secret is whsec_xxxxx

# .env.local に設定
# STRIPE_WEBHOOK_SECRET=whsec_xxxxx
```

### テストイベントの発火

```bash
# 特定イベントをトリガー
stripe trigger checkout.session.completed
stripe trigger customer.subscription.created
stripe trigger customer.subscription.updated
stripe trigger customer.subscription.deleted
stripe trigger invoice.payment_succeeded
stripe trigger invoice.payment_failed

# カスタムペイロードでトリガー
stripe trigger checkout.session.completed \
  --override checkout_session:metadata.user_id=test-user-123
```

### テスト用カード番号

| カード番号 | 用途 |
|-----------|------|
| `4242 4242 4242 4242` | 成功する支払い |
| `4000 0000 0000 3220` | 3D Secure 認証が必要 |
| `4000 0000 0000 9995` | 残高不足で失敗 |
| `4000 0000 0000 0341` | カード拒否 |
| `4000 0025 0000 3155` | SCA 認証が必要 |
| `4000 0000 0000 0077` | 常に charge.dispute で係争 |

> 有効期限: 将来の任意の日付、CVC: 任意の3桁

---

## 本番デプロイのチェックリスト

```markdown
## Stripe Webhook 本番チェックリスト

### Stripe Dashboard 設定
- [ ] 本番用 Webhook エンドポイントを登録
- [ ] 必要なイベントのみを選択（不要なイベントは除外）
- [ ] Webhook Secret を本番環境変数に設定
- [ ] API バージョンを固定（ダッシュボードで確認）

### アプリケーション
- [ ] 署名検証が有効
- [ ] べき等性チェックが実装済み
- [ ] エラーハンドリングが適切（5xx で Stripe がリトライ）
- [ ] タイムアウト設定（Webhook は30秒以内に応答）
- [ ] ログ出力が十分（デバッグ用）

### セキュリティ
- [ ] Webhook Secret を環境変数で管理（コードにハードコードしない）
- [ ] HTTPS エンドポイントのみ使用
- [ ] IP フィルタリング（Stripe の IP レンジに限定、任意）

### 監視
- [ ] Webhook 失敗のアラート設定
- [ ] Stripe Dashboard の Webhook ログを定期確認
- [ ] 処理遅延のモニタリング

### テスト
- [ ] 全必須イベントの E2E テスト完了
- [ ] 支払い失敗シナリオのテスト完了
- [ ] リトライシナリオのテスト完了（べき等性確認）
- [ ] Stripe CLI でローカル検証完了
```

---

## トラブルシューティング

| 症状 | 原因 | 対策 |
|------|------|------|
| 400 Bad Request | 署名検証失敗 | `request.text()` で生ボディを取得しているか確認 |
| イベント二重処理 | べき等性未実装 | `stripe_events` テーブルで重複チェック |
| イベントが届かない | エンドポイントURL誤り | Stripe Dashboard でエンドポイント確認 |
| タイムアウト | 処理が30秒超過 | 重い処理はキューに入れて非同期化 |
| 本番で署名エラー | Secret の環境不一致 | 本番用 Secret を再確認 |
| body パース不能 | ミドルウェアが先にパース | Next.js の場合 Route Handler で `request.text()` を使用 |
