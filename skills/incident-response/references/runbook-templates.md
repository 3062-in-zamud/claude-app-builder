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
   SELECT pg_terminate_backend(pid);  -- 問題のクエリを終了
4. アプリ側の接続プール設定確認（max connections）
5. 復旧確認: ヘルスチェックエンドポイント確認
```

## 2. Vercel デプロイ失敗

```
症状: デプロイがBuild Error / Timeout

手順:
1. Vercel Dashboard → Deployments → 失敗デプロイのログ確認
2. ビルドエラーの場合:
   - ローカルで npm run build を実行して再現確認
   - 依存関係: npm ci --force → 再デプロイ
3. タイムアウトの場合:
   - Vercel Function のタイムアウト設定確認（Hobby: 10s, Pro: 60s）
4. 環境変数不足の場合:
   - vercel env ls で本番環境変数を確認
5. ロールバック:
   vercel rollback  # 前回の正常デプロイに戻す
```

## 3. 認証エラー

```
症状: ログインできない / セッション切れ

手順:
1. Supabase Dashboard → Authentication → Users でユーザー状態確認
2. JWT設定確認:
   - NEXT_PUBLIC_SUPABASE_URL / ANON_KEY が正しいか
   - JWT expiry 設定（Dashboard → Settings → Auth）
3. Cookie設定確認: httpOnly, secure, SameSite
4. CORS設定: allowed origins にデプロイURLが含まれているか
5. Supabase Auth のステータスページ確認
```

## 4. 決済エラー（Stripe）

```
症状: 課金失敗 / Webhook未到達

手順:
1. Stripe Dashboard → Events で最新イベント確認
2. Webhook未到達の場合:
   - Webhook endpoint URL が正しいか確認
   - Stripe Dashboard → Webhooks → 失敗イベントの詳細確認
   - STRIPE_WEBHOOK_SECRET が環境変数に設定されているか
3. 課金失敗の場合:
   - カード情報の有効期限確認
   - Dunning設定確認（Smart Retries ON か）
4. Customer Portal でユーザーにカード更新を案内
```

## 5. パフォーマンス劣化

```
症状: レスポンス遅延 / Lighthouse スコア低下

手順:
1. Vercel Analytics → Web Vitals で劣化箇所特定
2. Sentry → Performance → Slow Transactions 確認
3. DB起因の場合:
   - Supabase Dashboard → Database → Query Performance
   - EXPLAIN ANALYZE で遅いクエリを特定
   - インデックス追加を検討
4. フロントエンド起因の場合:
   - Bundle Analyzer で大きなモジュール特定
   - 動的インポート / コード分割を検討
5. 改善後: Lighthouse CI で数値確認
```

## 6. セキュリティインシデント

```
症状: 不正アクセス / データ漏洩の疑い

手順（即時対応）:
1. 影響範囲の特定（どのデータ/ユーザーが影響を受けたか）
2. 攻撃経路の遮断:
   - 侵害されたAPIキーの無効化（Supabase/Stripe Dashboard）
   - 影響を受けたユーザーのセッション無効化
3. 証拠保全: ログのスナップショット取得
4. 通知:
   - GDPR対象の場合: 72時間以内に監督当局に通知
   - 影響ユーザーへの通知
5. 修正:
   - 脆弱性の修正
   - 全シークレットのローテーション
6. ポストモーテム実施
```
