# リリース前50項目チェックリスト

## Phase 1: 要件定義・ブランディング（4項目）

- [ ] P1-1: [MEDIUM] 解決する課題が1文で言えるか（`docs/requirements.md` 確認）
- [ ] P1-2: [MEDIUM] ターゲットユーザーが具体的に記載されているか
- [ ] P1-3: [MEDIUM] MVP機能が5個以内に絞れているか
- [ ] P1-4: [LOW] プロダクト名が確定しているか（ドメイン空き確認済み）

## Phase 2: 設計（3項目）

- [ ] P2-1: [MEDIUM] 技術スタックが要件に適合しているか（`docs/tech-stack.md` 確認）
- [ ] P2-2: [HIGH] デザインシステムのカラーが WCAG AA 基準を満たすか
- [ ] P2-3: [MEDIUM] OGP画像の仕様が決まっているか（1200x630px）

## Phase 3: ドキュメント・LP・法務（9項目）

- [ ] P3-1: [MEDIUM] README に「5分でセットアップできる」手順があるか
- [ ] P3-2: [HIGH] LP の CTA（行動喚起）が明確か
- [ ] P3-3: [CRITICAL] プライバシーポリシーが配置されているか（`/privacy`）
- [ ] P3-4: [CRITICAL] 利用規約が配置されているか（`/terms`）
- [ ] P3-5: [HIGH] LP の全リンクが動作するか
- [ ] P3-6: [HIGH] OGP タグ（og:title, og:description, og:image）が設定されているか
- [ ] P3-7: [MEDIUM] favicon が設定されているか
- [ ] P3-8: [CRITICAL] Cookie同意バナーが実装されているか（EU対象時は必須）
- [ ] P3-9: [HIGH] Cookie ポリシーページが配置されているか（`/cookies`）

## Phase 4: リポジトリ（5項目）

- [ ] P4-1: [CRITICAL] `.gitignore` に `.env*` が含まれているか
- [ ] P4-2: [HIGH] `.env.example` に全必要環境変数が記載されているか（値なし）
- [ ] P4-3: [MEDIUM] GitHub リポジトリの公開/非公開が意図通りか
- [ ] P4-4: [CRITICAL] `SECURITY.md` が配置されているか
- [ ] P4-5: [HIGH] Branch Protection ルールが設定されているか

## Phase 5: 実装・テスト（6項目）

- [ ] P5-1: [HIGH] テストカバレッジ 80% 以上か（`npm run test:coverage`）
- [ ] P5-2: [HIGH] E2E テストが主要フローをカバーしているか
- [ ] P5-3: [HIGH] TypeScript 型エラーがないか（`npx tsc --noEmit`）
- [ ] P5-4: [MEDIUM] ESLint エラーがないか（`npx eslint src/`）
- [ ] P5-5: [HIGH] エラーバウンダリが設定されているか（React Error Boundary）
- [ ] P5-6: [MEDIUM] ローディング状態が適切に表示されるか（Suspense/Skeleton）

## Phase 5.5: セキュリティ（8項目）

- [ ] P55-1: [CRITICAL] IDOR 全 API で所有者確認あり
- [ ] P55-2: [CRITICAL] Supabase RLS 全テーブルで有効
- [ ] P55-3: [CRITICAL] Service Role Key がクライアント側に露出していない
- [ ] P55-4: [CRITICAL] シークレット漏洩スキャン完了（TruffleHog）
- [ ] P55-5: [HIGH] JWT が httpOnly cookie に格納されているか
- [ ] P55-6: [HIGH] npm audit で HIGH 以上の脆弱性がないか
- [ ] P55-7: [HIGH] セキュリティヘッダーが設定されているか（CSP, X-Frame-Options等）
- [ ] P55-8: [HIGH] Rate Limiting が主要APIに設定されているか

## Phase 6: デプロイ準備（5項目）

- [ ] P6-1: [HIGH] Sentry が設定されているか（DSN 環境変数）
- [ ] P6-2: [MEDIUM] Vercel Analytics が設定されているか
- [ ] P6-3: [HIGH] Lighthouse スコアが Performance 90+, Accessibility 95+ か
- [ ] P6-4: [MEDIUM] GitHub Dependabot が有効か
- [ ] P6-5: [HIGH] パフォーマンスバジェットを満たしているか（JS < 200KB gzip）

## Phase 7: デプロイ（5項目）

- [ ] P7-1: [CRITICAL] 環境変数が Vercel ダッシュボードに設定されているか
- [ ] P7-2: [CRITICAL] Supabase マイグレーションが本番に適用されているか
- [ ] P7-3: [HIGH] ユーザーサポートの連絡先が LP に記載されているか
- [ ] P7-4: [HIGH] ヘルスチェックエンドポイント（/api/health）が HTTP 200 を返すか
- [ ] P7-5: [MEDIUM] ロールバック手順が Runbook に記載されているか

## Phase 8: コンプライアンス・運用（5項目）

- [ ] P8-1: [CRITICAL] GDPR 対応（EU対象時）: データ削除リクエスト対応
- [ ] P8-2: [HIGH] SLO（Service Level Objective）が定義されているか
- [ ] P8-3: [HIGH] バックアップ・復旧手順が確認されているか
- [ ] P8-4: [MEDIUM] CHANGELOG.md が最新か
- [ ] P8-5: [MEDIUM] ドキュメント（README, ARCHITECTURE）が最新か

---
**合計**: 50 項目

**重要度別内訳**:
- CRITICAL（必須）: 10項目 → 全て ✅ 必須
- HIGH（重要）: 22項目 → 90% 以上 ✅
- MEDIUM（中）: 14項目 → 70% 以上 ✅
- LOW（低）: 4項目 → 50% 以上 ✅

**CRITICAL 項目一覧**:
P3-3, P3-4, P3-8, P4-1, P4-4, P55-1, P55-2, P55-3, P55-4, P7-1, P7-2, P8-1
