# インフラサービス代替比較マトリクス

## ホスティング

| | Vercel | Cloudflare Pages | Netlify | Railway |
|--|--------|-----------------|---------|---------|
| 無料枠 | 100GB帯域 | 無制限帯域 | 100GB帯域 | $5/月クレジット |
| Pro価格 | $20/月 | $25/月 | $19/月 | 使用量課金 |
| SSR | ✅ | ✅ (Workers) | ✅ | ✅ |
| Edge | ✅ | ✅ (最速) | ✅ (Edge Functions) | ❌ |
| Next.js最適化 | ✅ (開発元) | △ | △ | ✅ |
| 商用利用(無料) | ❌ 禁止 | ✅ | ✅ | ✅ |

## データベース

| | Supabase | PlanetScale | Neon | Railway Postgres |
|--|----------|------------|------|-----------------|
| 無料枠 | 500MB/2PJ | 5GB/1DB | 512MB | $5クレジット |
| Pro価格 | $25/月 | $29/月 | $19/月 | 使用量課金 |
| PostgreSQL | ✅ | ❌ (MySQL) | ✅ | ✅ |
| Auth内蔵 | ✅ | ❌ | ❌ | ❌ |
| RLS | ✅ | ❌ | ✅ | ✅ |
| Edge Functions | ✅ | ❌ | ❌ | ❌ |
| Branching | ❌ | ✅ | ✅ | ❌ |

## エラー監視

| | Sentry | GlitchTip | Highlight.io | Bugsnag |
|--|--------|-----------|-------------|---------|
| 無料枠 | 5Kイベント/月 | Self-hosted無料 | 500セッション/月 | 7日トライアル |
| Pro価格 | $26/月 | Self-hosted | $150/月 | $59/月 |
| ソースマップ | ✅ | ✅ | ✅ | ✅ |
| パフォーマンス | ✅ | △ | ✅ | ✅ |
| セッションリプレイ | ✅ | ❌ | ✅ | ❌ |
| セルフホスト | ❌ | ✅ | ✅ | ❌ |

## メール送信

| | Resend | Postmark | Amazon SES | SendGrid |
|--|--------|---------|-----------|---------|
| 無料枠 | 3K通/月 | 100通/月 | 62K通/月(12ヶ月) | 100通/日 |
| 価格 | $20/月(50K) | $15/月(10K) | $0.10/1K通 | $20/月(40K) |
| React Email | ✅ (開発元) | ❌ | ❌ | ❌ |
| 配信率 | 高 | 最高 | 高 | 中-高 |
| セットアップ | 簡単 | 簡単 | 複雑 | 中程度 |

## MRR別 推奨構成

| MRR | ホスティング | DB | 監視 | メール | 月額コスト |
|-----|------------|-----|------|--------|-----------|
| $0-1K | Vercel Pro | Supabase Pro | Sentry Free | Resend Free | ~$45 |
| $1K-5K | Vercel Pro | Supabase Pro | Sentry Team | Resend Pro | ~$90 |
| $5K+ | Vercel Pro | Supabase Team | Sentry Business | Resend Business | ~$700+ |
