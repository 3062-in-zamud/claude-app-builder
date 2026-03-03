---
name: data-deletion
description: |
  What: 30日猶予付きデータ削除パイプライン（論理削除→物理削除）を設計・実装する
  When: Phase 11.5（コンプライアンス強化フェーズ）
  How: 削除フロー設計 → DB設計 → Stripe連携 → 削除ジョブ → 監査ログ実装
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# data-deletion: データ削除パイプライン

## 概要

GDPR「忘れられる権利」（Art.17）に準拠したデータ削除パイプラインを構築します。
30日の猶予期間付き論理削除から物理削除まで、安全かつ追跡可能な削除フローを実装します。

## ワークフロー

### Step 1: 入力ドキュメントの読み込み

以下のファイルを読み込み、削除対象のデータを把握:

- `docs/requirements.md` - ビジネス要件
- `docs/data-mapping.md` - データマッピング（存在する場合、gdpr-complianceスキルで生成）

### Step 2: 論理削除→物理削除パイプライン設計

```markdown
## 削除パイプライン

### フロー
1. ユーザーが削除リクエスト
2. 確認ダイアログ（理由ヒアリング含む）
3. 論理削除（Soft Delete）: `deleted_at` タイムスタンプ設定
4. 確認メール送信（30日以内なら復元可能と通知）
5. 30日猶予期間（この間ユーザーは復元可能）
6. 猶予期間満了 → 物理削除ジョブ実行
7. 外部サービスからのデータ削除
8. 削除完了通知メール
9. 監査ログ記録

### 状態遷移
active → deletion_requested → soft_deleted → (30日経過) → hard_deleted
         ↑                    ↓
         └── restored ←───────┘ (猶予期間内に復元)
```

### Step 3: Supabase テーブル設計

```sql
-- ユーザーテーブルへのカラム追加
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ DEFAULT NULL;
ALTER TABLE users ADD COLUMN deletion_scheduled_at TIMESTAMPTZ DEFAULT NULL;
ALTER TABLE users ADD COLUMN deletion_reason TEXT DEFAULT NULL;

-- 削除リクエスト時
-- deleted_at = NOW()
-- deletion_scheduled_at = NOW() + INTERVAL '30 days'

-- RLS ポリシー: 論理削除されたユーザーのデータを非表示
CREATE POLICY "Hide soft-deleted user data"
  ON user_data FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = user_data.user_id
      AND users.deleted_at IS NULL
    )
  );

-- 監査ログテーブル
CREATE TABLE deletion_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  action TEXT NOT NULL, -- 'requested', 'soft_deleted', 'restored', 'hard_deleted'
  target_table TEXT,
  target_id UUID,
  performed_by UUID, -- 実行者（ユーザー自身 or システム）
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Step 4: Stripe連携解約フロー

```markdown
## Stripe 連携削除フロー

### 手順
1. アクティブなサブスクリプションのキャンセル
   - `stripe.subscriptions.cancel(subscriptionId)`
   - 即時キャンセル（期間終了まで待たない）
2. 未払いインボイスの処理
   - `stripe.invoices.voidInvoice(invoiceId)`
3. Payment Method の削除
   - `stripe.paymentMethods.detach(paymentMethodId)`
4. Customer オブジェクトの削除
   - `stripe.customers.del(customerId)`
   - 注意: 税務記録のため、Invoice データはStripe側で保持される

### 注意点
- Stripe Customer削除前にサブスクリプションを必ずキャンセル
- Webhook で削除完了を確認
- 削除失敗時のリトライ機構
```

### Step 5: 外部サービス削除チェックリスト

```markdown
## 外部サービス削除チェックリスト

| サービス | 削除対象データ | 削除方法 | API有無 |
|---------|--------------|---------|---------|
| Supabase | ユーザーデータ全般 | SQL DELETE | ✅ |
| Stripe | Customer, Subscription | Stripe API | ✅ |
| Sentry | ユーザー関連エラーログ | Sentry API (Data Scrubbing) | ✅ |
| Resend | メールアドレス、送信履歴 | Resend API | ✅ |
| Vercel Analytics | 匿名化済みのため対象外 | - | - |
| ファイルストレージ | アップロードファイル | Supabase Storage API | ✅ |

### 削除順序
1. アプリケーションデータ（Supabase）
2. 決済データ（Stripe）
3. 監視データ（Sentry）
4. 通信データ（Resend）
5. ファイルデータ（Storage）
```

### Step 6: 削除確認UI

```markdown
## 削除確認UI設計

### アカウント削除ページ (/settings/delete-account)
1. 削除の影響説明
   - 「アカウントを削除すると以下が失われます:」
   - データ一覧（プロジェクト数、ファイル数等）
2. 削除理由ヒアリング（任意、チャーン分析用）
   - [ ] もう使わなくなった
   - [ ] 別のサービスに乗り換えた
   - [ ] 料金が高い
   - [ ] 必要な機能がない
   - [ ] その他（自由記述）
3. 確認ダイアログ
   - 「アカウント名を入力して確認してください」
   - 30日以内なら復元可能であることを明示
4. 削除実行ボタン（赤色、2段階確認）
```

### Step 7: 削除ジョブ実装

```typescript
/**
 * 物理削除ジョブ（Supabase Edge Functions / cron）
 *
 * 毎日1回実行:
 * - deletion_scheduled_at が過去のユーザーを検索
 * - 外部サービスからデータ削除
 * - Supabaseからデータ物理削除
 * - 監査ログ記録
 * - 削除完了通知メール送信
 */

// cron設定: 0 3 * * * (毎日午前3時)
```

削除ジョブの実装:
- Supabase Edge Functions または pg_cron を使用
- 冪等性の確保（同じジョブが重複実行されても安全）
- エラー時のリトライ（最大3回、指数バックオフ）
- 削除失敗時のアラート通知

### Step 8: 削除完了通知メール

```markdown
## メールテンプレート

### 削除リクエスト受付メール
件名: アカウント削除リクエストを受け付けました
本文:
- 30日以内であればログインして復元可能
- 30日後に完全に削除される旨
- サポート連絡先

### 削除完了メール
件名: アカウントの削除が完了しました
本文:
- 削除が完了した旨
- 削除されたデータの概要
- 再度利用したい場合は新規登録が必要な旨
```

### Step 9: 監査ログ

```markdown
## 監査ログ設計

### 記録項目
- who: 誰が（ユーザー自身 / システム / 管理者）
- when: いつ（タイムスタンプ）
- what: 何を（対象テーブル、レコードID）
- action: どうした（requested / soft_deleted / restored / hard_deleted）
- metadata: 補足情報（削除理由、外部サービス削除結果等）

### 保持期間
- 監査ログ自体は法的要件に基づき [N年] 保持
- 個人を特定できない形で保持（ユーザーIDのハッシュ化等）
```

## 出力ファイル

- `src/app/api/gdpr/delete/route.ts` - 削除リクエストAPI
- `src/app/api/gdpr/restore/route.ts` - 復元API
- `supabase/migrations/xxx_add_deletion_columns.sql` - マイグレーション
- `supabase/functions/cleanup-deleted-users/index.ts` - 物理削除ジョブ
- `docs/data-deletion-procedure.md` - データ削除手順書

## 品質チェック

- [ ] 30日猶予期間が設定されているか
- [ ] 猶予期間内の復元フローが実装されているか
- [ ] Stripe連携（サブスクキャンセル→Customer削除）が正しい順序か
- [ ] 外部サービス削除チェックリストに漏れがないか
- [ ] 削除ジョブが冪等性を持っているか
- [ ] 監査ログが全削除操作を記録しているか
- [ ] 削除確認UIに2段階確認があるか
- [ ] 削除完了通知メールが設計されているか
- [ ] GDPR Art.17 の例外（法的保持義務）が考慮されているか
