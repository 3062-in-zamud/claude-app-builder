# Branch Protection 設定ガイド

## GitHub UI での設定

Settings → Branches → Add branch protection rule

### 推奨設定

| 設定 | 値 | 理由 |
|------|-----|------|
| Branch name pattern | `main` | メインブランチを保護 |
| Require a pull request before merging | ✅ | 直接 push 禁止 |
| Required approving reviews | 1 | 最低1人のレビュー必須 |
| Dismiss stale PR approvals | ✅ | 新しいコミットで承認リセット |
| Require status checks | ✅ | CI が通らないとマージ不可 |
| Require branches to be up to date | ✅ | マージ前に最新 main を取り込む |
| Include administrators | ❌ | 管理者は緊急時に bypass 可能 |

## GitHub Actions CI 設定例

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  test:
    name: ci/tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run typecheck
      - run: npm run lint
      - run: npm test
```

## Dependabot 設定例

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      minor-and-patch:
        patterns: ["*"]
        update-types: ["minor", "patch"]
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "automated"
```
