# ゼロダウンタイム・デプロイ戦略

## Expand-Contract パターン

DBスキーマ変更時にダウンタイムを発生させないための段階的マイグレーション手法。

### 概要

```
Phase 1: Expand（拡張）
  → 新カラム/テーブルを追加（既存は変更しない）
  → 新旧両方のカラムにデータを書き込むコードをデプロイ

Phase 2: Migrate（移行）
  → 既存データを新カラムにバックフィル
  → 新カラムからの読み取りに切り替え

Phase 3: Contract（縮小）
  → 旧カラム/テーブルを削除（次回のデプロイサイクルで）
```

### 例: カラム名変更（user_name → display_name）

**NG: 一括変更（ダウンタイム発生）**
```sql
ALTER TABLE users RENAME COLUMN user_name TO display_name;
```

**OK: Expand-Contract（ダウンタイムなし）**

```sql
-- Step 1: Expand - 新カラム追加
ALTER TABLE users ADD COLUMN display_name TEXT;

-- Step 2: Migrate - データコピー
UPDATE users SET display_name = user_name WHERE display_name IS NULL;

-- Step 3: Contract - 旧カラム削除（次回デプロイで）
-- ALTER TABLE users DROP COLUMN user_name;
```

### 例: テーブル分割

```sql
-- Step 1: Expand - 新テーブル作成
CREATE TABLE user_profiles (
  user_id UUID REFERENCES users(id),
  bio TEXT,
  avatar_url TEXT
);

-- Step 2: Migrate - データ移行
INSERT INTO user_profiles (user_id, bio, avatar_url)
SELECT id, bio, avatar_url FROM users;

-- Step 3: Contract - 旧カラム削除（次回デプロイで）
-- ALTER TABLE users DROP COLUMN bio, DROP COLUMN avatar_url;
```

## Vercel のデプロイ特性

Vercel はデフォルトで **Immutable Deployment** を採用:

- 各デプロイは固有のURLを持つ
- `--prod` でプロダクションエイリアスを切り替え
- ロールバックは `vercel rollback` で即座に前のデプロイに戻せる
- Preview デプロイでステージングテストが可能

### Blue-Green 概念（Vercel 版）

```
Blue（現在の本番）: https://app-xxxx.vercel.app → app.vercel.app
Green（新デプロイ）: https://app-yyyy.vercel.app

1. Green をデプロイ（Preview）
2. Green でスモークテスト実施
3. vercel --prod で Green を本番に昇格
4. 問題発生時: vercel rollback で Blue に戻す
```

## Supabase マイグレーション注意点

| 操作 | リスク | 推奨手法 |
|------|--------|---------|
| カラム追加 | 低 | そのまま ADD COLUMN |
| カラム削除 | 高 | Expand-Contract（2段階で） |
| カラム名変更 | 高 | 新カラム追加 → データ移行 → 旧削除 |
| NOT NULL 追加 | 中 | DEFAULT 値を先に設定してから制約追加 |
| インデックス追加 | 低 | CONCURRENTLY オプション推奨 |
| テーブル削除 | 高 | 参照がないことを確認してから |

## チェックリスト

- [ ] 破壊的変更（DROP/RENAME）が含まれていないか
- [ ] Expand-Contract が必要な変更を特定したか
- [ ] Preview デプロイでスモークテスト完了か
- [ ] ロールバック手順を確認したか
