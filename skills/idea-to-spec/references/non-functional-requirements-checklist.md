# 非機能要件チェックリスト

## 概要

MVP でも考慮すべき非機能要件を4カテゴリに整理する。
各要件について MVP 基準（最低限）と将来基準（スケール時）を定義する。

## 1. 性能（Performance）

| 要件 | MVP基準 | 将来基準 | 測定方法 |
|------|---------|---------|---------|
| 初回ページ読み込み（LCP） | < 3.0秒 | < 1.5秒 | Lighthouse |
| API レスポンス時間（p95） | < 500ms | < 200ms | Sentry / Vercel Analytics |
| Time to Interactive（TTI） | < 5.0秒 | < 3.0秒 | Lighthouse |
| First Input Delay（FID） | < 300ms | < 100ms | Core Web Vitals |
| Cumulative Layout Shift（CLS） | < 0.25 | < 0.1 | Core Web Vitals |
| バンドルサイズ（JS） | < 300KB | < 150KB | next build --analyze |
| 画像最適化 | next/image 使用 | + CDN | 手動確認 |
| データベースクエリ時間 | < 200ms | < 50ms | Supabase Dashboard |

## 2. セキュリティ（Security）

| 要件 | MVP基準 | 将来基準 | 確認方法 |
|------|---------|---------|---------|
| 認証方式 | Supabase Auth（メール/パスワード） | + OAuth + MFA | 手動テスト |
| データ暗号化（通信） | HTTPS（Vercel 標準） | + Certificate Pinning | 自動 |
| データ暗号化（保管） | Supabase 標準暗号化 | + フィールドレベル暗号化 | 設定確認 |
| アクセス制御 | RLS（Row Level Security） | + ABAC | security-hardening |
| 入力バリデーション | Zod でサーバーサイド検証 | + Rate Limiting | コードレビュー |
| CSRF 対策 | SameSite Cookie | + CSRF Token | security-hardening |
| XSS 対策 | React デフォルトエスケープ | + CSP ヘッダー | security-hardening |
| 依存関係の脆弱性 | npm audit（HIGH以上なし） | + Snyk 統合 | CI |
| シークレット管理 | .env + Vercel 環境変数 | + Secret Manager | 手動確認 |

## 3. 可用性（Availability）

| 要件 | MVP基準 | 将来基準 | 確認方法 |
|------|---------|---------|---------|
| 稼働率 SLA | 99%（月間 ~7.3時間のダウンタイム許容） | 99.9% | Uptime Monitor |
| エラーレート | < 5% | < 1% | Sentry |
| バックアップ | Supabase 自動バックアップ（日次） | + PITR（Point-in-Time Recovery） | Supabase Dashboard |
| 障害復旧時間（RTO） | < 4時間 | < 30分 | Runbook |
| データ復旧時点（RPO） | < 24時間 | < 1時間 | バックアップ設定 |
| ヘルスチェック | /api/health エンドポイント | + 外部監視 | curl テスト |
| グレースフルデグラデーション | エラーバウンダリ表示 | + フォールバックUI | 手動テスト |

## 4. 拡張性（Scalability）

| 要件 | MVP基準 | 将来基準 | 確認方法 |
|------|---------|---------|---------|
| 同時接続数 | 100 | 10,000 | 負荷テスト |
| データ量 | 〜10GB | 〜1TB | Supabase Dashboard |
| API レートリミット | 100 req/min/user | カスタム | ミドルウェア |
| CDN | Vercel Edge Network | + 画像CDN | 自動 |
| DB コネクションプーリング | Supabase 標準 | + PgBouncer | 設定確認 |
| 水平スケーリング | Vercel Serverless（自動） | + Edge Functions | 自動 |
| キャッシュ戦略 | ISR（Incremental Static Regeneration） | + Redis | next.config 確認 |

## 優先度マトリクス

MVP で必須（MUST）の非機能要件:

| # | カテゴリ | 要件 | 理由 |
|---|---------|------|------|
| 1 | セキュリティ | RLS 有効化 | データ漏洩防止 |
| 2 | セキュリティ | HTTPS | 通信保護 |
| 3 | セキュリティ | 入力バリデーション | インジェクション防止 |
| 4 | 性能 | LCP < 3秒 | UX最低基準 |
| 5 | 可用性 | ヘルスチェック | 監視の基盤 |
| 6 | 可用性 | エラーバウンダリ | クラッシュ防止 |

## requirements.md への記載形式

```markdown
## 非機能要件

### 性能要件
- ページ読み込み: LCP < [X]秒
- API レスポンス: p95 < [X]ms

### セキュリティ要件
- 認証: [方式]
- アクセス制御: [方式]

### 可用性要件
- 稼働率: [X]%
- バックアップ: [方式]

### 拡張性要件
- 同時接続: [X]ユーザー
- データ量: [X]GB
```
