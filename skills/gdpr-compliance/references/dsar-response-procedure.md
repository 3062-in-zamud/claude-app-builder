# DSAR（データ主体アクセス要求）対応手順

## 免責事項

**このドキュメントはテンプレートです。法的効力については必ずDPOまたは法律専門家にレビューを依頼してください。**

## 6つの権利と対応

| 権利 | GDPR条文 | 対応期限 | 実装 |
|------|---------|---------|------|
| アクセス権 | Art.15 | 30日 | データエクスポートAPI |
| 訂正権 | Art.16 | 30日 | プロフィール編集UI |
| 削除権 | Art.17 | 30日 | data-deletionスキル連携 |
| 処理制限権 | Art.18 | 30日 | アカウント凍結機能 |
| データポータビリティ | Art.20 | 30日 | JSON/CSVエクスポート |
| 異議申立権 | Art.21 | 即時 | マーケティングオプトアウト |

## 対応フロー

```
1. 受付 → 2. 本人確認 → 3. 対応 → 4. 回答 → 5. 記録
                (5営業日)   (20営業日)  (30日以内)
```

## 本人確認

- ログイン済みユーザー: セッション認証で十分
- メール経由の要求: 登録メールアドレスからの送信を確認
- 追加確認が必要な場合: 身分証のコピー要求（最小限の情報のみ）

## Supabase データ抽出 SQL

```sql
-- ユーザーの全データをエクスポート
SELECT json_build_object(
  'profile', (SELECT row_to_json(p) FROM profiles p WHERE p.user_id = $1),
  'subscriptions', (SELECT json_agg(row_to_json(s)) FROM subscriptions s WHERE s.user_id = $1),
  'activity_log', (SELECT json_agg(row_to_json(a)) FROM activity_logs a WHERE a.user_id = $1)
) AS user_data;
```

## 対応ログテーブル

```sql
CREATE TABLE dsar_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  request_type TEXT NOT NULL, -- access, rectification, erasure, restriction, portability, objection
  status TEXT DEFAULT 'received', -- received, verified, processing, completed, rejected
  received_at TIMESTAMPTZ DEFAULT now(),
  verified_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  response_notes TEXT,
  CONSTRAINT response_within_30days CHECK (
    completed_at IS NULL OR completed_at <= received_at + INTERVAL '30 days'
  )
);
```

## チェックリスト

- [ ] 全6権利の対応手順が文書化されているか
- [ ] 本人確認プロセスが定義されているか
- [ ] 30日以内の回答が保証できるか
- [ ] 対応ログが記録されるか
- [ ] データエクスポート形式（JSON/CSV）が実装されているか
