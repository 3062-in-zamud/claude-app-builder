# フェーズゲート基準詳細

## 概要

各フェーズ間のゲートで品質を確認し、問題がある状態で次フェーズに進まないようにする。
ゲートを通過できない場合は、問題を修正してから再チェックする。

## G1: 要件定義承認ゲート（Phase 1 後）

**位置**: Phase 1（idea-to-spec + brand-foundation）完了後
**判断者**: ユーザー

### 通過条件

| # | 条件 | 確認方法 | 必須 |
|---|------|---------|------|
| 1 | requirements.md が生成されている | ファイル存在確認 | Yes |
| 2 | brand-brief.md が生成されている | ファイル存在確認 | Yes |
| 3 | 解決する課題が1文で言える | requirements.md 確認 | Yes |
| 4 | MVP 機能が5個以内 | requirements.md 確認 | Yes |
| 5 | ターゲットユーザーが具体的 | requirements.md 確認 | Yes |
| 6 | ユーザー承認を取得 | AskUserQuestion | Yes |

### 未達時のアクション

- requirements.md の該当箇所を修正
- ユーザーに修正内容を提示して再承認を依頼

---

## G2: リポジトリ準備ゲート（Phase 3 後）

**位置**: Phase 3（project-scaffold + ci-setup + github-repo-setup）完了後
**判断者**: 自動チェック

### 通過条件

| # | 条件 | 確認方法 | 必須 |
|---|------|---------|------|
| 1 | GitHub リポジトリが作成されている | `gh repo view` | Yes |
| 2 | 初期コミットが成功している | `git log --oneline -1` | Yes |
| 3 | CI ワークフローが配置されている | `.github/workflows/test.yml` 存在確認 | Yes |
| 4 | Branch Protection が設定されている | `gh api` で確認 | Yes |
| 5 | .gitignore に .env* が含まれている | ファイル内容確認 | Yes |
| 6 | .env.example が存在する | ファイル存在確認 | Yes |

### 未達時のアクション

- 該当スキルを再実行
- 手動で設定を追加

---

## G3: MVP 品質ゲート（Phase 5 後）

**位置**: Phase 5（implementation）完了後
**判断者**: 自動チェック

### 通過条件

| # | 条件 | 確認方法 | 必須 |
|---|------|---------|------|
| 1 | TypeScript 型エラーなし | `npx tsc --noEmit` | Yes |
| 2 | ESLint エラーなし | `npx eslint src/` | Yes |
| 3 | テストカバレッジ 80% 以上 | `npm run test:coverage` | Yes |
| 4 | E2E テスト PASS | `npx playwright test` | Yes |
| 5 | ビルド成功 | `npm run build` | Yes |
| 6 | /api/health が 200 を返す | `curl /api/health` | Yes |

### 未達時のアクション

- テスト追加・修正
- 型エラー・lint エラー修正
- ビルドエラー修正

---

## G4: セキュリティゲート（Phase 5.5 後）

**位置**: Phase 5.5（security-hardening）完了後
**判断者**: security-hardening スキル

### 通過条件

| # | 条件 | 確認方法 | 必須 |
|---|------|---------|------|
| 1 | IDOR チェック完了 | security-hardening レポート | Yes |
| 2 | RLS 全テーブル有効 | Supabase SQL 確認 | Yes |
| 3 | Service Role Key 非露出 | コードスキャン | Yes |
| 4 | シークレットスキャン完了 | TruffleHog 実行 | Yes |
| 5 | npm audit HIGH 0件 | `npm audit --audit-level=high` | Yes |
| 6 | CRITICAL 問題 0件 | security-hardening レポート | Yes |

### 未達時のアクション

- CRITICAL: Phase 6 に進めない。即座に修正
- HIGH: 修正を強く推奨。ユーザーに確認してから判断
- MEDIUM/LOW: Issue 登録して後で対応可

---

## G5: リリース判断ゲート（Phase 6 後）

**位置**: Phase 6（release-checklist）完了後
**判断者**: Go/No-Go 判断基準に基づく

### 通過条件

| # | 条件 | 確認方法 | 必須 |
|---|------|---------|------|
| 1 | CRITICAL チェック項目 全 ✅ | checklist-50items.md | Yes |
| 2 | HIGH チェック項目 90% 以上 ✅ | checklist-50items.md | Yes |
| 3 | Lighthouse Performance 80+ | Lighthouse CI | Yes |
| 4 | Lighthouse Accessibility 90+ | Lighthouse CI | Yes |
| 5 | 本番環境変数準備完了 | ユーザー確認 | Yes |

### 判断結果

| 結果 | 条件 | 次のアクション |
|------|------|-------------|
| Go | 全条件クリア | Phase 7 へ |
| Conditional Go | 一部未達（許容範囲内） | Issue 登録して Phase 7 へ |
| No-Go | 必須条件未達 | 修正してから再チェック |

---

## ゲート運用ルール

1. **ゲートはスキップ不可**: G3, G4 は自動チェックのため回避できない
2. **G1 はユーザー判断**: 機械的な基準ではなくユーザーの承認が必要
3. **G5 は柔軟性あり**: Conditional Go で条件付きリリースが可能
4. **記録を残す**: 各ゲートの結果は `docs/release-report.md` に記録
