# Supabase スケーリングガイド

## プラン別制限

| | Free | Pro ($25/月) | Team ($599/月) |
|--|------|-------------|----------------|
| DB容量 | 500MB | 8GB | 50GB |
| 帯域 | 5GB | 250GB | 無制限 |
| Edge Functions | 500K/月 | 2M/月 | 無制限 |
| 同時接続 | 制限あり | 制限緩和 | 高性能 |
| 推奨ユーザー数 | 0-100 | 100-10K | 10K+ |

## コネクションプーリング（PgBouncer）

Dashboard → Settings → Database → Connection Pooling

```
Pool Mode: Transaction（推奨）
  - 各クエリ実行時のみコネクション使用
  - 最も効率的

Pool Mode: Session
  - セッション全体でコネクション維持
  - Prepared Statements 使用時に必要
```

### Next.js での接続

```typescript
// lib/supabase/server.ts
import { createClient } from '@supabase/supabase-js';

// 通常接続（API Routes, Server Components）
export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  { db: { schema: 'public' } }
);

// プーリング接続（高負荷時）
// Supabase Dashboard のConnection Pooling URLを使用
```

## インデックス最適化

```sql
-- 遅いクエリの特定
SELECT
  query,
  calls,
  mean_exec_time,
  total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- インデックス使用状況
SELECT
  relname AS table,
  indexrelname AS index,
  idx_scan AS scans
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;  -- スキャン0のインデックスは不要かも

-- よく使うインデックスパターン
CREATE INDEX CONCURRENTLY idx_posts_user_created
  ON posts(user_id, created_at DESC);
```

## Edge Functions 活用

| ユースケース | 通常 API Route | Edge Function |
|-------------|---------------|---------------|
| レスポンス時間 | 100-300ms | 10-50ms |
| コールドスタート | あり | なし |
| リージョン | 固定 | ユーザー最寄り |
| 適切な場面 | DB操作 | 認証、リダイレクト、A/B |

## スケーリングチェックリスト

- [ ] PgBouncer が Transaction mode で設定されているか
- [ ] 頻繁なクエリにインデックスが設定されているか
- [ ] N+1 クエリが解消されているか
- [ ] 静的アセットにCDNキャッシュが効いているか
- [ ] ISR/SSG が適切に使われているか
