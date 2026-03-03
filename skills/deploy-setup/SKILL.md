---
name: deploy-setup
description: |
  What: Supabase + Vercel への本番デプロイを実行し、ローンチ素材を生成する
  When: Phase 7（release-checklist 全項目 ✅ 後）
  How: デプロイ前チェック → ログイン確認 → 環境変数設定 → DB マイグレーション → vercel --prod → スモークテスト → 素材生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Bash
---

# deploy-setup: デプロイ実行

## ワークフロー

### Step 0: デプロイ前チェック（必須）

デプロイ前に環境の整合性を確認する。

```bash
echo "=== デプロイ前チェック ==="

# 1. DB diff確認（未適用マイグレーションの確認）
echo "📋 マイグレーション差分チェック..."
supabase db diff 2>/dev/null | head -20
if [ $? -eq 0 ]; then
  echo "✅ マイグレーション差分確認完了"
else
  echo "⚠️  supabase db diff の実行に失敗。手動確認してください"
fi

# 2. 環境変数差分チェック（.env.example vs Vercel）
echo ""
echo "📋 環境変数差分チェック..."
if [ -f ".env.example" ]; then
  EXPECTED_VARS=$(grep -v '^#' .env.example | grep '=' | cut -d'=' -f1 | sort)
  VERCEL_VARS=$(vercel env ls production 2>/dev/null | grep -v '^>' | awk '{print $1}' | sort)
  MISSING=$(comm -23 <(echo "$EXPECTED_VARS") <(echo "$VERCEL_VARS") 2>/dev/null)
  if [ -n "$MISSING" ]; then
    echo "⚠️  Vercel に未設定の変数:"
    echo "$MISSING"
  else
    echo "✅ 環境変数は全て設定済み"
  fi
else
  echo "⚠️  .env.example が見つかりません"
fi

# 3. ビルドチェック
echo ""
echo "📋 ローカルビルドチェック..."
npm run build 2>&1 | tail -5
if [ $? -eq 0 ]; then
  echo "✅ ビルド成功"
else
  echo "❌ ビルド失敗。修正してから再実行してください"
  exit 1
fi
```

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

> **注意**: 値に `=` が複数含まれる場合（例: base64エンコードされたキー）も
> 正しく処理します（`key="${line%%=*}"` / `value="${line#*=}"` を使用）。
> ただし改行を含む値は非対応。その場合は Vercel Dashboard で手動設定してください。

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
    printf '%s' "$value" | vercel env add "$key" production 2>/dev/null || {
      echo "  ⚠️  $key の設定に失敗しました。Vercel Dashboard で手動設定してください"
    }
  done < .env.local
  echo "✅ 環境変数の設定完了"
else
  echo "⚠️  .env.local が見つかりません"
  echo "   Vercel ダッシュボードで手動設定が必要です（追加介入ポイント）"
fi
```

⚠️ **SERVICE_ROLE_KEY は必ず Vercel ダッシュボードで設定。コードには含めない**

### Step 3: Supabase マイグレーション（本番）

**Expand-Contract パターン**を推奨。詳細は `references/zero-downtime-deploy-strategy.md` 参照。

1. **Expand**: 新カラム/テーブル追加（既存は変更しない）
2. **Deploy**: 新旧両対応コードをデプロイ
3. **Migrate**: データ移行
4. **Contract**: 旧カラム/テーブル削除（次回デプロイで）

```bash
# マイグレーション状態確認
supabase db status

# ⚠️ 破壊的変更がないか確認（DROP/ALTER/RENAME）
supabase db diff 2>/dev/null | grep -iE "DROP|ALTER.*RENAME|ALTER.*DROP" && {
  echo "⚠️  破壊的変更が含まれています。Expand-Contract パターンを検討してください"
  echo "   参照: references/zero-downtime-deploy-strategy.md"
}

# 本番 DB に適用
supabase db push

# 適用確認
supabase db status
echo "✅ マイグレーション完了"
```

> **注意**: Supabase は forward-only マイグレーション。ロールバックは新しいマイグレーションで
> 逆操作を記述する必要がある。詳細は `references/rollback-playbook.md` 参照。

### Step 3.5: ステージング環境でのプレビュー確認（推奨）

Vercel Preview Deploy を活用してステージングテストを行う。

```bash
# Preview デプロイ（本番前の確認）
PREVIEW_URL=$(vercel --yes 2>/dev/null | grep -E "^https://" | tail -1)
if [ -n "$PREVIEW_URL" ]; then
  echo "🔍 Preview URL: $PREVIEW_URL"
  echo "   本番デプロイ前にこの URL で動作確認してください"

  # Preview に対してスモークテスト実行
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$PREVIEW_URL" 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo "✅ Preview デプロイ正常（HTTP $STATUS）"
  else
    echo "⚠️  Preview デプロイに問題あり（HTTP $STATUS）。本番デプロイを中止してください"
  fi
else
  echo "⚠️  Preview URL の取得に失敗。本番デプロイに直接進みます"
fi
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

### Step 5: デプロイ後スモークテスト

詳細なスモークテスト項目は `references/post-deploy-verification.md` 参照。

```bash
echo "=== スモークテスト実行 ==="
SMOKE_PASS=0
SMOKE_FAIL=0

# 1. ヘルスチェック（最大30秒待機）
echo "📋 1/4 ヘルスチェック..."
for i in $(seq 1 10); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL/api/health" 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo "  ✅ /api/health → HTTP $STATUS"
    SMOKE_PASS=$((SMOKE_PASS + 1))
    break
  fi
  if [ "$i" = "10" ]; then
    echo "  ❌ /api/health → タイムアウト"
    SMOKE_FAIL=$((SMOKE_FAIL + 1))
  fi
  sleep 3
done

# 2. トップページ表示確認
echo "📋 2/4 トップページ..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL" 2>/dev/null || echo "000")
if [ "$STATUS" = "200" ]; then
  echo "  ✅ / → HTTP $STATUS"
  SMOKE_PASS=$((SMOKE_PASS + 1))
else
  echo "  ❌ / → HTTP $STATUS"
  SMOKE_FAIL=$((SMOKE_FAIL + 1))
fi

# 3. 主要APIエンドポイント確認
echo "📋 3/4 API確認..."
for endpoint in "/api/health"; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL$endpoint" 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "401" ]; then
    echo "  ✅ $endpoint → HTTP $STATUS"
    SMOKE_PASS=$((SMOKE_PASS + 1))
  else
    echo "  ❌ $endpoint → HTTP $STATUS"
    SMOKE_FAIL=$((SMOKE_FAIL + 1))
  fi
done

# 4. 静的アセット確認
echo "📋 4/4 静的アセット..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL/favicon.ico" 2>/dev/null || echo "000")
if [ "$STATUS" = "200" ]; then
  echo "  ✅ /favicon.ico → HTTP $STATUS"
  SMOKE_PASS=$((SMOKE_PASS + 1))
else
  echo "  ⚠️  /favicon.ico → HTTP $STATUS（致命的ではない）"
fi

# 結果サマリー
echo ""
echo "=== スモークテスト結果 ==="
echo "  ✅ Pass: $SMOKE_PASS"
echo "  ❌ Fail: $SMOKE_FAIL"
if [ "$SMOKE_FAIL" -gt 0 ]; then
  echo "  ⚠️  スモークテスト失敗あり。ロールバックを検討してください"
  echo "  📖 参照: references/rollback-playbook.md"
fi
```

### Step 5.5: ロールバック戦略

スモークテストが失敗した場合のロールバック手順。詳細は `references/rollback-playbook.md` 参照。

```bash
# Vercel ロールバック（直前の安定版に戻す）
# vercel rollback

# Supabase はforward-onlyのため、逆マイグレーションを作成して適用
# supabase migration new rollback_<対象>
# supabase db push
```

> **判断基準**: ヘルスチェック失敗 or エラー率5%超 → 即座にロールバック。
> それ以外は影響範囲を評価してから判断。

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

- [ ] デプロイ前チェック（ビルド成功・環境変数差分なし）
- [ ] 環境変数が Vercel ダッシュボードに設定されているか（コミットに含まない）
- [ ] Supabase マイグレーションが本番に適用されているか（Expand-Contract確認）
- [ ] ステージング（Preview）環境での動作確認済み
- [ ] スモークテスト全項目パス
- [ ] ロールバック手順を確認済み
- [ ] ローンチ素材が生成されているか
