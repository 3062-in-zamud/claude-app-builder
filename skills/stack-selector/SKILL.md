---
name: stack-selector
description: |
  What: requirements.md + brand-brief.md から最適な技術スタックを選定する
  When: Phase 2 の最初。ブランディング基礎完了後
  How: アプリタイプを判定 → スタックを選定 → tech-stack.md を生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
---

# stack-selector: 技術スタック選定

## ワークフロー

### Step 1: アプリタイプ判定

`docs/requirements.md` を読み込み、以下のタイプを判定:

| タイプ | 条件 | テンプレート |
|--------|------|------------|
| `web-fullstack` | 認証あり・DB あり | Next.js + Supabase + Vercel |
| `web-api` | APIのみ・フロントなし | Hono + Cloudflare Workers |
| `cli` | コマンドラインツール | Node.js CLI（Commander.js） |
| `tui` | ターミナルUI | Ink（React for CLI） |

### Step 2: デフォルトスタック（web-fullstack）

```
フロントエンド: Next.js 15 (App Router) + TypeScript
UI: Tailwind CSS + shadcn/ui
バックエンド: Next.js API Routes / Server Actions
データベース: Supabase (PostgreSQL + Row Level Security)
認証: Supabase Auth
デプロイ: Vercel
テスト: Vitest + Playwright
型チェック: TypeScript strict mode
リント: ESLint + Prettier
```

### Step 3: tech-stack.md 生成

### 出力ファイル

- `docs/tech-stack.md`

### 品質チェック

- [ ] アプリタイプが明確に判定されているか
- [ ] 選定理由が記載されているか
- [ ] 必要な npm パッケージが列挙されているか
