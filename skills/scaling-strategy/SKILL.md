---
name: scaling-strategy
description: |
  What: ユーザー数別スケーリング戦略・パフォーマンスバジェット・キャッシュ戦略を策定する
  When: Phase 13（GA/Scale）でプロダクトの成長に備えたスケーリング計画を立てるとき
  How: deployment_provider を前提に、マイルストーン別のインフラ構成・キャッシュ・DB最適化を段階的に設計する
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - WebSearch
---

# scaling-strategy: 段階的スケーリング戦略

## 概要

プロダクトの成長段階に応じた段階的なスケーリング戦略を策定する。
ユーザー数のマイルストーンごとに、インフラ構成・パフォーマンス最適化・コスト管理のバランスを取った実践的なロードマップを生成する。

このスキルは `deployment_provider`（`vercel` / `cloudflare-pages`）に追従し、provider前提の実行制約と運用コストを明示する。

## ワークフロー

### Step 1: プロジェクトコンテキスト読み込み

以下のファイルが存在すれば読み込み、現在のインフラ構成とパフォーマンス状況を把握する:

- `docs/tech-stack.md`
- `docs/monitoring-setup.md`
- `docs/architecture.md`
- `docs/deploy-setup.md`
- `docs/database-schema.md`

`docs/tech-stack.md` がある場合は `deployment_provider` を必ず確認する。

```bash
extract_value() {
  local key="$1"
  grep -E "^[[:space:]-]*${key}:" docs/tech-stack.md 2>/dev/null | head -1 | sed -E "s/^[[:space:]-]*${key}:[[:space:]]*//" | tr -d '\r'
}

if [ -f docs/tech-stack.md ]; then
  DEPLOYMENT_PROVIDER="$(extract_value deployment_provider)"
  [ -n "$DEPLOYMENT_PROVIDER" ] || { echo "❌ deployment_provider が未定義です"; exit 1; }
fi
```

### Step 2: ユーザー数別マイルストーン計画

各マイルストーンで必要なインフラ変更・コスト目安・重点施策を定義する:

#### Stage 1: 0-100ユーザー（MVP/Early Adopter）
- **インフラ**: Supabase Free + provider Free（Vercel Hobby または Cloudflare Pages Free）
- **月額コスト目安**: $0-30
- **重点**: PMF検証を優先、過剰最適化を避ける
- **やること**:
  - 基本監視（Sentry + provider Analytics）
  - 手動パフォーマンスチェック
  - ボトルネック計測の基準線作成

#### Stage 2: 100-1,000ユーザー（Product-Market Fit）
- **インフラ**: Supabase Pro + provider有料プラン（必要時）
- **月額コスト目安**: $50-150
- **重点**: DB接続とレスポンス安定化
- **やること**:
  - Supabase PgBouncer（コネクションプーリング）有効化
  - インデックス最適化
  - APIレスポンスキャッシュ導入
  - バックアップ/復旧手順の明文化
- **スケーリングトリガー**: p95レスポンス > 3秒、DB接続数 > 50%

#### Stage 3: 1,000-10,000ユーザー（Growth）
- **インフラ**: Supabase Pro/Team + provider最適化
- **月額コスト目安**: $150-700
- **重点**: CDN/Edge活用と非同期化
- **やること**:
  - providerのEdge実行基盤を活用（Vercel Edge Functions / Cloudflare Workers）
  - ISR/SSGやキャッシュ戦略でサーバー負荷軽減
  - 非同期ジョブ導入（Inngest / Trigger.dev / Queues）
  - Rate Limiting実装
  - Read Replica検討
- **スケーリングトリガー**: p95レスポンス > 2秒、DB CPU > 70%、月間リクエスト > 1M

#### Stage 4: 10,000+ユーザー（Scale）
- **インフラ**: Supabase Team/Enterprise + provider上位プラン/専用構成
- **月額コスト目安**: $700+
- **重点**: SLA・マルチリージョン・運用自動化
- **やること**:
  - マルチリージョン配信の検討
  - 高負荷ワークロード分離（読み取り/書き込み、同期/非同期）
  - キャッシュ階層の再設計
  - 専用インフラ移行判断（PaaS継続 vs AWS/GCP直利用）

### Step 3: provider別の最適化観点

| 領域 | vercel | cloudflare-pages |
|------|--------|-------------------|
| エッジ実行 | Edge Functions / ISR | Pages Functions / Workers |
| CDNキャッシュ | Vercel Edge Network | Cloudflare CDN / Cache Rules |
| ログ/分析 | Vercel Analytics + Logs | Cloudflare Analytics + Logs |
| デプロイ運用 | Immutable Deploy + Rollback | Pages Deploy + Previous Deployment への復帰 |

### Step 4: Supabase コネクションプーリング設定

PgBouncer（Supabase組み込み）の設定ガイドを作成する:

- **Transaction Mode**（推奨）
  - 接続文字列の切り替え方法（ポート6543）
  - Prisma/Drizzle等のORM設定変更手順
  - Prepared Statementsの制限事項
- **Session Mode**（長時間接続が必要な場合）
- **接続数の見積もり方法**:
  - provider Functions の同時実行数 × リージョン数
  - 推奨プールサイズ計算式
- **モニタリング**: アクティブ接続数の監視方法

### Step 5: キャッシュ戦略

4層のキャッシュ戦略を定義する:

#### Layer 1: ブラウザキャッシュ
- Cache-Control ヘッダー設計
- 静的アセット: `public, max-age=31536000, immutable`
- APIレスポンス: `private, max-age=0, must-revalidate`
- SWR（stale-while-revalidate）パターン

#### Layer 2: CDNキャッシュ（provider Edge Network）
- ISR（Incremental Static Regeneration）設定
- SSG（Static Site Generation）対象ページ選定
- Edge Cache purge戦略

#### Layer 3: アプリケーションキャッシュ
- React Query / SWR のキャッシュ設定
- Server-side メモリキャッシュ（`unstable_cache` / `next/cache`）
- APIルートのレスポンスキャッシュ

#### Layer 4: 外部キャッシュ（Growth以降）
- Upstash Redis: セッション、頻出データ
- provider系KV（Cloudflare KV等）: フラグ・設定値
- 導入判断: DB負荷が70%超 or p95レスポンス > 2秒

### Step 6: パフォーマンスバジェット定義

Core Web Vitals ベースのバジェットを設定する:

| メトリクス | 目標値 | 警告値 | 測定方法 |
|-----------|--------|--------|---------|
| FCP | < 1.8s | > 2.5s | Lighthouse / Web Vitals |
| LCP | < 2.5s | > 3.5s | Lighthouse / Web Vitals |
| INP | < 200ms | > 300ms | Web Vitals |
| CLS | < 0.1 | > 0.15 | Lighthouse / Web Vitals |
| TTFB | < 800ms | > 1.2s | provider Analytics / RUM |
| バンドルサイズ(JS) | < 200KB | > 300KB | bundle-analyzer |

運用:
- CI/CDでLighthouseチェック自動化
- バジェット超過時のアラート
- 週次パフォーマンスレビュー

### Step 7: データベーススケーリング

段階的なDB最適化戦略を策定する:

- インデックス最適化（`pg_stat_statements`、`EXPLAIN ANALYZE`）
- スロークエリ特定とN+1解消
- 10K+段階でのパーティショニング検討
- Growth段階でのRead Replica導入検討

### Step 8: 非同期処理パターン

スケーラブルな非同期処理の導入計画を作成する:

- **Inngest**: イベント駆動ジョブ（メール、Webhook、集計）
- **Trigger.dev**: 長時間処理（レポート生成など）
- **Supabase Edge Functions + pg_cron**: 定期ジョブ
- **Cloudflare Queues（cloudflare-pages時）**: provider内ジョブ連携

導入判断基準:
- APIレスポンス > 3秒の処理
- provider Functions のタイムアウト上限に近い処理
- ユーザー体験に非同期化可能な処理

## 出力ファイル

- `docs/scaling-strategy.md` - スケーリング戦略（全セクション統合）

## 品質チェック

- [ ] 各マイルストーン（0-100, 100-1K, 1K-10K, 10K+）のコスト目安が記載されているか
- [ ] `deployment_provider` に応じた運用制約が明記されているか
- [ ] ボトルネック特定方法（メトリクス、ツール、閾値）が明確か
- [ ] コネクションプーリングの設定手順が具体的か
- [ ] キャッシュ戦略が4層（ブラウザ、CDN、アプリ、外部）で整理されているか
- [ ] パフォーマンスバジェットがCore Web Vitalsに準拠しているか
- [ ] データベース最適化の段階が成長フェーズに対応しているか
- [ ] 非同期処理の導入判断基準が明確か
- [ ] 各段階のスケーリングトリガーが定義されているか
