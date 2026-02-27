# Supabase マイグレーションガイド

## マイグレーション作成

```bash
# 新しいマイグレーションファイルを作成
supabase migration new [migration_name]
# → supabase/migrations/[timestamp]_[migration_name].sql が作成される

# SQLを記述後、ローカルで適用・テスト
supabase db reset  # ローカルDBをリセット + マイグレーション適用
```

## 本番への適用

```bash
# 本番環境に接続
supabase link --project-ref [project-id]

# マイグレーション状態確認（ローカル vs 本番の差分）
supabase db status

# 本番に適用
supabase db push

# 適用後の確認
supabase db status
```

## ロールバック

```bash
# Supabase は自動ロールバックに非対応のため手動で down マイグレーションを作成
supabase migration new rollback_[name]
# → 手動で DROP TABLE などの逆操作を記述
```

## RLS の確認

```bash
# RLS 設定の確認
supabase db query "
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
"
```
