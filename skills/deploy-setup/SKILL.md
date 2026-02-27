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
# .env.local から環境変数を読み込んで一括設定（非対話式）
if [ -f ".env.local" ]; then
  echo "環境変数を Vercel に設定中..."
  while IFS= read -r line; do
    # コメント行・空行をスキップ
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$line" ]] && continue
    key="${line%%=*}"           # 最初の = までをキーに
    value="${line#*=}"          # 最初の = 以降を全て値に（= を含む値も正しく取得）
    [ -z "$key" ] && continue
    vercel env add "$key" production "$value" 2>/dev/null || true
  done < .env.local
  echo "✅ 環境変数の設定完了"
else
  echo "⚠️  .env.local が見つかりません"
  echo "   Vercel ダッシュボードで手動設定が必要です（追加介入ポイント）"
fi
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
# 本番デプロイ（単一実行）
DEPLOY_URL=$(vercel --prod --yes 2>/dev/null | grep -E "^https://" | tail -1)
if [ -z "$DEPLOY_URL" ]; then
  echo "⚠️  デプロイURLの取得に失敗しました。Vercel Dashboardで確認してください"
else
  echo "🚀 デプロイ URL: $DEPLOY_URL"
fi
```

### Step 4.5: カスタムドメイン設定（オプション）

```bash
# カスタムドメインを設定する場合
echo "カスタムドメインを設定しますか？（スキップ可能）"
# 設定する場合:
# vercel domains add your-domain.com
# 表示されたDNSレコードをドメインレジストラで設定してください
echo "DNS設定後、数分〜24時間でSSL証明書が自動発行されます"
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

### Step 7: メール送信設定（オプション）

Resend（無料: 3,000通/月）の設定:

1. [Resend](https://resend.com) でアカウント作成・APIキー取得
2. 環境変数に追加:
   ```
   RESEND_API_KEY=re_xxxx
   ```
3. Vercel に設定:
   ```bash
   vercel env add RESEND_API_KEY production "re_xxxx"
   ```

### Step 8: カスタマーサポート設定（オプション）

Crisp（無料プランあり）の1行埋め込み:

```html
<!-- layout.tsx の <head> に追加 -->
<script>window.$crisp=[];window.CRISP_WEBSITE_ID="YOUR-CRISP-ID";(function(){d=document;s=d.createElement("script");s.src="https://client.crisp.chat/l.js";s.async=1;d.getElementsByTagName("head")[0].appendChild(s);})();</script>
```

[Crisp](https://crisp.chat) でアカウント作成後、Website IDを取得してください。

### 出力

- デプロイ完了報告（URL + ヘルスチェック結果）
- `docs/launch-materials.md`（ローンチ素材）

### 品質チェック

- [ ] 環境変数が Vercel ダッシュボードに設定されているか（コミットに含まない）
- [ ] Supabase マイグレーションが本番に適用されているか
- [ ] デプロイ後にヘルスチェック URL が返答するか
- [ ] ローンチ素材が生成されているか
