# SLO/SLI/Error Budget 定義テンプレート

## 用語の整理

| 用語 | 正式名称 | 説明 | 例 |
|------|---------|------|-----|
| **SLI** | Service Level Indicator | サービス品質の計測指標 | 成功リクエスト率 |
| **SLO** | Service Level Objective | SLI の目標値 | 成功リクエスト率 >= 99.9% |
| **SLA** | Service Level Agreement | 顧客との契約（違反時にペナルティ） | SLA = SLO - マージン |
| **Error Budget** | エラーバジェット | 許容される障害量 | 月間43.8分のダウンタイム |

## SLI 定義テンプレート

### 可用性（Availability）

```
SLI = 成功レスポンス数 / 全リクエスト数
```

計測方法:
- provider Analytics のステータスコード分布
- Sentry のエラーイベント数
- Uptime モニタリング（UptimeRobot, Betterstack）

```typescript
// カスタム計測: API Route でレスポンスを記録
const availabilitySLI = {
  totalRequests: 0,
  successfulRequests: 0, // 2xx, 3xx
  get value() {
    return this.totalRequests > 0
      ? this.successfulRequests / this.totalRequests
      : 1
  },
}
```

### レイテンシ（Latency）

```
SLI = p99(レスポンス時間) < 閾値 のリクエスト割合
```

計測方法:
- provider Performance Analytics（TTFB, FCP, LCP）
- Sentry Performance（トランザクション時間）

### エラーレート（Error Rate）

```
SLI = エラーリクエスト数(5xx) / 全リクエスト数
```

計測方法:
- Sentry エラーイベント数
- provider Logs のステータスコード

## SLO 定義テンプレート

### MVP向け推奨SLO

| SLI | SLO | 理由 |
|-----|-----|------|
| 可用性 | >= 99.9% (Three Nines) | MVP では十分。99.99% は運用負荷が高い |
| レイテンシ (p50) | < 200ms | ユーザー体感として快適 |
| レイテンシ (p99) | < 500ms | 最悪ケースでも許容範囲 |
| エラーレート | < 0.1% | ビジネスに影響しない水準 |
| FCP | < 1.8s | Core Web Vitals 基準 |
| LCP | < 2.5s | Core Web Vitals 基準 |

### SLO ドキュメントテンプレート (docs/slo.md)

```markdown
# [サービス名] SLO 定義

## 対象期間
- 計測期間: ローリング30日間
- レビュー頻度: 月次

## SLO 一覧

### 1. 可用性
- **SLI**: HTTP 2xx/3xx レスポンスの割合
- **SLO**: >= 99.9%
- **計測方法**: provider Analytics + Sentry
- **除外条件**: メンテナンスウィンドウ（事前通知済み）

### 2. レイテンシ
- **SLI**: API レスポンス時間の p99
- **SLO**: < 500ms
- **計測方法**: Sentry Performance Monitoring

### 3. エラーレート
- **SLI**: HTTP 5xx レスポンスの割合
- **SLO**: < 0.1%
- **計測方法**: Sentry エラーイベント

## Error Budget ポリシー
[下記参照]
```

## Error Budget 計算

### 計算式

```
Error Budget = 1 - SLO

例: SLO 99.9% の場合
Error Budget = 1 - 0.999 = 0.001 = 0.1%
```

### 月間ダウンタイム換算

| SLO | Error Budget | 月間ダウンタイム | 年間ダウンタイム |
|-----|-------------|----------------|----------------|
| 99% | 1% | 7.3時間 | 3.65日 |
| 99.9% | 0.1% | 43.8分 | 8.77時間 |
| 99.95% | 0.05% | 21.9分 | 4.38時間 |
| 99.99% | 0.01% | 4.4分 | 52.6分 |

### Error Budget 消費トラッキング

```typescript
// Error Budget 計算の概念
interface ErrorBudgetTracker {
  slo: number              // 例: 0.999
  windowDays: 30           // ローリング30日
  totalRequests: number    // 期間内の全リクエスト数
  failedRequests: number   // 期間内の失敗リクエスト数

  get budgetTotal(): number {
    // 許容される失敗数
    return Math.floor(this.totalRequests * (1 - this.slo))
  }

  get budgetRemaining(): number {
    return this.budgetTotal - this.failedRequests
  }

  get budgetRemainingPercent(): number {
    return (this.budgetRemaining / this.budgetTotal) * 100
  }
}
```

## Error Budget ポリシー

### Budget 残量に応じたアクション

| Budget 残量 | ステータス | アクション |
|------------|----------|----------|
| **> 50%** | 正常 | 通常開発。機能追加優先 |
| **25-50%** | 注意 | 信頼性改善タスクを並行実施 |
| **10-25%** | 警告 | 機能追加を停止。信頼性改善に集中 |
| **< 10%** | 危険 | デプロイ凍結。ロールバック基準を厳格化 |
| **0%** | 超過 | 全チーム信頼性改善にフォーカス。ポストモーテム実施 |

### デプロイ判断基準

```markdown
## デプロイ可否チェック

Budget 残量 > 50%:
  - [x] 通常デプロイ可能
  - [x] リスクのある変更も許可

Budget 残量 25-50%:
  - [x] 低リスク変更のみデプロイ可能
  - [ ] 大規模リファクタリングは延期

Budget 残量 < 25%:
  - [ ] バグ修正・信頼性改善のみデプロイ可能
  - [ ] 機能追加は凍結

Budget 残量 < 10%:
  - [ ] 緊急修正のみデプロイ可能
  - [ ] カナリアデプロイ必須
  - [ ] ロールバック手順を事前準備
```

## レビューテンプレート

### 月次 SLO レビュー

```markdown
# SLO 月次レビュー: [YYYY-MM]

## サマリー
- 可用性: [実績]% / [目標]% → [OK/NG]
- レイテンシ p99: [実績]ms / [目標]ms → [OK/NG]
- エラーレート: [実績]% / [目標]% → [OK/NG]
- Error Budget 残量: [X]%

## 主要インシデント
1. [日付] - [概要] - [影響時間] - [Budget 消費量]

## 今月のアクション
- Budget > 50%: 通常開発を継続
- Budget 25-50%: [信頼性改善タスクを追加]
- Budget < 25%: [機能凍結判断]

## 来月の計画
- [SLO 調整の要否]
- [インフラ改善の予定]
```
