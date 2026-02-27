# Supabase RLS（Row Level Security）チェックリスト

## なぜ RLS が必要か

Supabase は PostgreSQL の RLS を使用してデータアクセスを制御します。RLS を設定しないと、`anon` キー（フロントエンドで公開される）でテーブルの全データにアクセスできます。

## チェック手順

### 1. RLS 未設定テーブルの確認

```sql
-- Supabase SQL Editor で実行
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
-- rowsecurity が false のテーブルはすべて修正が必要
```

### 2. 全テーブルに RLS を有効化

```sql
-- 各テーブルに対して実行
ALTER TABLE [table_name] ENABLE ROW LEVEL SECURITY;
```

### 3. 基本ポリシーパターン

#### パターンA: 認証ユーザーのみ・自分のデータのみ

```sql
-- SELECT
CREATE POLICY "Users can view own data"
ON [table_name] FOR SELECT
USING (auth.uid() = user_id);

-- INSERT
CREATE POLICY "Users can insert own data"
ON [table_name] FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- UPDATE
CREATE POLICY "Users can update own data"
ON [table_name] FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- DELETE
CREATE POLICY "Users can delete own data"
ON [table_name] FOR DELETE
USING (auth.uid() = user_id);
```

#### パターンB: 公開データ（誰でも読める・認証ユーザーのみ書ける）

```sql
-- 誰でも読める
CREATE POLICY "Public read access"
ON [table_name] FOR SELECT
USING (true);

-- 認証ユーザーのみ書ける
CREATE POLICY "Authenticated users can insert"
ON [table_name] FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);
```

#### パターンC: 管理者のみ（Service Role）

```sql
-- service_role を持つ場合のみアクセス可能
-- サーバーサイド API から supabaseAdmin クライアントで実行
```

### 4. ポリシー確認

```sql
-- 設定済みポリシーの確認
SELECT tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;
```

### 5. よくあるミス

| ミス | 結果 | 修正 |
|------|------|------|
| RLS 有効化のみ・ポリシーなし | すべてのアクセスがブロック | SELECT/INSERT/UPDATE/DELETE ポリシーを追加 |
| user_id フィールドなし | ユーザー別フィルタ不可 | マイグレーションで user_id カラムを追加 |
| USING と WITH CHECK の混同 | 意図しないアクセス | SELECT/DELETE は USING、INSERT は WITH CHECK、UPDATE は両方 |
