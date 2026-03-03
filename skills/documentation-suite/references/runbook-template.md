# Runbook テンプレート（オペレーション手順書）

## 概要

Runbook は障害対応やデプロイなどの運用手順を標準化するドキュメント。
「誰が対応しても同じ結果が得られる」ことを目指す。

## テンプレート

```markdown
# Runbook: [プロダクト名]

## 目次
1. デプロイ手順
2. ロールバック手順
3. 環境変数の変更
4. 障害対応

---

## 1. デプロイ手順

### 通常デプロイ（Vercel）

main ブランチへのマージで自動デプロイされる。

**手動デプロイが必要な場合**:
\```bash
# 1. 本番にデプロイ
vercel --prod

# 2. デプロイ確認
curl -s https://[app-url]/api/health | jq .
# 期待: { "status": "ok", "timestamp": "..." }

# 3. Sentry でエラー急増がないか確認
# https://sentry.io/organizations/[org]/issues/
\```

### データベースマイグレーション

\```bash
# 1. マイグレーション内容の確認
supabase db diff

# 2. ローカルでテスト
supabase db reset

# 3. 本番に適用
supabase db push

# 4. 適用結果の確認
supabase db remote status
\```

---

## 2. ロールバック手順

### Vercel ロールバック

\```bash
# 1. 直前のデプロイ一覧を確認
vercel ls --prod

# 2. 問題のないバージョンにロールバック
vercel rollback [deployment-url]

# 3. ロールバック確認
curl -s https://[app-url]/api/health | jq .
\```

### データベースロールバック

**注意**: DB ロールバックは最終手段。データ損失のリスクがある。

\```bash
# 1. バックアップからの復元（Supabase Dashboard）
# Settings > Database > Backups > Restore

# 2. または手動でマイグレーションを戻す
# （事前に down マイグレーションを用意しておく）
\```

---

## 3. 環境変数の変更

### Vercel 環境変数

\```bash
# 1. 現在の環境変数を確認
vercel env ls

# 2. 環境変数を追加/更新
vercel env add [KEY] production

# 3. 再デプロイ（環境変数変更を反映）
vercel --prod
\```

### Supabase 環境変数

Supabase Dashboard > Settings > API で確認・変更。
変更後は Vercel 側の環境変数も更新が必要。

---

## 4. 障害対応

### 4.1 サイトがダウンしている

**症状**: ユーザーからアクセスできない報告

\```
1. ステータス確認
   curl -s -o /dev/null -w "%{http_code}" https://[app-url]

2. Vercel ステータスページ確認
   https://www.vercel-status.com/

3. Supabase ステータスページ確認
   https://status.supabase.com/

4. エラーログ確認
   Sentry: https://sentry.io/organizations/[org]/issues/
   Vercel: vercel logs --prod

5. 対処:
   - Vercel 障害 → 復旧を待つ（通常30分以内）
   - Supabase 障害 → 復旧を待つ + キャッシュで凌ぐ
   - アプリケーションエラー → ロールバック（Section 2参照）
\```

### 4.2 レスポンスが遅い

**症状**: ページ読み込みが5秒以上かかる

\```
1. 原因の特定
   - Vercel Analytics でレスポンス時間を確認
   - Supabase Dashboard でクエリパフォーマンスを確認

2. よくある原因と対処:
   - DB クエリが遅い → インデックス追加
   - API ルートが遅い → キャッシュ追加（ISR or Redis）
   - 画像が重い → next/image で最適化
   - サードパーティスクリプト → 遅延読み込み

3. 緊急対処:
   - ISR の revalidate 値を長くする
   - 重い機能を一時的に無効化
\```

### 4.3 認証が動作しない

**症状**: ログインできない/セッションが切れる

\```
1. Supabase Auth ステータス確認
   supabase status

2. 環境変数の確認
   - NEXT_PUBLIC_SUPABASE_URL が正しいか
   - NEXT_PUBLIC_SUPABASE_ANON_KEY が正しいか

3. よくある原因:
   - Supabase の JWT シークレットが変更された
   - Auth メールテンプレートの URL が間違っている
   - CORS 設定が不正
\```

### 4.4 エラーが急増している

**症状**: Sentry でエラー件数が急増

\```
1. Sentry でエラーの詳細を確認
   - 同一エラーか、複数種類か
   - 影響を受けるユーザー数
   - 発生し始めた時刻

2. 直近のデプロイとの関連確認
   vercel ls --prod
   # 最後のデプロイ時刻とエラー開始時刻を比較

3. 対処:
   - デプロイが原因 → ロールバック
   - 外部サービスが原因 → フォールバック or 復旧待ち
   - データが原因 → 問題データの特定と修正
\```

---

## 連絡先

| 役割 | 担当 | 連絡方法 |
|------|------|---------|
| プロダクトオーナー | [名前] | [連絡先] |
| インフラ担当 | [名前] | [連絡先] |
| Vercel サポート | - | support@vercel.com |
| Supabase サポート | - | support@supabase.io |
```
