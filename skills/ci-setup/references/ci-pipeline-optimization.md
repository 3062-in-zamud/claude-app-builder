# CI パイプライン最適化ガイド

## 概要

CI パイプラインを最適化し、開発者のフィードバックループを短縮する。
目標: PR 作成から全ジョブ完了まで5分以内。

## パイプライン構成

```
PR 作成
  │
  ├── lint (並列) ─────────────┐
  ├── type-check (並列) ───────┤
  ├── unit-test (並列) ────────┤
  └── security (並列) ─────────┤
                                │
                           e2e (依存) ── unit-test 完了後
                                │
                           test (統合) ── 全ジョブ完了確認
                                │
                         Branch Protection → マージ可能
```

## 完全な test.yml テンプレート

```yaml
name: Test
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  type-check:
    name: Type Check
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx tsc --noEmit

  unit-test:
    name: Unit Test
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage
      - name: Upload coverage
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  e2e:
    name: E2E Test
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: [unit-test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci

      # Playwright ブラウザキャッシュ
      - uses: actions/cache@v4
        id: playwright-cache
        with:
          path: ~/.cache/ms-playwright
          key: playwright-${{ hashFiles('**/package-lock.json') }}

      - name: Install Playwright Browsers
        if: steps.playwright-cache.outputs.cache-hit != 'true'
        run: npx playwright install --with-deps chromium

      # Next.js ビルドキャッシュ
      - uses: actions/cache@v4
        with:
          path: .next/cache
          key: nextjs-${{ hashFiles('**/package-lock.json') }}-${{ hashFiles('**/*.ts', '**/*.tsx') }}
          restore-keys: nextjs-${{ hashFiles('**/package-lock.json') }}-

      - name: Build
        run: npm run build

      - name: Run E2E tests
        run: npx playwright test
        env:
          CI: true

      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - name: npm audit
        run: npm audit --audit-level=high
      - name: TruffleHog Secret Scan
        uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified

  # Branch Protection 用の統合ステータスチェック
  test:
    name: All Checks
    runs-on: ubuntu-latest
    needs: [lint, type-check, unit-test, e2e, security]
    if: always()
    steps:
      - name: Check results
        run: |
          if [ "${{ needs.lint.result }}" != "success" ] ||
             [ "${{ needs.type-check.result }}" != "success" ] ||
             [ "${{ needs.unit-test.result }}" != "success" ] ||
             [ "${{ needs.e2e.result }}" != "success" ] ||
             [ "${{ needs.security.result }}" != "success" ]; then
            echo "❌ One or more checks failed"
            exit 1
          fi
          echo "✅ All checks passed"
```

## キャッシュ効果

| 項目 | キャッシュなし | キャッシュあり | 短縮効果 |
|------|-------------|-------------|---------|
| npm ci | ~30秒 | ~5秒 | -83% |
| Playwright install | ~45秒 | ~0秒 | -100% |
| Next.js build | ~60秒 | ~20秒 | -67% |

## concurrency 設定

同じ PR で複数回 push した場合、古いワークフローをキャンセルする:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## timeout 設定

各ジョブに適切な timeout を設定し、ハングアップを防止:

| ジョブ | timeout | 理由 |
|--------|---------|------|
| lint | 5分 | 通常30秒以内に完了 |
| type-check | 5分 | 通常1分以内 |
| unit-test | 10分 | テスト数に依存 |
| e2e | 15分 | ビルド + ブラウザテスト |
| security | 5分 | スキャン時間 |

## デプロイ用ワークフロー（オプション）

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    needs: []  # test.yml で既にチェック済み
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Vercel
        run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
```
