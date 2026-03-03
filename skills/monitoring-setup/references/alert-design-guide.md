# P0-P3 アラート設計ガイド

## アラート優先度定義

### P0: Critical（即時対応）

| 項目 | 内容 |
|------|------|
| **対応時間** | 5分以内に対応開始 |
| **通知先** | PagerDuty（オンコール）+ Slack #alerts-critical + 電話 |
| **条件例** | サービス全面停止、データ漏洩、全ユーザー影響 |
| **エスカレーション** | 15分未対応 → マネージャーにエスカレーション |

**Sentry アラート設定**:
```
条件: 1分間に50件以上の5xxエラー
   OR 5分間ヘルスチェック失敗
   OR セキュリティイベント検出
アクション: PagerDuty + Slack + Email
```

### P1: High（1時間以内対応）

| 項目 | 内容 |
|------|------|
| **対応時間** | 1時間以内に対応開始 |
| **通知先** | Slack #alerts-high + メール |
| **条件例** | 主要機能の障害、エラー率5%超、レイテンシ大幅劣化 |
| **エスカレーション** | 2時間未解決 → P0にエスカレーション |

**Sentry アラート設定**:
```
条件: 5分間に10件以上の5xxエラー
   OR p99レイテンシ > 2秒が5分以上継続
   OR 認証エラー率が10%超
アクション: Slack + Email
```

### P2: Medium（4時間以内対応）

| 項目 | 内容 |
|------|------|
| **対応時間** | 4時間以内（営業時間内） |
| **通知先** | Slack #alerts-medium |
| **条件例** | パフォーマンス劣化、部分障害、Error Budget 25%消費 |
| **エスカレーション** | 翌営業日未解決 → P1にエスカレーション |

**Sentry アラート設定**:
```
条件: 1時間に50件以上のエラー
   OR p99レイテンシ > 1秒が30分以上継続
   OR Error Budget が25%を下回った
アクション: Slack
```

### P3: Low（翌営業日対応）

| 項目 | 内容 |
|------|------|
| **対応時間** | 翌営業日 |
| **通知先** | メール（日次ダイジェスト） |
| **条件例** | 軽微な問題、閾値接近、非クリティカルな警告 |
| **エスカレーション** | 1週間未解決 → P2にエスカレーション |

**Sentry アラート設定**:
```
条件: 新しいエラータイプの初回発生
   OR 1日のエラー件数が通常の2倍
   OR Lighthouse スコアが閾値を下回った
アクション: Email（日次ダイジェスト）
```

## Sentry アラートルール設定

### Next.js + Sentry でのアラート設定手順

1. Sentry Dashboard > Alerts > Create Alert Rule
2. 以下のルールを作成:

```yaml
# P0: サービス停止検出
- name: "[P0] Service Down"
  conditions:
    - type: event_frequency
      value: 50
      interval: 1m
      comparisonType: count
  filters:
    - type: level
      value: error
  actions:
    - type: pagerduty
    - type: slack
      channel: "#alerts-critical"
    - type: email

# P1: エラー率上昇
- name: "[P1] High Error Rate"
  conditions:
    - type: event_frequency
      value: 10
      interval: 5m
  filters:
    - type: level
      value: error
  actions:
    - type: slack
      channel: "#alerts-high"
    - type: email

# P2: パフォーマンス劣化
- name: "[P2] Performance Degradation"
  conditions:
    - type: event_frequency
      value: 50
      interval: 1h
  actions:
    - type: slack
      channel: "#alerts-medium"

# P3: 新規エラー検出
- name: "[P3] New Error Type"
  conditions:
    - type: first_seen_event
  actions:
    - type: email
      targetType: team
```

## エスカレーションフロー

```
P3 発生
  │
  ├─ 翌営業日に対応開始
  │    └─ 1週間未解決 → P2 にエスカレーション
  │
P2 発生
  │
  ├─ 4時間以内に対応開始
  │    └─ 翌営業日未解決 → P1 にエスカレーション
  │
P1 発生
  │
  ├─ 1時間以内に対応開始
  │    └─ 2時間未解決 → P0 にエスカレーション
  │
P0 発生
  │
  ├─ 5分以内に対応開始
  │    └─ 15分未対応 → マネージャー通知
  │         └─ 30分未解決 → 経営層通知
  │
  └─ 解決後: ポストモーテム実施（48時間以内）
```

## アラート疲れ防止

### ルール

| ルール | 説明 |
|--------|------|
| **アクション可能** | すべてのアラートに対して具体的なアクションが取れること |
| **重複排除** | 同一原因のアラートは集約する |
| **閾値調整** | 2週間ごとにアラート頻度をレビュー |
| **ミュート期間** | メンテナンス時はアラートをミュート |
| **オンコール交代** | P0対応者は週次ローテーション |

### アラート品質指標

```markdown
## アラート品質レビュー（月次）

| 指標 | 目標 | 実績 |
|------|------|------|
| 偽陽性率 | < 10% | [X]% |
| アクション不要率 | < 5% | [X]% |
| P0 MTTR（平均修復時間） | < 30分 | [X]分 |
| P1 MTTR | < 2時間 | [X]時間 |
| エスカレーション率 | < 10% | [X]% |
```

## ポストモーテムテンプレート

P0/P1 インシデント解決後、48時間以内にポストモーテムを実施:

```markdown
# ポストモーテム: [インシデントタイトル]

## 概要
- **日時**: YYYY-MM-DD HH:MM - HH:MM (JST)
- **影響時間**: X分
- **影響範囲**: [全ユーザー / 特定機能 / 一部ユーザー]
- **優先度**: P[0/1]
- **Error Budget 消費**: [X]%

## タイムライン
| 時刻 | イベント |
|------|---------|
| HH:MM | [最初の異常検知] |
| HH:MM | [アラート発報] |
| HH:MM | [対応開始] |
| HH:MM | [原因特定] |
| HH:MM | [修正デプロイ] |
| HH:MM | [復旧確認] |

## 根本原因
[技術的な根本原因を記述]

## 影響
- [影響を受けたユーザー数]
- [影響を受けた機能]
- [ビジネス影響]

## 再発防止策
| アクション | 担当 | 期限 | 種別 |
|-----------|------|------|------|
| [具体的なアクション] | [担当者] | [期限] | 予防/検知/緩和 |

## 教訓
- [良かった点]
- [改善すべき点]
```

## Slack 通知フォーマット

```typescript
// アラート通知テンプレート
function formatAlertMessage(alert: {
  priority: 'P0' | 'P1' | 'P2' | 'P3'
  title: string
  description: string
  sentryUrl: string
}) {
  const emoji = {
    P0: ':rotating_light:',
    P1: ':warning:',
    P2: ':large_yellow_circle:',
    P3: ':information_source:',
  }

  return {
    text: `${emoji[alert.priority]} [${alert.priority}] ${alert.title}`,
    blocks: [
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*${emoji[alert.priority]} [${alert.priority}] ${alert.title}*\n${alert.description}`,
        },
      },
      {
        type: 'actions',
        elements: [
          {
            type: 'button',
            text: { type: 'plain_text', text: 'Sentry で確認' },
            url: alert.sentryUrl,
          },
        ],
      },
    ],
  }
}
```
