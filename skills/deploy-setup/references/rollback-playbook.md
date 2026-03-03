# ロールバック・プレイブック

## ロールバック判断基準

| 状況 | 判断 | アクション |
|------|------|-----------|
| ヘルスチェック失敗（/api/health 非200） | 即座にロールバック | Vercel rollback |
| エラー率 5% 超（Sentry） | 即座にロールバック | Vercel rollback |
| レスポンス遅延 3秒超（P95） | 影響範囲を評価 | 原因調査 → 判断 |
| UI表示崩れ（致命的） | 影響範囲を評価 | Vercel rollback or ホットフィックス |
| 一部機能のみ不具合 | 影響範囲を評価 | ホットフィックスを検討 |

## Vercel ロールバック手順

```bash
# 1. 直前の安定デプロイにロールバック
vercel rollback

# 2. 特定のデプロイIDに戻す場合
vercel rollback <deployment-id>

# 3. デプロイ一覧からIDを確認
vercel ls --prod
```

**所要時間**: 数秒（CDN キャッシュ反映含めて最大1分）

## Supabase ロールバック手順

Supabase は **forward-only マイグレーション**。ロールバックには逆操作のマイグレーションを作成する。

### パターン1: カラム追加のロールバック

```bash
# 逆マイグレーション作成
supabase migration new rollback_add_column_xxx

# 生成されたファイルに逆操作を記述:
# ALTER TABLE public.users DROP COLUMN IF EXISTS xxx;

# 本番に適用
supabase db push
```

### パターン2: テーブル追加のロールバック

```bash
supabase migration new rollback_create_table_xxx

# DROP TABLE IF EXISTS public.xxx CASCADE;

supabase db push
```

### パターン3: RLS ポリシー変更のロールバック

```bash
supabase migration new rollback_rls_xxx

# DROP POLICY IF EXISTS "xxx" ON public.table_name;
# CREATE POLICY "original_policy" ON public.table_name ...;

supabase db push
```

## ロールバック後の確認

```bash
# 1. ヘルスチェック
curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL/api/health"

# 2. 主要機能の動作確認
curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL"

# 3. Sentry でエラー率確認
echo "Sentry ダッシュボードでエラー率が正常に戻ったか確認"
```

## 予防策

1. **Expand-Contract パターン**を採用してダウンタイムを防ぐ
2. **Preview デプロイ**で事前に確認
3. **スモークテスト**を必ず実行
4. **ピーク時間帯を避けて**デプロイ
