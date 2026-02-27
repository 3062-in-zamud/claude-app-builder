# リリース前34項目チェックリスト

## Phase 1: 要件定義・ブランディング（4項目）

- [ ] P1-1: 解決する課題が1文で言えるか（`docs/requirements.md` 確認）
- [ ] P1-2: ターゲットユーザーが具体的に記載されているか
- [ ] P1-3: MVP機能が5個以内に絞れているか
- [ ] P1-4: プロダクト名が確定しているか（ドメイン空き確認済み）

## Phase 2: 設計（3項目）

- [ ] P2-1: 技術スタックが要件に適合しているか（`docs/tech-stack.md` 確認）
- [ ] P2-2: デザインシステムのカラーが WCAG AA 基準を満たすか
- [ ] P2-3: OGP画像の仕様が決まっているか（1200x630px）

## Phase 3: ドキュメント・LP・法務（7項目）

- [ ] P3-1: README に「5分でセットアップできる」手順があるか
- [ ] P3-2: LP の CTA（行動喚起）が明確か
- [ ] P3-3: プライバシーポリシーが配置されているか（`/privacy`）
- [ ] P3-4: 利用規約が配置されているか（`/terms`）
- [ ] P3-5: LP の全リンクが動作するか
- [ ] P3-6: OGP タグ（og:title, og:description, og:image）が設定されているか
- [ ] P3-7: favicon が設定されているか

## Phase 4: リポジトリ（5項目）

- [ ] P4-1: `.gitignore` に `.env*` が含まれているか
- [ ] P4-2: `.env.example` に全必要環境変数が記載されているか（値なし）
- [ ] P4-3: GitHub リポジトリの公開/非公開が意図通りか
- [ ] P4-4: `SECURITY.md` が配置されているか
- [ ] P4-5: Branch Protection ルールが設定されているか

## Phase 5: 実装・テスト（4項目）

- [ ] P5-1: テストカバレッジ 80% 以上か（`npm run test:coverage`）
- [ ] P5-2: E2E テストが主要フローをカバーしているか
- [ ] P5-3: TypeScript 型エラーがないか（`npx tsc --noEmit`）
- [ ] P5-4: ESLint エラーがないか（`npx eslint src/`）

## Phase 5.5: セキュリティ（6項目）

- [ ] P55-1: IDOR 全 API で所有者確認あり
- [ ] P55-2: Supabase RLS 全テーブルで有効
- [ ] P55-3: Service Role Key がクライアント側に露出していない
- [ ] P55-4: シークレット漏洩スキャン完了（TruffleHog）
- [ ] P55-5: JWT が httpOnly cookie に格納されているか
- [ ] P55-6: npm audit で HIGH 以上の脆弱性がないか

## Phase 6: デプロイ準備（4項目）

- [ ] P6-1: Sentry が設定されているか（DSN 環境変数）
- [ ] P6-2: Vercel Analytics が設定されているか
- [ ] P6-3: Lighthouse スコアが Performance 90+, Accessibility 95+ か
- [ ] P6-4: GitHub Dependabot が有効か

## Phase 7: デプロイ（3項目）

- [ ] P7-1: 環境変数が Vercel ダッシュボードに設定されているか
- [ ] P7-2: Supabase マイグレーションが本番に適用されているか
- [ ] P7-3: ユーザーサポートの連絡先が LP に記載されているか

---
**合計**: 36 項目（34 + 2 追加）
**CRITICAL（必須）**: P4-1, P4-4, P55-1 〜 P55-6, P7-1, P7-2
