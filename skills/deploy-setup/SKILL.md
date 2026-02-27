---
name: deploy-setup
description: |
  What: Supabase + Vercel への本番デプロイを実行し、ローンチ素材を生成する
  When: Phase 7（release-checklist 全項目 ✅ 後）
  How: ログイン確認 → 環境変数設定 → DB マイグレーション → vercel --prod → 素材生成
model: claude-haiku-4-5-20251001
allowed-tools:
  - Read
  - Write
  - Bash
---

# deploy-setup: デプロイ実行

## ワークフロー

### Step 1: ログイン状態確認（必須）

```bash
# Vercel ログイン確認
echo -n "Vercel: "
vercel whoami 2>/dev/null || {
  echo "❌ ログインが必要です"
  echo "   実行してください: vercel login"
  exit 1
}

# Supabase ログイン確認
echo -n "Supabase: "
supabase projects list 2>/dev/null | head -3 || {
  echo "❌ ログインが必要です"
  echo "   実行してください: supabase login"
  exit 1
}
```

### Step 2: 環境変数の設定

`.env.example` に記載された全変数を Vercel に設定:

```bash
# 環境変数の一括設定（Production のみ）
# 実際の値は .env.local を参照
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add SUPABASE_SERVICE_ROLE_KEY production
vercel env add NEXT_PUBLIC_APP_URL production
vercel env add SENTRY_DSN production
vercel env add NEXT_PUBLIC_SENTRY_DSN production
```

⚠️ **SERVICE_ROLE_KEY は必ず Vercel ダッシュボードで設定。コードには含めない**

### Step 3: Supabase マイグレーション（本番）

```bash
# マイグレーション状態確認
supabase db status

# 本番 DB に適用
supabase db push

# 適用確認
supabase db status
echo "✅ マイグレーション完了"
```

### Step 4: Vercel デプロイ

```bash
# 本番デプロイ
vercel --prod

# デプロイ URL を取得
DEPLOY_URL=$(vercel --prod --confirm 2>&1 | grep "https://" | tail -1)
echo "🚀 デプロイ URL: $DEPLOY_URL"
```

### Step 5: デプロイ後ヘルスチェック

```bash
# ヘルスチェック（最大30秒待機）
echo "ヘルスチェック中..."
for i in $(seq 1 10); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL/api/health" 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo "✅ ヘルスチェック成功 (HTTP $STATUS)"
    break
  fi
  echo "   待機中... ($i/10)"
  sleep 3
done
```

### Step 6: ローンチ素材生成（Sonnet にエスカレーション）

`docs/requirements.md` と `docs/brand-brief.md` を読み込み、以下を生成:

#### Product Hunt 投稿文

```
タイトル: [プロダクト名] - [キャッチコピー（60文字以内）]

説明:
[250文字以内の説明]
[どんな課題を解決するか]
[主要機能3点]
[誰のためのツールか]

リンク: [DEPLOY_URL]
```

#### Twitter/X 告知文（280文字以内）

```
🚀 [プロダクト名] をリリースしました！

[解決する課題を1文で]

✨ [機能1]
✨ [機能2]
✨ [機能3]

👉 [DEPLOY_URL]

#[タグ1] #[タグ2] #[タグ3]
```

#### LinkedIn 告知文

```
[より詳細な説明]
[課題と解決方法]
[技術スタック（オプション）]
[CTA]

[DEPLOY_URL]
```

### 出力

- デプロイ完了報告（URL + ヘルスチェック結果）
- `docs/launch-materials.md`（ローンチ素材）

### 品質チェック

- [ ] 環境変数が Vercel ダッシュボードに設定されているか（コミットに含まない）
- [ ] Supabase マイグレーションが本番に適用されているか
- [ ] デプロイ後にヘルスチェック URL が返答するか
- [ ] ローンチ素材が生成されているか
