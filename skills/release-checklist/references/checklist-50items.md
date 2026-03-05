# リリース前50項目チェックリスト

## Phase 1: 要件・ブランディング

- [ ] P1-1: [MEDIUM] 解決する課題が1文で言える
- [ ] P1-2: [MEDIUM] ターゲットユーザーが具体的
- [ ] P1-3: [MEDIUM] MVP機能が5個以内
- [ ] P1-4: [LOW] ドメイン候補が確定

## Phase 2: 技術設計（契約必須）

- [ ] P2-1: [CRITICAL] `docs/tech-stack.md` に `app_type` がある
- [ ] P2-2: [CRITICAL] `docs/tech-stack.md` に `deployment_provider` がある
- [ ] P2-3: [CRITICAL] `docs/tech-stack.md` に `app_domain` がある
- [ ] P2-4: [CRITICAL] providerが `cloudflare-pages` の場合 `cloudflare_pages_project` がある
- [ ] P2-5: [CRITICAL] providerが `cloudflare-pages` の場合 `cloudflare_build_command` がある
- [ ] P2-6: [CRITICAL] providerが `cloudflare-pages` の場合 `cloudflare_build_dir` がある

## Phase 3: ドキュメント・LP・法務

- [ ] P3-1: [MEDIUM] README セットアップ手順が最新
- [ ] P3-2: [CRITICAL] プライバシーポリシー配置済み
- [ ] P3-3: [CRITICAL] 利用規約配置済み
- [ ] P3-4: [CRITICAL] Cookie同意バナー実装（EU対象時）
- [ ] P3-5: [HIGH] LPリンク・OGP設定が正しい

## Phase 4: リポジトリ安全性

- [ ] P4-1: [CRITICAL] `.gitignore` に `.env*`
- [ ] P4-2: [CRITICAL] `.env.example` に必要変数のみ（値なし）
- [ ] P4-3: [HIGH] Branch Protection 有効
- [ ] P4-4: [CRITICAL] `SECURITY.md` 配置済み

## Phase 5: 実装・テスト

- [ ] P5-1: [HIGH] テストカバレッジ 80%+
- [ ] P5-2: [HIGH] TypeScript 型エラー 0
- [ ] P5-3: [HIGH] E2E 主要フロー PASS
- [ ] P5-4: [MEDIUM] ESLint エラー 0

## Phase 5.5: セキュリティ

- [ ] P55-1: [CRITICAL] IDOR 対策完了
- [ ] P55-2: [CRITICAL] Supabase RLS 全テーブル有効
- [ ] P55-3: [CRITICAL] Service Role Key の露出なし
- [ ] P55-4: [CRITICAL] シークレット漏洩スキャン完了
- [ ] P55-5: [HIGH] npm audit HIGH 0
- [ ] P55-6: [HIGH] セキュリティヘッダー設定完了

## Phase 6: 監視・運用準備

- [ ] P6-1: [HIGH] Sentry 設定済み
- [ ] P6-2: [HIGH] providerに応じた Analytics 設定済み
- [ ] P6-3: [HIGH] Lighthouse Performance 90+, Accessibility 95+
- [ ] P6-4: [MEDIUM] Dependabot 有効
- [ ] P6-5: [HIGH] SLO/SLI/Error Budget 定義済み

## Phase 7: デプロイ

- [ ] P7-1: [CRITICAL] provider環境に環境変数が設定済み
- [ ] P7-2: [CRITICAL] Supabase マイグレーション適用済み
- [ ] P7-3: [CRITICAL] `/api/health` が HTTP 200
- [ ] P7-4: [HIGH] 本番スモークテスト PASS
- [ ] P7-5: [HIGH] provider別ロールバック手順がRunbookにある

## Phase 8: 運用・コンプライアンス

- [ ] P8-1: [CRITICAL] GDPR対応フロー定義済み
- [ ] P8-2: [HIGH] バックアップ/復旧手順確認済み
- [ ] P8-3: [MEDIUM] CHANGELOG更新済み
- [ ] P8-4: [MEDIUM] README/ARCHITECTURE更新済み

## ゲート判定

- G1: Phase 1承認
- G2: Phase 5.5 セキュリティ必須項目すべてPASS
- G3: Phase 7 本番検証必須項目すべてPASS
- G4: Growth EngineのAlpha→Beta判定
- G5: Growth EngineのBeta→GA判定
