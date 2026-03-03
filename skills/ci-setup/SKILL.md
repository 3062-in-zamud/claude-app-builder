---
name: ci-setup
description: |
  What: GitHub Actions でテスト自動化CIを設定する（Phase 4.5）
  When: project-scaffold 完了後・github-repo-setup の前（必須の依存関係）
  How: Vitest + Playwright + TypeScript型チェックのワークフロー生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
---

# ci-setup: CI設定

## 概要

GitHub Actions でテストを自動実行する CI を設定します。
**ジョブ名は `test`** で固定（github-repo-setup の Branch Protection と連携）。

## ワークフロー

### Step 1: CI設定ファイルの生成

`.github/workflows/test.yml` を生成:

```yaml
name: Test
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx tsc --noEmit
      - run: npm run lint
      - run: npm test -- --coverage
      - name: Install Playwright Browsers
        run: npx playwright install --with-deps chromium
      - name: Run E2E tests
        run: npx playwright test
        env:
          CI: true
```

### Step 2: package.json のスクリプト確認

`package.json` に以下のスクリプトが含まれているか確認:

```json
{
  "scripts": {
    "test": "vitest run",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/"
  }
}
```

不足している場合は追加する。

## ジョブ並列化設計

`references/ci-pipeline-optimization.md` に従い、CIジョブを並列化して高速化する:

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  type-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx tsc --noEmit

  unit-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage

  e2e:
    runs-on: ubuntu-latest
    needs: [unit-test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test

  # Branch Protection 用の統合ジョブ
  test:
    runs-on: ubuntu-latest
    needs: [lint, type-check, unit-test, e2e]
    if: always()
    steps:
      - run: |
          if [ "${{ needs.lint.result }}" != "success" ] ||
             [ "${{ needs.type-check.result }}" != "success" ] ||
             [ "${{ needs.unit-test.result }}" != "success" ] ||
             [ "${{ needs.e2e.result }}" != "success" ]; then
            exit 1
          fi
```

## キャッシュ戦略

node_modules、ビルドキャッシュ、Playwright ブラウザをキャッシュする:

```yaml
# node_modules キャッシュ（actions/setup-node の cache: 'npm' で自動）
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

# Next.js ビルドキャッシュ
- uses: actions/cache@v4
  with:
    path: .next/cache
    key: nextjs-${{ hashFiles('**/package-lock.json') }}-${{ hashFiles('**/*.ts', '**/*.tsx') }}
    restore-keys: nextjs-${{ hashFiles('**/package-lock.json') }}-

# Playwright ブラウザキャッシュ
- uses: actions/cache@v4
  with:
    path: ~/.cache/ms-playwright
    key: playwright-${{ hashFiles('**/package-lock.json') }}
```

## セキュリティスキャン CI 統合

```yaml
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci

      # npm audit（HIGH以上で失敗）
      - name: npm audit
        run: npm audit --audit-level=high

      # TruffleHog シークレットスキャン
      - name: TruffleHog Secret Scan
        uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified
```

## CI 段階化（Fast Feedback → Full Test → Deploy）

| 段階 | トリガー | ジョブ | 所要時間目安 |
|------|---------|--------|-----------|
| Fast Feedback | PR作成 | lint + type-check | ~1分 |
| Full Test | PR作成 | unit-test + e2e + security | ~3-5分 |
| Deploy | main マージ | ビルド + デプロイ | ~2-3分 |

## 完了条件

- [ ] `.github/workflows/test.yml` が生成されている
- [ ] ジョブ名が `test` になっている（Branch Protection との整合性）
- [ ] `package.json` に必要なスクリプトが存在する
- [ ] lint / type-check / unit-test / e2e が並列化されているか
- [ ] キャッシュ戦略（node_modules, .next/cache, Playwright）が設定されているか
- [ ] npm audit によるセキュリティスキャンが含まれているか

## 出力

- `.github/workflows/test.yml`（CI設定ファイル）
