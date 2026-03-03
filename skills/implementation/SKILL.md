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

## コンテキスト管理（重要）

MVP機能が3つを超える場合、単一コンテキストウィンドウに収まらない可能性があります。
以下の戦略で対処してください:

### 機能数別の実装戦略

| 機能数 | 戦略 |
|--------|------|
| 1〜3機能 | 単一コンテキストで通常実装 |
| 4〜5機能 | 機能ごとに `git commit` → `/compact` → 次機能 |
| 6機能以上 | `/app-builder` による分割を検討。または機能を絞る |

### 中断・再開方法

実装が中断した場合の再開手順:
```bash
# 進捗確認
git log --oneline -10
cat docs/requirements.md | grep "P0\|実装済み"
```

再開時は「前回のgit logと requirements.md のP0機能リストを確認し、
未実装の機能から続けてください」と伝えてください。

## アーキテクチャ方針

### Vertical Slice アーキテクチャ（Feature-based フォルダ構成）

```
src/
  features/
    auth/
      components/    # UI コンポーネント
      hooks/         # カスタムフック
      api/           # API ルートハンドラ
      lib/           # ビジネスロジック
      types.ts       # 型定義
      __tests__/     # テスト
    posts/
      components/
      hooks/
      api/
      lib/
      types.ts
      __tests__/
  shared/            # 複数 feature で共有するもののみ
    components/
    lib/
    types/
```

**判断基準**: 2つ以上の feature で使われるまで `shared/` に移動しない（早すぎる抽象化を防ぐ）。

### テストピラミッド戦略

テスト配分の目安（詳細は `references/test-strategy-pyramid.md`）:

| 層 | 割合 | 対象 | ツール |
|----|------|------|--------|
| **Unit** | 70% | ビジネスロジック・ユーティリティ | Vitest |
| **Integration** | 20% | API ルート・DB 操作・コンポーネント連携 | Vitest + Testing Library |
| **E2E** | 10% | 主要ユーザーフロー（登録→ログイン→CRUD） | Playwright |

### エラーハンドリング方針

Result 型パターンを採用（詳細は `references/error-handling-patterns.md`）:

```typescript
// neverthrow 推奨
import { ok, err, Result } from 'neverthrow'

type AppError = { code: string; message: string; statusCode: number }

function createPost(data: PostInput): Result<Post, AppError> {
  if (!data.title) {
    return err({ code: 'VALIDATION_ERROR', message: 'Title is required', statusCode: 400 })
  }
  return ok(newPost)
}
```

API レスポンスは RFC 7807 Problem Details 形式で統一:

```json
{
  "type": "https://example.com/errors/validation",
  "title": "Validation Error",
  "status": 400,
  "detail": "Title is required",
  "instance": "/api/posts"
}
```

### パフォーマンスバジェット

| 指標 | 目標値 | 計測方法 |
|------|--------|----------|
| FCP (First Contentful Paint) | < 1.8s | Lighthouse CI |
| LCP (Largest Contentful Paint) | < 2.5s | Lighthouse CI |
| CLS (Cumulative Layout Shift) | < 0.1 | Lighthouse CI |
| TBT (Total Blocking Time) | < 300ms | Lighthouse CI |
| バンドルサイズ (JS) | < 200KB (gzip) | `next build` |

### DB 設計パターン（Supabase 特化）

詳細は `references/database-design-patterns.md` を参照:

- **正規化判断**: 3NF を基本とし、読み取り頻度が高いデータのみ意図的に非正規化
- **インデックス戦略**: WHERE / JOIN / ORDER BY で使うカラムに作成。複合インデックスはカーディナリティ順
- **Soft Delete**: `deleted_at TIMESTAMP` カラム + RLS ポリシーで `deleted_at IS NULL` フィルタ
- **タイムスタンプ**: 全テーブルに `created_at`, `updated_at` を必須設定
- **UUID**: 主キーは `uuid` 型（`gen_random_uuid()` デフォルト）

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
- [ ] テストピラミッド比率が Unit 70% / Integration 20% / E2E 10% に近いか
- [ ] エラーハンドリングが Result 型 + RFC 7807 に準拠しているか
- [ ] パフォーマンスバジェット（FCP<1.8s, LCP<2.5s, CLS<0.1）を満たしているか
- [ ] DB テーブルに `created_at`, `updated_at` が設定されているか
- [ ] Vertical Slice 構成で feature ごとにフォルダが分かれているか

## 出力

- 実装済みコード（`src/` 以下）
- テストファイル（`src/**/*.test.ts`）
- E2E テスト（`e2e/` 以下）
