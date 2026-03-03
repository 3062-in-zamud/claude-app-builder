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
  --import-alias "@/*" --yes

# shadcn/ui インストール
cd [プロジェクト名] && npx shadcn@latest init --yes --defaults

# Supabase クライアントインストール
npm install @supabase/supabase-js @supabase/ssr

# テストツール
npm install -D vitest @vitejs/plugin-react @playwright/test
```

### Step 3: 設定ファイル生成

- `.gitignore`（.env* を含む）
- `.env.example`（全環境変数のキー・説明を記載、値なし）
- `README.md`（基本的な内容、documentation-suite で上書き）
- `src/app/api/health/route.ts`（ヘルスチェックエンドポイント）

**生成ファイル**: `src/app/api/health/route.ts`
```typescript
export async function GET() {
  return Response.json({ status: 'ok', timestamp: new Date().toISOString() })
}
```

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

### Step 5: Husky + lint-staged 設定

`references/precommit-hook-setup.md` に従い、pre-commit フックを設定する:

```bash
# Husky インストール
npm install -D husky lint-staged
npx husky init

# pre-commit フック設定
echo "npx lint-staged" > .husky/pre-commit
```

`package.json` に lint-staged 設定を追加:

```json
{
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml}": ["prettier --write"]
  }
}
```

### Step 6: Zod 環境変数バリデーション

`references/env-validation-setup.md` に従い、環境変数の型安全な読み込みを設定する:

```bash
npm install zod
```

`src/env.ts` を生成:

```typescript
import { z } from 'zod'

const envSchema = z.object({
  NEXT_PUBLIC_APP_URL: z.string().url(),
  NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1).optional(),
})

export const env = envSchema.parse({
  NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
})
```

### Step 7: EditorConfig 設定

`.editorconfig` を生成:

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false
```

### 品質チェック

- [ ] `.gitignore` に `.env*` が含まれているか
- [ ] `.env.example` に全必要環境変数が記載されているか（値なし）
- [ ] 初期コミットが完了しているか
- [ ] GitHub リポジトリが作成されているか
- [ ] Husky + lint-staged が設定されているか
- [ ] `src/env.ts` で環境変数バリデーションが設定されているか
- [ ] `.editorconfig` が配置されているか
