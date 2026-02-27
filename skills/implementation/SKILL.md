---
name: implementation
description: |
  What: TDD（Red→Green→Refactor）でMVP機能を実装する
  When: Phase 5（project-scaffold・ci-setup完了後）
  How: requirements.md のP0機能をユーザーストーリー順に実装
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# implementation: TDD実装

## 概要

`docs/requirements.md` の P0 機能をユーザーストーリー順に TDD で実装します。

## 実装ワークフロー

### Step 1: 要件確認

```bash
# 実装対象機能の確認
cat docs/requirements.md
```

P0 機能をユーザーストーリー順にリストアップし、実装順序を決定する。

### Step 2: TDD サイクル（各機能）

各 P0 機能について以下のサイクルを繰り返す:

**Red（テスト作成）**:
- Vitest でユニットテストを作成
- テストが失敗することを確認

**Green（最小実装）**:
- テストを通す最小限の実装を作成
- `npx tsc --noEmit` で型エラーがないことを確認

**Refactor（改善）**:
- コードの可読性・保守性を向上
- `npm run lint` でLintチェック

### Step 3: 各機能完成後のクイックチェック

```bash
npx tsc --noEmit && echo "✅ TypeScript OK" || echo "❌ TypeScript エラーあり"
npm run lint && echo "✅ Lint OK" || echo "❌ Lint エラーあり"
```

### Step 4: 全機能完成後

```bash
# テストカバレッジ確認（80%以上）
npm run test:coverage

# E2E テスト（主要フロー）
npx playwright test
```

### Step 5: セルフレビュー

OWASP Top 10 観点でコードを確認（独立したセキュリティレビューは security-hardening スキルが担当）:
- [ ] ユーザー入力のバリデーション
- [ ] SQL インジェクション対策（パラメタライズドクエリ）
- [ ] 認証・認可の確認
- [ ] エラーメッセージに機密情報が含まれていないか

## 完了条件

- [ ] `npm run test:coverage` で 80% 以上
- [ ] TypeScript 型エラーなし（`npx tsc --noEmit`）
- [ ] E2E テスト: 登録・ログイン・CRUD の主要フローが通る
- [ ] `npm run lint` エラーなし

## 出力

- 実装済みコード（`src/` 以下）
- テストファイル（`src/**/*.test.ts`）
- E2E テスト（`e2e/` 以下）
