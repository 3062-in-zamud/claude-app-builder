# ロールバック・プレイブック

## 判断基準

| 状況 | 判断 | アクション |
|------|------|-----------|
| `/api/health` 非200 | 即時ロールバック | provider別ロールバック |
| エラー率 5% 超 | 即時ロールバック | provider別ロールバック |
| 致命的UI崩れ | 影響評価後ロールバック | provider別ロールバック or hotfix |
| 一部機能不具合 | 影響評価 | hotfix優先 |

## provider別ロールバック

### Vercel

```bash
vercel ls --prod
vercel rollback
# または vercel rollback <deployment-id>
```

### Cloudflare Pages

```bash
wrangler pages deployment list --project-name "$CF_PAGES_PROJECT"
wrangler pages deployment promote <deployment-id> --project-name "$CF_PAGES_PROJECT"
```

## Supabase ロールバック（共通）

Supabase は forward-only。逆マイグレーションで戻す。

```bash
supabase migration new rollback_<target>
# 逆操作SQLを記述
supabase db push
```

## ロールバック後確認

```bash
curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL/api/health"
curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL"
```

## 予防策

1. Expand-Contract パターンを採用
2. 本番前にPreview/Stage検証
3. スモークテストを自動化
4. ピーク時間帯のデプロイ回避
