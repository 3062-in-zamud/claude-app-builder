---
name: app-builder
description: |
  What: アイデアを0からMVPリリースまで全自動で実現するメインオーケストレーター
  When: /app-builder "アイデア" で起動。新規アプリの0→1開発時
  How: 8フェーズ（要件定義〜デプロイ）を順次実行。Opus がリーダーとして全体を判断
model: claude-opus-4-6
allowed-tools:
  - Task
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# App Builder - メインオーケストレーター

## 概要

アイデアから MVP リリースまで、以下のフェーズを自動実行します。

**ユーザー介入ポイント**:
1. アイデア入力（起動時）
2. 競合サービス名の入力（Phase 0.5）
3. **Phase 1後の要件定義承認**（必須・承認ゲート1）
4. Vercel/Supabase 制限事項の確認（Phase 1内）
5. `.env.local` への環境変数値の入力（Phase 7前）
6. デプロイ後の本番確認（承認ゲート2）

## 起動前チェック

```bash
# Vercel ログイン確認
vercel whoami 2>/dev/null || {
  echo "⚠️ Vercel にログインしていません"
  echo "   vercel login を実行してください"
  # ユーザーに案内して一時停止
  exit 1
}

# Supabase ログイン確認（web-fullstack の場合）
supabase projects list 2>/dev/null || {
  echo "⚠️ Supabase にログインしていません"
  echo "   supabase login を実行してください"
}
```

## フェーズ実行ワークフロー

### Phase 0: ユーザーリサーチ（推奨・任意）

**実行スキル**:
- `user-research` [Sonnet] → `docs/personas.md` + `docs/interview-guide.md` + `docs/hypothesis.md`

「自分が欲しいから作る」罠を回避するためのペルソナ・インタビューガイド・仮説検証フレームを生成します。
実際のユーザーインタビュー（3〜5名）を実施してから Phase 0.5 へ進むことを推奨します。

### Phase 0.5: 市場調査（オプション推奨）

**実行スキル**:
- `market-research` [Sonnet] → `docs/market-research.md`

競合調査と市場規模の概算を行います。idea-to-spec 前に実行することで、
より精度の高い要件定義が可能になります。

### Phase 1: 要件定義 + ブランディング基礎

※ `docs/personas.md` が存在しない場合: 「ペルソナ情報がないため、汎用的なブランディングになります。先に /user-research を実行しますか？」とユーザーに案内する。

**実行スキル（順次）**:
1. `idea-to-spec` [Sonnet] → `docs/requirements.md`（完了を確認してから次へ）
2. `brand-foundation` [Opus] → `docs/brand-brief.md`（requirements.md を読み込んで実行）

※ 並列化でなく順次実行にすることで、brand-foundation が正しく requirements.md を
  参照できることを保証する。

**完了後: ユーザー承認ゲート**

```
📋 Phase 1 完了 - 要件定義・ブランディングの確認

以下の内容で開発を進めてよろしいですか？

[requirements.md の内容をサマリー表示]
[brand-brief.md の内容をサマリー表示]

✅ 承認 → Phase 2 へ進む
✏️ 修正 → どの点を修正しますか？
```

### Phase 2: 設計 + ブランドアセット

**実行スキル（並列）**:
- `stack-selector` [Sonnet] → `docs/tech-stack.md`
- `visual-designer` [Opus] → `docs/design-system.md`

### Phase 3: リポジトリ準備

**実行スキル（順次）**:
1. `project-scaffold` [Haiku] → リポジトリ作成 + テンプレート展開
2. `ci-setup` [Sonnet] → `.github/workflows/test.yml` 生成（ジョブ名: "test"）
3. `github-repo-setup` [Haiku+Sonnet] → 公開設定 + Branch Protection（contexts: ["test"]）+ Dependabot

### Phase 4: ドキュメント + LP + 法務 + SEO + Cookie同意

**実行スキル（並列）**:
- `documentation-suite` [Sonnet] → `README.md` + `docs/`
- `landing-page-builder` [Sonnet] → `app/landing/`
- `legal-docs-generator` [Sonnet] → `app/privacy/` + `app/terms/` + `app/cookies/` + `app/legal/`
- `seo-setup` [Sonnet] → `src/app/sitemap.ts` + `robots.ts` + JSON-LD
- `cookie-consent` [Haiku] → Cookie同意バナー + Google Consent Mode v2（EU対象時は必須）

### Phase 5: 実装 + テスト

**実行スキル（順次）**:
1. `implementation` [Sonnet] → TDD実装・Vitest単体テスト・Playwright E2E
   - 完了条件: `npm run test:coverage` 80%以上 + TypeScript型エラーなし

※ 単一コンテキストで一貫性のある実装を行います。

### G3: MVP品質ゲート（Phase 5 完了後・Phase 5.5 前）

Phase 5.5 に進む前に以下を全て確認:

```
📋 G3 - MVP品質ゲート

1. ヘルスチェック:
   ✅ /api/health が HTTP 200 を返す

2. テストカバレッジ:
   ✅ npm run test:coverage → 80% 以上

3. Lighthouse スコア:
   ✅ Performance: 90+ (P90)
   ✅ Accessibility: 95+ (A95)
```

```bash
# G3 自動チェック
echo "=== G3: MVP品質ゲート ==="
G3_PASS=true

# テストカバレッジ確認
echo "📋 テストカバレッジ..."
COVERAGE=$(npm run test:coverage 2>&1 | grep "All files" | awk '{print $4}' | tr -d '%')
if [ -n "$COVERAGE" ] && [ "$(echo "$COVERAGE >= 80" | bc)" = "1" ]; then
  echo "  ✅ カバレッジ: ${COVERAGE}% (>= 80%)"
else
  echo "  ❌ カバレッジ不足: ${COVERAGE:-N/A}% (< 80%)"
  G3_PASS=false
fi

# ビルド確認（Lighthouse は本番デプロイ後に実行）
echo "📋 ビルドチェック..."
if npm run build 2>&1 | tail -1 | grep -q "error"; then
  echo "  ❌ ビルドエラーあり"
  G3_PASS=false
else
  echo "  ✅ ビルド成功"
fi

if [ "$G3_PASS" = false ]; then
  echo ""
  echo "❌ G3 品質ゲート未達。修正してから Phase 5.5 に進んでください"
fi
```

⚠️ **G3 未達の場合は Phase 5.5 に進めない**。テスト追加・パフォーマンス改善を実施。

### Phase 5.5: セキュリティ強化（必須・スキップ不可）

**実行スキル**:
- `security-hardening` [**Opus**] → IDOR・RLS・Secret・CSRF 全チェック

⚠️ **CRITICAL 問題がある場合は Phase 6 に進めない**

### Phase 6: デプロイ準備 + 本番設定

**実行スキル（並列）**:
- `monitoring-setup` [Sonnet] → Sentry + Analytics + Lighthouse CI
- `release-checklist` [Sonnet] → 50項目チェック + Go/No-Go 判断

### Phase 7: デプロイ実行 + ローンチ準備

**実行スキル**:
- `deploy-setup` [Haiku→Sonnet] → supabase db push → vercel --prod → ローンチ素材生成

### Phase 8: リリース報告 + フィードバック設計

**実行内容**:
1. リリース報告（本番URL + セキュリティ確認済みマーク）
2. `feedback-loop` [Sonnet] → フィードバック収集設計 + 次イテレーション計画

```
🎉 アプリケーションが公開されました！

📱 本番URL: https://[app-name].vercel.app

🔒 セキュリティ確認済み:
  ✅ IDOR チェック完了
  ✅ Supabase RLS 全テーブル設定済み
  ✅ シークレット漏洩スキャン完了
  ✅ CSRF 保護確認済み
  ✅ npm audit 問題なし

📢 ローンチ素材:
  [Product Hunt 投稿文]
  [Twitter/X 告知文]
  [LinkedIn 告知文]

📋 次のステップ:
  - Typeform/Canny でフィードバック収集を設定（docs/feedback-strategy.md 参照）
  - Sentry でエラーを監視
  - 2週間後: ユーザーフィードバックを元に次イテレーション計画

💰 グロース・収益化:
  - /growth-engine で収益化戦略を立案（プライシング → 決済 → オンボーディング → メール → グロース）
  - フィードバックデータが蓄積されてから実行を推奨
```

## フェーズゲート基準

各フェーズ間にゲート（品質チェックポイント）を設置し、品質を担保する。
`references/phase-gate-criteria.md` に各ゲートの通過条件を詳細に記載。

| ゲート | 位置 | 通過条件 |
|--------|------|---------|
| G1 | Phase 1 後 | 要件定義承認（ユーザー確認） |
| G2 | Phase 3 後 | リポジトリ・CI 正常動作 |
| G3 | Phase 5 後 | テストカバレッジ 80%+, ビルド成功 |
| G4 | Phase 5.5 後 | セキュリティ CRITICAL 問題なし |
| G5 | Phase 6 後 | Go/No-Go 判断 Go |

## 品質ダッシュボード自動生成

Phase 6（release-checklist）完了後に `docs/quality-dashboard.md` を自動生成する。
`references/quality-dashboard-template.md` のテンプレートに従い、以下を集約:

```markdown
## 品質ダッシュボード

### テスト
- カバレッジ: [X]%
- ユニットテスト: [X]件 PASS / [X]件 FAIL
- E2E テスト: [X]件 PASS / [X]件 FAIL

### セキュリティ
- IDOR チェック: ✅/❌
- RLS 設定: ✅/❌
- npm audit HIGH: [X]件
- シークレットスキャン: ✅/❌

### パフォーマンス
- Lighthouse Performance: [X]
- Lighthouse Accessibility: [X]
- バンドルサイズ: [X]KB

### リリースチェック
- CRITICAL: [X]/[X] ✅
- HIGH: [X]/[X] ✅
- Go/No-Go: Go / Conditional Go / No-Go
```

## エラーハンドリング

### 3回失敗でエスカレーション

```
⚠️ フェーズ名: [Phase X - スキル名] で問題が発生しました

エラー内容:
[具体的なエラーメッセージ]

推奨アクション:
1. [具体的な修正手順]
2. または /app-builder を再実行して最初からやり直す

どうしますか？
1. 手動で修正して続行
2. このフェーズをスキップ（⚠️ 品質低下のリスクあり）
3. 中断して後で再開
```

## モデル割り当て表

| タスク | モデル |
|--------|--------|
| リーダー（全体判断） | `claude-opus-4-6` |
| ブランディング | `claude-opus-4-6` |
| デザイン戦略 | `claude-opus-4-6` |
| セキュリティレビュー | `claude-opus-4-6` |
| 要件定義・実装・ドキュメント | `claude-sonnet-4-6` |
| デプロイ | `claude-sonnet-4-6` |
| テンプレート展開 | `claude-haiku-4-5-20251001` |
| Cookie同意管理 | `claude-haiku-4-5-20251001` |
| 法務文書 | `claude-sonnet-4-6` |
