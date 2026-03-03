---
name: scaling-strategy
description: |
  What: ユーザー数別スケーリング戦略・パフォーマンスバジェット・キャッシュ戦略を策定する
  When: Phase 13（GA/Scale）でプロダクトの成長に備えたスケーリング計画を立てるとき
  How: マイルストーン別のインフラ構成・コネクションプーリング・キャッシュ・DB最適化を含む段階的スケーリングロードマップを生成する
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - WebSearch
---

# scaling-strategy: 段階的スケーリング戦略

## 概要

プロダクトの成長段階に応じた段階的なスケーリング戦略を策定する。ユーザー数のマイルストーンごとに、インフラ構成・パフォーマンス最適化・コスト管理のバランスを取った実践的なロードマップを生成する。Vercel + Supabase スタックに最適化し、過剰投資を避けながら成長に対応する。

## ワークフロー

### Step 1: プロジェクトコンテキスト読み込み

以下のファイルが存在すれば読み込み、現在のインフラ構成とパフォーマンス状況を把握する:

- `docs/tech-stack.md`
- `docs/monitoring-setup.md`
- `docs/architecture.md`
- `docs/deploy-setup.md`
- `docs/database-schema.md`

存在しないファイルはスキップし、一般的なVercel + Supabaseスタックを前提に進める。

### Step 2: ユーザー数別マイルストーン計画

各マイルストーンで必要なインフラ変更・コスト目安・重点施策を定義する:

#### Stage 1: 0-100ユーザー（MVP/Early Adopter）
- **インフラ**: Supabase Free, Vercel Hobby
- **月額コスト目安**: $0-20
- **重点**: プロダクト改善に集中、スケーリングは不要
- **やること**:
  - 基本的な監視（Vercel Analytics, Supabase Dashboard）
  - エラートラッキング（Sentry Free）
  - 手動パフォーマンスチェック
- **やらないこと**: 早すぎる最適化、有料プランへの移行

#### Stage 2: 100-1,000ユーザー（Product-Market Fit）
- **インフラ**: Supabase Pro ($25/月), Vercel Pro ($20/月)
- **月額コスト目安**: $50-100
- **重点**: パフォーマンス基盤整備、コネクションプーリング有効化
- **やること**:
  - Supabase PgBouncer（コネクションプーリング）有効化
  - データベースインデックス最適化
  - 画像最適化（Next.js Image + CDN）
  - API レスポンスキャッシュ導入
  - バックアップ戦略策定
- **スケーリングトリガー**: p95レスポンス > 3秒、DB接続数 > 50%

#### Stage 3: 1,000-10,000ユーザー（Growth）
- **インフラ**: Supabase Pro/Team, Vercel Pro, CDN最適化
- **月額コスト目安**: $100-500
- **重点**: パフォーマンス最適化、Edge活用、非同期処理
- **やること**:
  - Vercel Edge Functions活用（地理的に近いリージョンで実行）
  - ISR/SSG活用でサーバー負荷軽減
  - Supabase Edge Functions（計算処理のオフロード）
  - データベースパーティショニング検討
  - キュー/バックグラウンドジョブ導入（Inngest/Trigger.dev等）
  - Rate Limiting実装
  - Read Replica検討
- **スケーリングトリガー**: p95レスポンス > 2秒、DB CPU > 70%、月間リクエスト > 1M

#### Stage 4: 10,000+ユーザー（Scale）
- **インフラ**: Supabase Team/Enterprise, Vercel Enterprise検討
- **月額コスト目安**: $500+
- **重点**: マルチリージョン、専用インフラ、SLA保証
- **やること**:
  - マルチリージョンデプロイ検討
  - 専用データベースインスタンス
  - Redis/Upstash導入（セッション、キャッシュ）
  - CDNエッジキャッシュ最適化
  - 専用インフラ移行判断（AWS/GCP直接利用 vs PaaS継続）
  - SLA定義と監視
- **判断ポイント**: PaaSのコスト効率 vs 専用インフラの制御性

### Step 3: Supabase コネクションプーリング設定

PgBouncer（Supabase組み込み）の設定ガイドを作成する:

- **Transaction Mode**（推奨）: リクエストごとに接続を再利用
  - 接続文字列の切り替え方法（ポート6543）
  - Prisma/Drizzle等のORM設定変更手順
  - Prepared Statementsの制限事項
- **Session Mode**: 長時間接続が必要な場合
- **接続数の見積もり方法**:
  - Vercel Serverless: 同時実行数 × リージョン数
  - 推奨プールサイズ計算式
- **モニタリング**: アクティブ接続数の監視方法

### Step 4: キャッシュ戦略

4層のキャッシュ戦略を定義する:

#### Layer 1: ブラウザキャッシュ
- Cache-Control ヘッダー設計
- 静的アセット: `public, max-age=31536000, immutable`
- APIレスポンス: `private, max-age=0, must-revalidate`
- SWR（stale-while-revalidate）パターン

#### Layer 2: CDNキャッシュ（Vercel Edge Network）
- ISR（Incremental Static Regeneration）設定
  - revalidate間隔の設計指針
  - On-Demand Revalidation（Webhook連動）
- SSG（Static Site Generation）対象ページの選定基準
- Edge Cacheのpurge戦略

#### Layer 3: アプリケーションキャッシュ
- React Query / SWR のキャッシュ設定
  - staleTime, cacheTime の推奨値
  - Optimistic Updates パターン
- Server-side メモリキャッシュ（unstable_cache / next/cache）
- APIルートのレスポンスキャッシュ

#### Layer 4: 外部キャッシュ（Growth段階以降）
- Upstash Redis: セッション、頻繁に参照するデータ
- KV Store（Vercel KV）: 設定値、フィーチャーフラグ
- 導入判断基準: DB負荷が70%超 or p95レスポンス > 2秒

### Step 5: パフォーマンスバジェット定義

Core Web Vitals ベースのパフォーマンスバジェットを設定する:

| メトリクス | 目標値 | 警告値 | 測定方法 |
|-----------|--------|--------|---------|
| FCP (First Contentful Paint) | < 1.8s | > 2.5s | Lighthouse / Web Vitals |
| LCP (Largest Contentful Paint) | < 2.5s | > 3.5s | Lighthouse / Web Vitals |
| INP (Interaction to Next Paint) | < 200ms | > 300ms | Web Vitals |
| CLS (Cumulative Layout Shift) | < 0.1 | > 0.15 | Lighthouse / Web Vitals |
| TTFB (Time to First Byte) | < 800ms | > 1.2s | Vercel Analytics |
| バンドルサイズ (JS) | < 200KB | > 300KB | next/bundle-analyzer |

パフォーマンスバジェットの運用方法:
- CI/CDでのLighthouseチェック自動化
- バジェット超過時のアラート設定
- 週次パフォーマンスレビュー手順

### Step 6: データベーススケーリング

段階的なデータベース最適化戦略を策定する:

#### インデックス最適化
- 頻出クエリパターンの特定方法（pg_stat_statements）
- 複合インデックスの設計指針
- 不要インデックスの検出と削除
- EXPLAIN ANALYZEの読み方と活用

#### クエリプロファイリング
- Supabase Dashboard での確認方法
- スロークエリの特定と改善
- N+1問題の検出と解決
- クエリプラン最適化のパターン

#### パーティショニング（10K+ユーザー段階）
- テーブルパーティショニングの判断基準
- 時系列データのRange Partitioning
- テナント別のList Partitioning
- パーティション管理の自動化

#### Read Replica（Growth段階以降）
- Supabase Read Replicaの設定
- 読み取り/書き込みの分離パターン
- レプリケーションラグの許容範囲設計

### Step 7: 非同期処理パターン

スケーラブルな非同期処理の導入計画を作成する:

#### キュー/バックグラウンドジョブ
- **Inngest**: イベント駆動のバックグラウンドジョブ（Vercel統合）
  - ユースケース: メール送信、Webhook処理、データ集計
  - リトライ戦略、タイムアウト設定
- **Trigger.dev**: 長時間実行タスク（Vercel Serverless制限の回避）
  - ユースケース: レポート生成、大量データ処理
- **Supabase Edge Functions + pg_cron**: スケジュールジョブ
  - ユースケース: 定期クリーンアップ、統計計算

#### 非同期処理パターン
- Fire-and-Forget: 結果を待たない処理（ログ記録、通知）
- Request-Response with Queue: 重い処理の非同期化
- Event Sourcing: 変更イベントの記録と再生
- Saga Pattern: 複数サービスにまたがるトランザクション

#### 導入判断基準
- APIレスポンスタイム > 3秒の処理
- Vercel Serverless タイムアウト（10秒/60秒）に近い処理
- ユーザー体験に直接影響しない処理

## 出力ファイル

- `docs/scaling-strategy.md` - スケーリング戦略（全セクション統合）

## 品質チェック

- [ ] 各マイルストーン（0-100, 100-1K, 1K-10K, 10K+）のコスト目安が記載されているか
- [ ] ボトルネック特定方法（メトリクス、ツール、閾値）が明確か
- [ ] コネクションプーリングの設定手順が具体的か
- [ ] キャッシュ戦略が4層（ブラウザ、CDN、アプリ、外部）で整理されているか
- [ ] パフォーマンスバジェットがCore Web Vitalsに準拠しているか
- [ ] データベース最適化の段階が成長フェーズに対応しているか
- [ ] 非同期処理の導入判断基準が明確か
- [ ] 各段階のスケーリングトリガー（いつ次の段階に移るか）が定義されているか
