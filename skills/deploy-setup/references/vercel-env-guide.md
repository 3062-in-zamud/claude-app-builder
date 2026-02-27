# Vercel 環境変数設定ガイド

## 設定方法

### CLI での設定

```bash
# 対話形式で値を入力
vercel env add VARIABLE_NAME production

# 確認
vercel env ls production
```

### ダッシュボードでの設定

1. [vercel.com](https://vercel.com) にログイン
2. プロジェクト選択 → Settings → Environment Variables
3. 変数名・値・スコープ（Production/Preview/Development）を入力

## 重要な注意事項

| 変数プレフィックス | 露出 | 用途 |
|-----------------|------|------|
| `NEXT_PUBLIC_*` | クライアント側に露出 | anon key, APP_URL など |
| （プレフィックスなし） | サーバーサイドのみ | service_role_key, SENTRY_DSN など |

## .env.example との対応

```bash
# .env.example の各変数を Vercel に設定する
while IFS= read -r line; do
  # コメントと空行をスキップ
  [[ "$line" =~ ^#.*$ ]] && continue
  [[ -z "$line" ]] && continue

  var_name="${line%%=*}"
  echo "設定が必要: $var_name"
done < .env.example
```
