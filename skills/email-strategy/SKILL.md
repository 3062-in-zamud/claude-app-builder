---
name: email-strategy
description: |
  What: メール戦略 - Resend + React Email によるドリップキャンペーン・トランザクショナルメール実装（Phase 10）
  When: onboarding-optimizer完了後、growth-engine の Stage D で実行
  How: requirements.md + onboarding-strategy.md を基にメールテンプレート・配信ロジックを実装
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# email-strategy: メール戦略・実装

## 概要

ユーザーエンゲージメントを最大化するメール戦略を設計・実装します。
Resend + React Email でドリップキャンペーン（ウェルカム〜アップグレードCTA）と
トランザクショナルメール（パスワードリセット・課金通知・領収書）を構築し、
CAN-SPAM/GDPR 準拠の配信停止機能を含めます。

## ワークフロー

### Step 1: インプット読み込み

- `docs/requirements.md` - プロダクト概要・機能
- `docs/onboarding-strategy.md`（存在する場合）- オンボーディングフロー・TTV設計
- `docs/pricing-strategy.md`（存在する場合）- プラン設計
- `docs/brand-brief.md`（存在する場合）- ブランドトーン

### Step 2: Resend + React Email セットアップ

```bash
npm install resend @react-email/components react-email
```

#### `src/lib/email.ts` - メール送信クライアント

```typescript
import { Resend } from 'resend'

if (!process.env.RESEND_API_KEY) {
  throw new Error('RESEND_API_KEY is not set')
}

export const resend = new Resend(process.env.RESEND_API_KEY)

export const EMAIL_FROM = process.env.EMAIL_FROM || 'noreply@yourdomain.com'
```

### Step 3: ドリップキャンペーン設計

```markdown
## ドリップキャンペーンスケジュール

| Day | メール | 目的 | トリガー | KPI |
|-----|-------|------|---------|-----|
| 0 | Welcome | 価値の再確認 + 最初のアクション誘導 | サインアップ完了 | 開封率 > 70% |
| 1 | Quick Win | 「5分でできる○○」具体的な成功体験 | Day0メール開封 or 時間経過 | クリック率 > 15% |
| 3 | Feature Highlight | 見落としがちな便利機能の紹介 | 時間経過 | 機能利用率UP |
| 7 | Social Proof | 「○○人が使っています」+ ユースケース | 時間経過 | リテンション率UP |
| 14 | Upgrade CTA | Pro版の価値訴求 + 限定オファー | トライアル期限3日前 or 時間経過 | 転換率 > 2% |
```

#### ドリップメール実装

各メールを React Email コンポーネントとして実装:

##### `src/emails/welcome.tsx`

```tsx
import {
  Body, Container, Head, Heading, Html, Link,
  Preview, Section, Text, Button, Img,
} from '@react-email/components'

interface WelcomeEmailProps {
  userName: string
  actionUrl: string
}

export default function WelcomeEmail({ userName, actionUrl }: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>[プロダクト名]へようこそ</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={h1}>ようこそ、{userName}さん！</Heading>
          <Text style={text}>
            [プロダクト名]にご登録いただきありがとうございます。
          </Text>
          <Section style={buttonContainer}>
            <Button style={button} href={actionUrl}>
              さっそく始める
            </Button>
          </Section>
          <Text style={footer}>
            このメールは[プロダクト名]から送信されています。
            <Link href="{unsubscribe_url}">配信停止</Link>
          </Text>
        </Container>
      </Body>
    </Html>
  )
}

const main = { backgroundColor: '#f6f9fc', fontFamily: 'sans-serif' }
const container = { margin: '0 auto', padding: '40px 20px', maxWidth: '560px' }
const h1 = { color: '#1a1a1a', fontSize: '24px' }
const text = { color: '#4a4a4a', fontSize: '16px', lineHeight: '26px' }
const buttonContainer = { textAlign: 'center' as const, margin: '32px 0' }
const button = {
  backgroundColor: '#000', color: '#fff', padding: '12px 24px',
  borderRadius: '6px', fontSize: '16px', textDecoration: 'none',
}
const footer = { color: '#8898aa', fontSize: '12px', marginTop: '32px' }
```

同様のパターンで以下のメールも生成:
- `src/emails/quick-win.tsx` - Day1: 具体的な成功体験ガイド
- `src/emails/feature-highlight.tsx` - Day3: 便利機能紹介
- `src/emails/social-proof.tsx` - Day7: 利用事例・ソーシャルプルーフ
- `src/emails/upgrade-cta.tsx` - Day14: アップグレード訴求

### Step 4: トランザクショナルメール

#### `src/emails/password-reset.tsx`

```tsx
// パスワードリセットメール
// resetUrl を含む。有効期限（1時間）を明記。
```

#### `src/emails/payment-receipt.tsx`

```tsx
// 課金領収書メール
// 金額、プラン名、次回更新日を含む。
```

#### `src/emails/payment-failed.tsx`

```tsx
// 課金失敗通知メール
// 支払い方法更新リンクを含む。
```

#### メール送信 API

##### `src/app/api/email/send/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { resend, EMAIL_FROM } from '@/lib/email'
import WelcomeEmail from '@/emails/welcome'

// 内部 API（Webhook や Cron Job から呼び出し）
export async function POST(req: NextRequest) {
  // API キーによる認証（内部呼び出し用）
  const authHeader = req.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.INTERNAL_API_KEY}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { type, to, data } = await req.json()

  const emailMap: Record<string, { subject: string; component: any }> = {
    welcome: {
      subject: '[プロダクト名]へようこそ！',
      component: WelcomeEmail(data),
    },
    // 他のメールタイプも同様に追加
  }

  const email = emailMap[type]
  if (!email) {
    return NextResponse.json({ error: 'Unknown email type' }, { status: 400 })
  }

  const result = await resend.emails.send({
    from: EMAIL_FROM,
    to,
    subject: email.subject,
    react: email.component,
  })

  return NextResponse.json(result)
}
```

### Step 5: 配信停止（Unsubscribe）機能

CAN-SPAM / GDPR 準拠の配信停止機能:

#### Supabase テーブル

```sql
-- メール配信設定テーブル
CREATE TABLE IF NOT EXISTS email_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  marketing_emails BOOLEAN DEFAULT true,
  product_updates BOOLEAN DEFAULT true,
  transactional_emails BOOLEAN DEFAULT true, -- パスワードリセット等は常に送信
  unsubscribe_token UUID DEFAULT gen_random_uuid() UNIQUE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE email_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own email preferences"
  ON email_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own email preferences"
  ON email_preferences FOR UPDATE
  USING (auth.uid() = user_id);
```

#### `src/app/unsubscribe/[token]/page.tsx`

```typescript
// 配信停止ページ
// - ワンクリック配信停止（List-Unsubscribe ヘッダー対応）
// - カテゴリ別の配信設定変更
// - 認証不要（トークンベース）
```

#### List-Unsubscribe ヘッダー

```typescript
// 全マーケティングメールに以下のヘッダーを付与
headers: {
  'List-Unsubscribe': `<${appUrl}/unsubscribe/{token}>`,
  'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
}
```

### Step 6: メールテンプレートコンポーネント

共通の React Email コンポーネントを作成:

#### `src/emails/components/layout.tsx`

```tsx
// 共通レイアウト: ロゴ + フッター（配信停止リンク必須）
```

#### `src/emails/components/button.tsx`

```tsx
// ブランドカラーのCTAボタン
```

#### `src/emails/components/footer.tsx`

```tsx
// 共通フッター: 会社名・住所・配信停止リンク（CAN-SPAM必須項目）
```

### Step 7: 送信ログ・開封率追跡設計

```markdown
## メール分析設計

### Resend Webhook イベント
| イベント | 用途 | 保存先 |
|---------|------|--------|
| email.sent | 送信成功確認 | email_logs テーブル |
| email.delivered | 到達確認 | email_logs テーブル |
| email.opened | 開封率計測 | email_logs テーブル |
| email.clicked | クリック率計測 | email_logs テーブル |
| email.bounced | バウンス処理 | email_logs + 配信停止 |
| email.complained | スパム報告処理 | email_logs + 配信停止 |

### 主要KPI
| 指標 | 目標 | 計算方法 |
|------|------|---------|
| 開封率 | > 30% | opened / delivered |
| クリック率 | > 5% | clicked / delivered |
| 配信停止率 | < 0.5% | unsubscribed / delivered |
| バウンス率 | < 2% | bounced / sent |
```

## 出力ファイル

- `src/lib/email.ts` - Resend クライアント初期化
- `src/emails/welcome.tsx` - ウェルカムメール
- `src/emails/quick-win.tsx` - Day1 メール
- `src/emails/feature-highlight.tsx` - Day3 メール
- `src/emails/social-proof.tsx` - Day7 メール
- `src/emails/upgrade-cta.tsx` - Day14 メール
- `src/emails/password-reset.tsx` - パスワードリセット
- `src/emails/payment-receipt.tsx` - 課金領収書
- `src/emails/payment-failed.tsx` - 課金失敗通知
- `src/emails/components/layout.tsx` - 共通レイアウト
- `src/emails/components/button.tsx` - CTAボタン
- `src/emails/components/footer.tsx` - 共通フッター
- `src/app/api/email/send/route.ts` - メール送信 API
- `src/app/unsubscribe/[token]/page.tsx` - 配信停止ページ
- `supabase/migrations/YYYYMMDD_create_email_preferences.sql` - DB マイグレーション
- `docs/email-strategy.md` - メール戦略ドキュメント

## 品質チェック

- [ ] 全マーケティングメールに配信停止リンクが含まれているか（CAN-SPAM/GDPR必須）
- [ ] List-Unsubscribe ヘッダーが設定されているか
- [ ] SPF/DKIM 設定ガイドが docs/email-strategy.md に含まれているか
- [ ] テスト送信手順が記載されているか
- [ ] トランザクショナルメールは配信停止の対象外になっているか
- [ ] バウンス・スパム報告時の自動配信停止が実装されているか
- [ ] メールテンプレートがモバイルレスポンシブか
- [ ] 環境変数にAPIキーがハードコードされていないか
