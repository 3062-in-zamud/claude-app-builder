# データ削除パイプライン設計

## 2段階削除フロー

```
[削除リクエスト] → [論理削除] → [30日猶予期間] → [物理削除]
                   (即時)      (復元可能)         (不可逆)
```

## 論理削除

```sql
-- ユーザーアカウント論理削除
UPDATE profiles SET
  deleted_at = now(),
  deletion_scheduled_at = now() + INTERVAL '30 days',
  email = 'deleted_' || id || '@deleted.local'  -- PII即時匿名化
WHERE user_id = $1;

-- アクセス無効化
UPDATE auth.users SET
  banned_until = '2999-12-31'::timestamptz
WHERE id = $1;
```

## 物理削除ジョブ（pg_cron）

```sql
-- 毎日0時に実行: 猶予期間超過データを物理削除
SELECT cron.schedule(
  'purge-deleted-users',
  '0 0 * * *',
  $$
    -- 1. ユーザーコンテンツ削除
    DELETE FROM posts WHERE user_id IN (
      SELECT user_id FROM profiles WHERE deletion_scheduled_at < now()
    );
    -- 2. プロフィール削除
    DELETE FROM profiles WHERE deletion_scheduled_at < now();
    -- 3. Supabase Auth ユーザー削除
    DELETE FROM auth.users WHERE id IN (
      SELECT user_id FROM profiles WHERE deletion_scheduled_at < now()
    );
  $$
);
```

## 外部サービス削除チェックリスト

| サービス | 削除方法 | API |
|---------|---------|-----|
| Stripe | Customer削除 | `stripe.customers.del(customerId)` |
| Sentry | ユーザーフィードバック削除 | Sentry API |
| Resend | コンタクト削除 | Resend API |
| Vercel Analytics | 匿名化済み（対応不要） | - |

## 監査ログテーブル

```sql
CREATE TABLE deletion_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  action TEXT NOT NULL, -- 'soft_delete', 'hard_delete', 'external_delete'
  target TEXT NOT NULL, -- 'profile', 'posts', 'stripe', 'sentry'
  performed_by TEXT NOT NULL, -- 'user', 'system_cron', 'admin'
  performed_at TIMESTAMPTZ DEFAULT now(),
  details JSONB
);
```

## 削除確認 UI

ユーザーに以下を表示:
1. 「アカウントを削除しますか？」確認ダイアログ
2. 30日以内なら復元可能であることの説明
3. 削除理由のヒアリング（任意、改善に活用）
4. パスワード再入力による本人確認
5. 最終確認ボタン

## チェックリスト

- [ ] 30日猶予期間が設定されているか
- [ ] PII が論理削除時に即時匿名化されるか
- [ ] 外部サービスの削除が全て実装されているか
- [ ] 監査ログが記録されるか
- [ ] 削除完了通知メールが送信されるか
