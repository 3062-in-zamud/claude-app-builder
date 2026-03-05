# ランブックテンプレート集

## 1. DB接続エラー

```
症状: "Too many connections" / "Connection timeout"

手順:
1. Supabase Dashboard → Database → Active connections 確認
2. 異常なコネクション数の場合:
   - PgBouncer設定確認（Settings → Database → Connection Pooling）
   - Pool Mode: Transaction を推奨
3. 特定クエリが原因の場合:
   SELECT pid, query, state FROM pg_stat_activity WHERE state = 'active';
   SELECT pg_terminate_backend(pid);  -- 問題クエリを終了
4. アプリ側の接続プール設定確認（max connections）
5. 復旧確認: /api/health のHTTP 200を確認
```

## 2. デプロイ失敗（provider別）

```
症状: Build Error / Deploy失敗 / Timeout

手順:
1. deployment_provider を確認（docs/tech-stack.md）
2. providerログ確認:
   - vercel: Dashboard → Deployments
   - cloudflare-pages: Dashboard → Pages → Deployments
3. ビルドエラーの場合:
   - ローカルで build コマンドを再実行
   - 依存関係のロックファイル/環境変数差分を確認
4. タイムアウトの場合:
   - Functions実行時間上限と重い処理を確認
5. ロールバック:
   - vercel: `vercel rollback`
   - cloudflare-pages: 直前の安定デプロイを再アクティブ化
```

## 3. 認証エラー

```
症状: ログイン失敗 / セッション切れ多発

手順:
1. Supabase Dashboard → Authentication → Users でユーザー状態確認
2. JWT設定確認:
   - NEXT_PUBLIC_SUPABASE_URL / ANON_KEY が正しいか
   - JWT expiry 設定（Settings → Auth）
3. Cookie設定: httpOnly, secure, SameSite
4. CORS設定: 本番originが許可されているか
5. Supabase Auth Status を確認
```

## 4. 決済エラー（Stripe）

```
症状: 課金失敗 / Webhook未到達

手順:
1. Stripe Dashboard → Events で最新イベント確認
2. Webhook未到達の場合:
   - endpoint URL の整合を確認
   - 失敗イベント詳細を確認
   - STRIPE_WEBHOOK_SECRET を確認
3. 課金失敗の場合:
   - カード情報・Dunning設定確認
4. 必要なら手動リカバリとユーザー通知
```

## 5. パフォーマンス劣化

```
症状: レスポンス遅延 / Core Web Vitals 悪化

手順:
1. provider Analytics / RUM で劣化箇所を特定
2. Sentry Performance でSlow Transaction確認
3. DB起因の場合:
   - Supabase Query Performance確認
   - EXPLAIN ANALYZE でスロークエリ特定
   - インデックス追加を検討
4. フロント起因の場合:
   - bundle-analyzer で大きな依存を特定
   - 動的import / code split を適用
5. 改善後に Lighthouse CI で再確認
```

## 6. セキュリティインシデント

```
症状: 不正アクセス / データ漏洩の疑い

手順（即時対応）:
1. 影響範囲を特定
2. 攻撃経路を遮断:
   - 侵害APIキーを無効化（Supabase/Stripe/provider）
   - 影響ユーザーのセッション無効化
3. 証拠保全: ログのスナップショット取得
4. 通知:
   - GDPR対象なら72時間以内に監督当局通知
   - 影響ユーザー通知
5. 修正:
   - 脆弱性修正
   - シークレットローテーション
6. ポストモーテム実施
```
