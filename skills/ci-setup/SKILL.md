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

## 完了条件

- [ ] `.github/workflows/test.yml` が生成されている
- [ ] ジョブ名が `test` になっている（Branch Protection との整合性）
- [ ] `package.json` に必要なスクリプトが存在する

## 出力

- `.github/workflows/test.yml`（CI設定ファイル）
