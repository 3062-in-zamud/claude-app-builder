# メール配信設定ガイド

## 概要

メール配信の信頼性を確保するためのDNS認証設定（SPF/DKIM/DMARC）、Resendセットアップ、法令準拠チェックリスト、配信停止実装パターンを網羅。

---

## 1. DNS認証設定

### 認証の全体像

```
送信サーバー → 受信サーバー
                  │
                  ├─ SPF チェック: 送信元IPは許可されているか？
                  ├─ DKIM チェック: メールは改ざんされていないか？
                  └─ DMARC チェック: SPF/DKIMが一致し、ポリシーに準拠しているか？
```

### SPF（Sender Policy Framework）

送信元IPアドレスを認証する。

```dns
# DNSのTXTレコード
# ドメイン: yourdomain.com

yourdomain.com.  IN  TXT  "v=spf1 include:amazonses.com include:resend.com ~all"
```

| 構文 | 意味 |
|------|------|
| `v=spf1` | SPFバージョン1 |
| `include:resend.com` | Resendの送信サーバーを許可 |
| `include:amazonses.com` | Amazon SESを許可（Resendが使用） |
| `~all` | 上記以外はソフトフェイル（推奨） |
| `-all` | 上記以外はハードフェイル（厳格） |

**注意:** SPFレコードは1ドメインにつき1つのみ。複数サービス使用時は `include` を1行にまとめる。

### DKIM（DomainKeys Identified Mail）

メールの改ざん検知のための電子署名。

```dns
# ResendのDKIMレコード（3つ設定が必要）
# Resend Dashboard → Domains → DNS Records から取得

resend._domainkey.yourdomain.com.  IN  CNAME  resend._domainkey.resend.com.
resend2._domainkey.yourdomain.com. IN  CNAME  resend2._domainkey.resend.com.
resend3._domainkey.yourdomain.com. IN  CNAME  resend3._domainkey.resend.com.
```

### DMARC（Domain-based Message Authentication, Reporting & Conformance）

SPFとDKIMの結果に基づくポリシー。

```dns
# DMARCレコード
_dmarc.yourdomain.com.  IN  TXT  "v=DMARC1; p=none; rua=mailto:dmarc@yourdomain.com; pct=100"
```

| パラメータ | 値 | 意味 |
|-----------|-----|------|
| `v=DMARC1` | 固定 | DMARCバージョン |
| `p=none` | none/quarantine/reject | ポリシー |
| `rua=mailto:...` | メールアドレス | レポート送信先 |
| `pct=100` | 0-100 | 適用率 |

#### DMARC段階的導入

```
Phase 1 (2週間): p=none      → モニタリングのみ、レポート収集
Phase 2 (2週間): p=quarantine → 失敗メールを迷惑メールフォルダへ
Phase 3 (以降):  p=reject     → 失敗メールを完全拒否
```

### DNS設定確認ツール

```bash
# SPF確認
dig TXT yourdomain.com +short

# DKIM確認
dig CNAME resend._domainkey.yourdomain.com +short

# DMARC確認
dig TXT _dmarc.yourdomain.com +short

# 総合チェック（オンラインツール）
# - https://mxtoolbox.com/SuperTool.aspx
# - https://dmarcian.com/dmarc-inspector/
```

---

## 2. Resend セットアップ

### インストール

```bash
npm install resend
# or
pnpm add resend
```

### 基本設定

```typescript
// lib/email/resend.ts
import { Resend } from "resend";

export const resend = new Resend(process.env.RESEND_API_KEY);

// 共通設定
export const EMAIL_CONFIG = {
  from: "App Name <noreply@yourdomain.com>",
  replyTo: "support@yourdomain.com",
} as const;
```

### ドメイン認証手順

```
1. Resend Dashboard (https://resend.com/domains) にアクセス
2. "Add Domain" → ドメイン名を入力
3. 表示されるDNSレコードを設定:
   - MX レコード (1件)
   - TXT レコード (SPF用, 1件)
   - CNAME レコード (DKIM用, 3件)
4. "Verify DNS Records" をクリック
5. ステータスが "Verified" になるまで待つ（通常数分〜24時間）
```

### メール送信関数

```typescript
// lib/email/send.ts
import { resend, EMAIL_CONFIG } from "./resend";
import { WelcomeEmail } from "@/emails/WelcomeEmail";
import { render } from "@react-email/render";

interface SendEmailOptions {
  to: string;
  subject: string;
  react: React.ReactElement;
  tags?: Array<{ name: string; value: string }>;
}

export async function sendEmail(options: SendEmailOptions) {
  try {
    const { data, error } = await resend.emails.send({
      from: EMAIL_CONFIG.from,
      replyTo: EMAIL_CONFIG.replyTo,
      to: options.to,
      subject: options.subject,
      react: options.react,
      tags: options.tags,
      headers: {
        "List-Unsubscribe": `<https://yourdomain.com/api/unsubscribe?email=${encodeURIComponent(options.to)}>`,
        "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
      },
    });

    if (error) {
      console.error("Email send error:", error);
      throw new Error(error.message);
    }

    return data;
  } catch (err) {
    console.error("Failed to send email:", err);
    throw err;
  }
}

// 使用例
await sendEmail({
  to: "user@example.com",
  subject: "ようこそ！最初の3分で始めましょう",
  react: WelcomeEmail({
    firstName: "太郎",
    dashboardUrl: "https://app.yourdomain.com/dashboard",
    profileUrl: "https://app.yourdomain.com/settings/profile",
    newProjectUrl: "https://app.yourdomain.com/projects/new",
    inviteUrl: "https://app.yourdomain.com/settings/team",
  }),
  tags: [
    { name: "campaign", value: "onboarding" },
    { name: "email_type", value: "welcome" },
  ],
});
```

### Webhook（配信ステータス追跡）

```typescript
// app/api/webhooks/resend/route.ts
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const body = await request.json();

  // Resendのwebhookイベント
  switch (body.type) {
    case "email.sent":
      console.log(`Email sent: ${body.data.email_id}`);
      break;
    case "email.delivered":
      console.log(`Email delivered: ${body.data.email_id}`);
      break;
    case "email.opened":
      console.log(`Email opened: ${body.data.email_id}`);
      break;
    case "email.clicked":
      console.log(`Link clicked: ${body.data.email_id}`);
      break;
    case "email.bounced":
      console.error(`Email bounced: ${body.data.email_id}`);
      // バウンスリストに追加
      break;
    case "email.complained":
      console.error(`Spam complaint: ${body.data.email_id}`);
      // 自動配信停止
      break;
  }

  return NextResponse.json({ received: true });
}
```

### .env.local

```bash
RESEND_API_KEY=re_xxxxxxxxxxxxx
```

---

## 3. CAN-SPAM / GDPR 準拠チェックリスト

### CAN-SPAM Act（米国）準拠

- [ ] **送信者の正確な識別**: From/Reply-Toが正確
- [ ] **件名が内容を反映**: 誤解を招くSubject Lineでない
- [ ] **広告の明示**: 広告メールであることを示す（該当する場合）
- [ ] **物理的住所の記載**: 送信者の住所をフッターに含む
- [ ] **配信停止の提供**: オプトアウトリンクを明記
- [ ] **10営業日以内の対応**: 配信停止リクエストに10営業日以内に対応
- [ ] **第三者への責任**: 委託先の送信も準拠が必要

### GDPR（EU一般データ保護規則）準拠

- [ ] **明示的同意（オプトイン）**: メール送信前に明示的な同意を取得
- [ ] **ダブルオプトイン**: 確認メールでの再同意（推奨）
- [ ] **同意の記録**: いつ、どのように同意を得たかを記録
- [ ] **簡単なオプトアウト**: 全メールに配信停止リンクを含む
- [ ] **データ最小化**: 必要最小限の個人データのみ収集
- [ ] **データアクセス権**: ユーザーが自分のデータを確認・ダウンロードできる
- [ ] **データ削除権**: ユーザーがデータの削除を要求できる
- [ ] **プライバシーポリシー**: メール配信に関する記載を含む
- [ ] **データ処理者との契約**: Resend等のDPA（Data Processing Agreement）を締結

### 日本（特定電子メール法）準拠

- [ ] **オプトイン**: 事前同意を得たユーザーのみに送信
- [ ] **送信者情報**: 氏名/名称、住所、連絡先を明記
- [ ] **配信停止**: 受信拒否の通知手段を明記
- [ ] **同意記録の保存**: 同意を証明する記録を保存

---

## 4. 配信停止実装パターン

### パターン1: ワンクリック配信停止（推奨）

```typescript
// app/api/unsubscribe/route.ts
import { NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

// GET: 配信停止確認ページ表示
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const token = searchParams.get("token");

  if (!token) {
    return NextResponse.json({ error: "Invalid token" }, { status: 400 });
  }

  // トークンからユーザーを特定
  const { data: preference } = await supabase
    .from("email_preferences")
    .select("email, unsubscribed")
    .eq("unsubscribe_token", token)
    .single();

  if (!preference) {
    return NextResponse.json({ error: "Invalid token" }, { status: 404 });
  }

  // 配信停止処理
  await supabase
    .from("email_preferences")
    .update({
      unsubscribed: true,
      unsubscribed_at: new Date().toISOString(),
    })
    .eq("unsubscribe_token", token);

  // 確認ページにリダイレクト
  return NextResponse.redirect(
    `${process.env.NEXT_PUBLIC_APP_URL}/unsubscribed`
  );
}

// POST: List-Unsubscribe-Post対応（RFC 8058）
export async function POST(request: Request) {
  const { searchParams } = new URL(request.url);
  const email = searchParams.get("email");

  if (!email) {
    return NextResponse.json({ error: "Invalid email" }, { status: 400 });
  }

  await supabase
    .from("email_preferences")
    .update({
      unsubscribed: true,
      unsubscribed_at: new Date().toISOString(),
    })
    .eq("email", email);

  return NextResponse.json({ success: true });
}
```

### パターン2: カテゴリ別配信設定

```typescript
// 配信設定テーブル
/*
CREATE TABLE email_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  unsubscribe_token TEXT UNIQUE DEFAULT gen_random_uuid()::TEXT,

  -- カテゴリ別設定
  marketing BOOLEAN DEFAULT TRUE,
  product_updates BOOLEAN DEFAULT TRUE,
  transactional BOOLEAN DEFAULT TRUE,  -- 常にTRUE（解除不可）
  weekly_digest BOOLEAN DEFAULT TRUE,

  unsubscribed BOOLEAN DEFAULT FALSE,  -- 全配信停止
  unsubscribed_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
*/

// 配信設定ページ
// app/settings/email/page.tsx
"use client";

import { useState, useEffect } from "react";
import { createClient } from "@/lib/supabase/client";

interface EmailPreferences {
  marketing: boolean;
  product_updates: boolean;
  weekly_digest: boolean;
}

export default function EmailPreferencesPage() {
  const [prefs, setPrefs] = useState<EmailPreferences>({
    marketing: true,
    product_updates: true,
    weekly_digest: true,
  });
  const [saving, setSaving] = useState(false);
  const supabase = createClient();

  useEffect(() => {
    async function load() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data } = await supabase
        .from("email_preferences")
        .select("marketing, product_updates, weekly_digest")
        .eq("user_id", user.id)
        .single();

      if (data) setPrefs(data);
    }
    load();
  }, []);

  async function save() {
    setSaving(true);
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    await supabase
      .from("email_preferences")
      .upsert({
        user_id: user.id,
        ...prefs,
        updated_at: new Date().toISOString(),
      });

    setSaving(false);
  }

  return (
    <div className="max-w-md mx-auto p-6">
      <h1 className="text-xl font-semibold mb-6">メール通知設定</h1>

      <div className="space-y-4">
        <label className="flex items-center gap-3">
          <input
            type="checkbox"
            checked={prefs.marketing}
            onChange={(e) => setPrefs({ ...prefs, marketing: e.target.checked })}
          />
          <div>
            <p className="font-medium">マーケティング</p>
            <p className="text-sm text-gray-500">新機能やキャンペーンのお知らせ</p>
          </div>
        </label>

        <label className="flex items-center gap-3">
          <input
            type="checkbox"
            checked={prefs.product_updates}
            onChange={(e) => setPrefs({ ...prefs, product_updates: e.target.checked })}
          />
          <div>
            <p className="font-medium">プロダクトアップデート</p>
            <p className="text-sm text-gray-500">新機能リリースや改善のお知らせ</p>
          </div>
        </label>

        <label className="flex items-center gap-3">
          <input
            type="checkbox"
            checked={prefs.weekly_digest}
            onChange={(e) => setPrefs({ ...prefs, weekly_digest: e.target.checked })}
          />
          <div>
            <p className="font-medium">週次ダイジェスト</p>
            <p className="text-sm text-gray-500">週間アクティビティのサマリー</p>
          </div>
        </label>

        <div className="pt-2 border-t">
          <p className="text-xs text-gray-400">
            取引関連メール（決済確認、パスワードリセット等）は配信停止できません。
          </p>
        </div>
      </div>

      <button
        onClick={save}
        disabled={saving}
        className="mt-6 w-full py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
      >
        {saving ? "保存中..." : "設定を保存"}
      </button>
    </div>
  );
}
```

### 送信前の配信停止チェック

```typescript
// lib/email/check-preference.ts
export async function canSendEmail(
  supabase: SupabaseClient,
  email: string,
  category: "marketing" | "product_updates" | "weekly_digest" | "transactional"
): Promise<boolean> {
  // トランザクションメールは常に送信可能
  if (category === "transactional") return true;

  const { data } = await supabase
    .from("email_preferences")
    .select(`unsubscribed, ${category}`)
    .eq("email", email)
    .single();

  // レコードがない場合はデフォルトで送信可能
  if (!data) return true;

  // 全配信停止チェック
  if (data.unsubscribed) return false;

  // カテゴリ別チェック
  return data[category] === true;
}
```

---

## 5. 配信品質モニタリング

### 主要指標と健全性基準

| 指標 | 健全な値 | 危険な値 | 対策 |
|------|---------|---------|------|
| バウンス率 | < 2% | > 5% | リスト精査、ダブルオプトイン |
| スパム報告率 | < 0.1% | > 0.3% | コンテンツ改善、配信頻度見直し |
| 開封率 | > 20% | < 10% | Subject改善、送信時間最適化 |
| クリック率 | > 2% | < 0.5% | CTA改善、コンテンツ最適化 |
| 配信停止率 | < 0.5% | > 1% | 頻度・内容の見直し |

### バウンス処理

```typescript
// ハードバウンス: 即座に配信リストから除外
// ソフトバウンス: 3回連続で配信リストから除外

async function handleBounce(email: string, bounceType: "hard" | "soft") {
  if (bounceType === "hard") {
    // 即座に配信停止
    await supabase
      .from("email_preferences")
      .update({ unsubscribed: true, unsubscribed_at: new Date().toISOString() })
      .eq("email", email);
  } else {
    // ソフトバウンスカウント
    const { data } = await supabase
      .from("email_preferences")
      .select("soft_bounce_count")
      .eq("email", email)
      .single();

    const count = (data?.soft_bounce_count ?? 0) + 1;

    if (count >= 3) {
      await supabase
        .from("email_preferences")
        .update({ unsubscribed: true, unsubscribed_at: new Date().toISOString() })
        .eq("email", email);
    } else {
      await supabase
        .from("email_preferences")
        .update({ soft_bounce_count: count })
        .eq("email", email);
    }
  }
}
```

---

## 6. 設定チェックリスト

### DNS認証
- [ ] SPFレコードを設定
- [ ] DKIMレコードを設定（3つのCNAME）
- [ ] DMARCレコードを設定（まずp=none）
- [ ] MXToolboxで全レコードの検証
- [ ] Resend Dashboardでドメイン認証完了

### Resendセットアップ
- [ ] Resendアカウント作成
- [ ] APIキー発行・環境変数設定
- [ ] ドメイン認証完了
- [ ] テストメール送信成功
- [ ] Webhook設定（配信ステータス追跡）

### 法令準拠
- [ ] CAN-SPAM準拠（フッター、配信停止リンク）
- [ ] GDPR準拠（オプトイン、データ権利）
- [ ] 特定電子メール法準拠（送信者情報、同意記録）
- [ ] プライバシーポリシーにメール配信の記載

### 配信停止
- [ ] ワンクリック配信停止を実装
- [ ] List-Unsubscribeヘッダーを設定
- [ ] カテゴリ別配信設定ページを実装
- [ ] 送信前の配信停止チェックロジックを実装
- [ ] バウンス処理を実装

### モニタリング
- [ ] バウンス率アラート設定
- [ ] スパム報告率アラート設定
- [ ] 配信レポートダッシュボード構築
