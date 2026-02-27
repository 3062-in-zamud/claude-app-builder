# 技術スタックカタログ

## web-fullstack（認証 + DB あり）

**推奨スタック**:
- Next.js 15 + TypeScript
- Tailwind CSS + shadcn/ui
- Supabase（Auth + PostgreSQL + RLS）
- Vercel デプロイ
- Vitest（ユニット）+ Playwright（E2E）

**Pro**: フルスタック一体、Vercel との親和性高、型安全
**Con**: 学習曲線、バンドルサイズ
**適用**: SaaS, SNS, ダッシュボード, EC

---

## web-api（APIのみ）

**推奨スタック**:
- Hono + TypeScript
- Cloudflare Workers
- D1（SQLite）または PostgreSQL
- Zod（バリデーション）

**Pro**: エッジ実行・超高速・コスト低
**Con**: エコシステムが小さい
**適用**: API サービス, Webhook, マイクロサービス

---

## cli（コマンドラインツール）

**推奨スタック**:
- Node.js + TypeScript
- Commander.js（コマンド定義）
- Inquirer.js（対話式入力）
- chalk（カラー出力）
- ora（スピナー）

**Pro**: シンプル・配布容易
**Con**: GUI なし
**適用**: 開発ツール, 自動化スクリプト

---

## tui（ターミナルUI）

**推奨スタック**:
- Ink（React for terminal）+ TypeScript
- Yoga（レイアウト）
- Pastel（スタイリング）

**Pro**: リッチなUI・React の知識が使える
**Con**: Ink のエコシステムが小さい
**適用**: インタラクティブな開発ツール, REPL

---

## モバイルアプリ

| スタック | 用途 | 備考 |
|---------|------|------|
| React Native + Expo | クロスプラットフォームアプリ | `/app-builder` フルフロー非対応 |
