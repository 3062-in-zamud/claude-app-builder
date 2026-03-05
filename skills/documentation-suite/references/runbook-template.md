# Runbook テンプレート（オペレーション手順書）

## テンプレート

```markdown
# Runbook: [プロダクト名]

deployment_provider: [vercel | cloudflare-pages]

## 1. 通常デプロイ

### Vercel
\```bash
vercel --prod
curl -s https://[app-url]/api/health | jq .
\```

### Cloudflare Pages
\```bash
# tech-stack.md の cloudflare_build_command を実行
[cloudflare_build_command]
wrangler pages deploy [cloudflare_build_dir] --project-name [cloudflare_pages_project]
curl -s https://[app-url]/api/health | jq .
\```

## 2. DBマイグレーション（Supabase共通）

\```bash
supabase db diff
supabase db push
supabase db status
\```

## 3. ロールバック

### Vercel
\```bash
vercel ls --prod
vercel rollback [deployment-id]
\```

### Cloudflare Pages
\```bash
wrangler pages deployment list --project-name [project]
wrangler pages deployment promote [deployment-id] --project-name [project]
\```

### Supabase（共通）
\```bash
supabase migration new rollback_[target]
supabase db push
\```

## 4. 環境変数変更

### Vercel
\```bash
vercel env ls
vercel env add [KEY] production
vercel --prod
\```

### Cloudflare Pages
\```bash
wrangler pages secret put [KEY] --project-name [project]
# 必要なら再デプロイ
\```

## 5. 障害対応

1. 監視確認（Sentry + provider別Analytics/Logs）
2. providerステータス確認（Vercel/Cloudflare）
3. 15分以内に一次報告
4. 影響拡大時は即ロールバック

## 6. 連絡先

| 連絡先 | URL/メール |
|--------|-----------|
| Vercel Support | support@vercel.com |
| Cloudflare Support | support.cloudflare.com |
| Supabase Support | support@supabase.com |
| Sentry Support | support@sentry.io |
```
