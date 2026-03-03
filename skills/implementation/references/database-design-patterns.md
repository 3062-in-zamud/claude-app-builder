# Supabase 特化 DB 設計パターン

## テーブル設計の基本

### 必須カラム

全テーブルに以下を含める:

```sql
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  -- ビジネスカラム
  title TEXT NOT NULL,
  body TEXT,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  -- 必須メタカラム
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  deleted_at TIMESTAMPTZ  -- Soft Delete 用（NULL = 未削除）
);

-- updated_at 自動更新トリガー
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

### UUID vs Serial

| 比較項目 | UUID | Serial/BigInt |
|---------|------|---------------|
| Supabase推奨 | Yes | - |
| URL安全性 | 推測困難 | 連番で推測可能 |
| 分散システム | 衝突なし | 調整が必要 |
| パフォーマンス | やや劣る | 高速 |
| **結論** | **デフォルトで使用** | 特殊要件時のみ |

## 正規化判断

### 3NF を基本とし、読み取り頻度に応じて非正規化

```sql
-- 正規化された設計（基本）
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  user_id UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  body TEXT NOT NULL,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
```

### 意図的な非正規化の判断基準

| 条件 | 判断 |
|------|------|
| 読み取り頻度が書き込みの10倍以上 | 非正規化を検討 |
| JOIN が3テーブル以上 | ビュー or 非正規化を検討 |
| データの一貫性が最重要 | 正規化を維持 |
| リアルタイム表示が必要 | 非正規化 + Realtime |

```sql
-- 非正規化の例: posts に author_name をキャッシュ
ALTER TABLE posts ADD COLUMN author_name TEXT;

-- トリガーで同期
CREATE OR REPLACE FUNCTION sync_author_name()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.author_name = (SELECT display_name FROM users WHERE id = NEW.user_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## インデックス戦略

### 作成基準

```sql
-- 1. WHERE句で頻繁に使うカラム
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- 2. 外部キー（JOINの高速化）
CREATE INDEX idx_comments_post_id ON comments(post_id);

-- 3. ORDER BY で使うカラム
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- 4. 複合インデックス（カーディナリティが高い順に）
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);

-- 5. Soft Delete フィルタ用の部分インデックス
CREATE INDEX idx_posts_active ON posts(user_id, created_at DESC)
  WHERE deleted_at IS NULL;

-- 6. 全文検索用
CREATE INDEX idx_posts_title_search ON posts
  USING GIN (to_tsvector('japanese', title));
```

### インデックスのアンチパターン

| アンチパターン | 問題 | 対策 |
|--------------|------|------|
| 全カラムにインデックス | 書き込み性能低下 | WHERE/JOIN/ORDER BY で使うもののみ |
| カーディナリティが低いカラム | 効果なし | boolean 単体のインデックスは避ける |
| 未使用インデックス | ストレージ浪費 | 定期的に `pg_stat_user_indexes` で確認 |

```sql
-- 未使用インデックスの確認
SELECT indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND schemaname = 'public';
```

## Soft Delete パターン

### 実装

```sql
-- deleted_at カラムを使用
ALTER TABLE posts ADD COLUMN deleted_at TIMESTAMPTZ;

-- 論理削除（UPDATE）
UPDATE posts SET deleted_at = now() WHERE id = $1;

-- アクティブレコードのみ取得（RLSで強制）
CREATE POLICY "Active records only"
  ON posts FOR SELECT
  USING (deleted_at IS NULL AND user_id = auth.uid());
```

### Supabase クライアント側

```typescript
// 論理削除
async function softDeletePost(postId: string) {
  const { error } = await supabase
    .from('posts')
    .update({ deleted_at: new Date().toISOString() })
    .eq('id', postId)

  return error ? err({ code: 'DELETE_ERROR', message: error.message, statusCode: 500 }) : ok(null)
}

// RLS があるので、取得時のフィルタは不要（ポリシーで強制）
async function getPosts(userId: string) {
  const { data, error } = await supabase
    .from('posts')
    .select('*')
    .order('created_at', { ascending: false })

  return data
}
```

## RLS（Row Level Security）テンプレート

```sql
-- テーブルの RLS を有効化
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- SELECT: 自分のアクティブなレコードのみ
CREATE POLICY "Users can view own active posts"
  ON posts FOR SELECT
  USING (auth.uid() = user_id AND deleted_at IS NULL);

-- INSERT: 自分のレコードのみ作成可能
CREATE POLICY "Users can create own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- UPDATE: 自分のレコードのみ更新可能
CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id AND deleted_at IS NULL)
  WITH CHECK (auth.uid() = user_id);

-- DELETE: 物理削除は禁止（Soft Delete を使う）
-- DELETE ポリシーは作成しない = 物理削除不可
```

## マイグレーション管理

```bash
# Supabase CLI でマイグレーション作成
supabase migration new create_posts_table

# マイグレーションファイルに SQL を記述
# supabase/migrations/YYYYMMDDHHMMSS_create_posts_table.sql

# ローカルで適用
supabase db reset

# リモートに適用
supabase db push
```

### マイグレーションのベストプラクティス

- 1マイグレーション = 1変更（テーブル作成 or カラム追加）
- ロールバック可能な変更を意識する
- データマイグレーションとスキーママイグレーションを分離する
- 本番適用前にローカルで `supabase db reset` で検証
