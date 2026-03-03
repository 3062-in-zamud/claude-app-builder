---
name: github-repo-setup
description: |
  What: GitHub リポジトリのセキュリティ設定・Branch Protection・Dependabot を設定する
  When: Phase 4（project-scaffold 完了後）
  How: gh CLI でリポジトリ設定を適用
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Bash
---

# github-repo-setup: GitHub リポジトリ設定

## ワークフロー

### Step 1: リポジトリ情報確認

```bash
gh repo view --json name,url,visibility
```

### Step 2: Branch Protection 設定

```bash
# main ブランチの保護（直接 push 禁止）
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/{owner}/{repo}/branches/main/protection \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field enforce_admins=false \
  --field restrictions=null \
  --field required_status_checks='{"strict":true,"contexts":["test"]}'
```

### Step 3: Dependabot 有効化

```bash
# .github/dependabot.yml を作成
mkdir -p .github
cat > .github/dependabot.yml << 'EOF'
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
EOF
```

### Step 4: Secret Scanning 確認

```bash
# Secret scanning は GitHub が自動で有効化（パブリックリポジトリ）
# プライベートリポジトリの場合は以下で確認
gh api /repos/{owner}/{repo}/secret-scanning/alerts 2>/dev/null | echo "Secret scanning enabled"
```

### Step 5: SECURITY.md 配置

リポジトリに `SECURITY.md` が存在することを確認。

### Step 6: Supabase RLS 初期設定コマンド案内

```sql
-- Supabase SQL Editor で実行
-- 全テーブルに RLS を有効化（例）
ALTER TABLE [table_name] ENABLE ROW LEVEL SECURITY;

-- 基本的な RLS ポリシー（認証ユーザーのみ自分のデータにアクセス）
CREATE POLICY "Users can view own data" ON [table_name]
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own data" ON [table_name]
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own data" ON [table_name]
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own data" ON [table_name]
  FOR DELETE USING (auth.uid() = user_id);
```

### 出力

- Branch Protection 設定完了
- Dependabot 設定ファイル（`.github/dependabot.yml`）
- Supabase RLS 初期 SQL

### Step 7: Issue/PR テンプレート

`references/issue-pr-templates/` に従い、テンプレートファイルを配置する:

```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   └── feature_request.md
└── PULL_REQUEST_TEMPLATE.md
```

### Step 8: CODEOWNERS 設定

```bash
# .github/CODEOWNERS を作成
cat > .github/CODEOWNERS << 'EOF'
# デフォルトオーナー
* @[owner]

# フロントエンド
/src/app/ @[owner]
/src/components/ @[owner]

# インフラ・CI
/.github/ @[owner]
/supabase/ @[owner]
EOF
```

### Step 9: Release 自動化

semantic-release または GitHub Releases による自動リリース設定:

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    branches: [main]
    paths-ignore:
      - '*.md'
      - 'docs/**'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Create Release
        uses: googleapis/release-please-action@v4
        with:
          release-type: node
```

Conventional Commits に基づき、自動で CHANGELOG.md を更新し GitHub Release を作成する。

### 品質チェック

- [ ] Branch Protection ルールが設定されているか
- [ ] `SECURITY.md` が配置されているか
- [ ] Dependabot が有効か
- [ ] GitHub Secret Scanning が有効か
- [ ] Supabase RLS の初期 SQL が提示されているか
- [ ] Issue テンプレート（Bug Report, Feature Request）が配置されているか
- [ ] PR テンプレートが配置されているか
- [ ] CODEOWNERS が設定されているか
- [ ] Release 自動化ワークフローが設定されているか
