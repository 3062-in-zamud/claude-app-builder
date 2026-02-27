---
name: project-scaffold
description: |
  What: 技術スタックに応じたプロジェクト雛形を生成し、GitHub リポジトリを作成する
  When: Phase 4（技術スタック決定後）
  How: アプリタイプ別テンプレートを展開 → gh repo create → 初期コミット
model: claude-haiku-4-5-20251001
allowed-tools:
  - Read
  - Write
  - Bash
---

# project-scaffold: プロジェクト雛形生成

## ワークフロー

### Step 1: tech-stack.md からアプリタイプを読み込む

```
docs/tech-stack.md を読み込み、アプリタイプを確認
```

### Step 2: テンプレート展開

アプリタイプに応じて `templates/` からファイルを展開:

#### web-fullstack の場合
```bash
# Next.js プロジェクト作成
npx create-next-app@latest [プロジェクト名] \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*"

# shadcn/ui インストール
cd [プロジェクト名] && npx shadcn@latest init

# Supabase クライアントインストール
npm install @supabase/supabase-js @supabase/ssr

# テストツール
npm install -D vitest @vitejs/plugin-react @playwright/test
```

### Step 3: 設定ファイル生成

- `.gitignore`（.env* を含む）
- `.env.example`（全環境変数のキー・説明を記載、値なし）
- `README.md`（基本的な内容、documentation-suite で上書き）

### Step 4: GitHub リポジトリ作成

```bash
cd [プロジェクト名]
git init
git add .
git commit -m "chore: initial scaffold"

# リポジトリ作成（公開/非公開は requirements.md の設定に従う）
gh repo create [プロジェクト名] --public --source=. --remote=origin --push
```

### 出力

- 生成されたプロジェクトディレクトリ
- GitHub リポジトリ URL

### 品質チェック

- [ ] `.gitignore` に `.env*` が含まれているか
- [ ] `.env.example` に全必要環境変数が記載されているか（値なし）
- [ ] 初期コミットが完了しているか
- [ ] GitHub リポジトリが作成されているか
