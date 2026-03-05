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

## 目的

このスキルの出力は後続スキルの唯一の入力契約になる。
`docs/tech-stack.md` の形式は固定し、曖昧な表現や省略を禁止する。

## ワークフロー

### Step 1: アプリタイプ判定

`docs/requirements.md` を読み込み、以下のタイプを判定:

| タイプ | 条件 | テンプレート |
|--------|------|------------|
| `web-fullstack` | 認証あり・DB あり | Next.js + Supabase + (Vercel or Cloudflare Pages) |
| `web-api` | APIのみ・フロントなし | Hono + Cloudflare Workers |
| `cli` | コマンドラインツール | Node.js CLI（Commander.js） |
| `tui` | ターミナルUI | Ink（React for CLI） |
| `mobile` | モバイルアプリ | React Native + Expo |

**モバイルアプリ（React Native / Expo）**:
- React Native + Expo
- 注意: `/app-builder` フルフローは現在 Web アプリのみ対応

### Step 2: web-fullstack のデフォルトスタック

```
フロントエンド: Next.js 15 (App Router) + TypeScript
UI: Tailwind CSS + shadcn/ui
バックエンド: Next.js API Routes / Server Actions
データベース: Supabase (PostgreSQL + Row Level Security)
認証: Supabase Auth
デプロイ: deployment_provider で選択（vercel / cloudflare-pages）
テスト: Vitest + Playwright
型チェック: TypeScript strict mode
リント: ESLint + Prettier
```

### Step 3: deployment_provider を決定（web-fullstack 必須）

- `deployment_provider: vercel`
- `deployment_provider: cloudflare-pages`

第1弾の制約:
- `cloudflare-pages` を選んでも DB/Auth は Supabase 維持
- D1/KV/R2 置換は対象外

### Step 4: tech-stack.md を契約形式で生成

出力ファイル: `docs/tech-stack.md`

以下のキーを **行頭の `key: value` 形式で必ず出力**（箇条書き禁止）:

```markdown
# Tech Stack

app_type: web-fullstack
deployment_provider: vercel
app_domain: app.example.com

# Cloudflare 選択時のみ必須
cloudflare_pages_project: your-pages-project
cloudflare_build_command: npm run build:cloudflare
cloudflare_build_dir: .open-next/cloudflare
```

補足:
- `deployment_provider=vercel` の場合、`cloudflare_*` は空でも可
- `deployment_provider=cloudflare-pages` の場合、`cloudflare_*` は全て必須

## ADR（Architecture Decision Record）

`references/adr-template.md` を使い、主要判断を記録:

```
docs/adr/
├── 0001-use-nextjs-app-router.md
├── 0002-use-supabase-for-database.md
└── 0003-use-{deployment-provider}-for-deployment.md
```

## 技術選定スコアリングマトリクス

6軸で候補を評価:

| 軸 | 重み | 説明 |
|----|------|------|
| 開発速度 | 25% | MVP を最速で構築できるか |
| スケーラビリティ | 20% | ユーザー増加時に対応できるか |
| コスト | 20% | 初期・運用コストの低さ |
| 学習曲線 | 15% | チームが習熟するまでの時間 |
| コミュニティ | 10% | ドキュメント・エコシステムの充実度 |
| メンテナンス性 | 10% | 長期運用の容易さ |

## 品質チェック

- [ ] `docs/tech-stack.md` が作成されているか
- [ ] `app_type` が行頭 `key: value` 形式で定義されているか
- [ ] `deployment_provider` が `vercel` か `cloudflare-pages` のどちらかか
- [ ] `app_domain` が定義されているか
- [ ] `deployment_provider=cloudflare-pages` の場合 `cloudflare_pages_project` があるか
- [ ] `deployment_provider=cloudflare-pages` の場合 `cloudflare_build_command` があるか
- [ ] `deployment_provider=cloudflare-pages` の場合 `cloudflare_build_dir` があるか
- [ ] ADR が `0001`〜`0003` まで作成されているか
