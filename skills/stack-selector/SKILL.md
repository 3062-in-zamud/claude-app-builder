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
| `mobile` | モバイルアプリ | React Native + Expo |

**モバイルアプリ（React Native / Expo）**:
- React Native + Expo
- 注意: `/app-builder` フルフローは現在 Web アプリのみ対応です
  モバイルを選択した場合は各フェーズのスキルを手動実行してください

⚠️ モバイルアプリを選択した場合:
「`/app-builder` は現在 Web アプリのみ自動化対応です。
各フェーズのスキルを手動で実行してください。」

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

## ADR（Architecture Decision Record）

技術選定の各判断を ADR として記録する。`references/adr-template.md` を使用。

```
docs/adr/
├── 0001-use-nextjs-app-router.md
├── 0002-use-supabase-for-database.md
└── 0003-use-vercel-for-deployment.md
```

主要な技術選定（フレームワーク、DB、認証、デプロイ先）ごとに ADR を1件作成する。

## 技術選定スコアリングマトリクス

技術候補を6軸で定量評価する:

| 軸 | 重み | 説明 |
|----|------|------|
| 開発速度 | 25% | MVP を最速で構築できるか |
| スケーラビリティ | 20% | ユーザー増加時に対応できるか |
| コスト | 20% | 初期・運用コストの低さ |
| 学習曲線 | 15% | チームが習熟するまでの時間 |
| コミュニティ | 10% | ドキュメント・エコシステムの充実度 |
| メンテナンス性 | 10% | 長期運用の容易さ |

```markdown
### 技術選定スコアリング（例: フロントエンド）

| 候補 | 開発速度(25) | スケール(20) | コスト(20) | 学習(15) | コミュニティ(10) | 保守(10) | 合計 |
|------|------------|------------|----------|---------|---------------|---------|------|
| Next.js | 23 | 18 | 18 | 12 | 9 | 9 | 89 |
| Remix | 20 | 17 | 18 | 10 | 7 | 8 | 80 |
| Nuxt.js | 21 | 16 | 18 | 11 | 7 | 8 | 81 |
```

## ユーザー数別コスト予測

`references/cost-estimation-template.md` に従い、スケール時のインフラコストを予測する:

| ユーザー数 | Vercel | Supabase | その他 | 月額合計 |
|-----------|--------|----------|--------|---------|
| 〜100 | $0 (Hobby) | $0 (Free) | - | $0 |
| 〜1,000 | $20 (Pro) | $25 (Pro) | - | $45 |
| 〜10,000 | $20 + 従量 | $25 + 従量 | Sentry $29 | ~$100 |
| 〜100,000 | Enterprise | Team $599 | + CDN | ~$800+ |

tech-stack.md に「コスト予測」セクションとして記載する。

### 品質チェック

- [ ] アプリタイプが明確に判定されているか
- [ ] 選定理由が記載されているか
- [ ] 必要な npm パッケージが列挙されているか
- [ ] 主要技術選定ごとに ADR が作成されているか
- [ ] 技術選定スコアリングマトリクスが含まれているか
- [ ] ユーザー数別コスト予測が tech-stack.md に含まれているか
