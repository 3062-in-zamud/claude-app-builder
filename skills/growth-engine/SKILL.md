---
name: growth-engine
description: |
  What: 成長エンジン - Alpha→有料化→Beta→GA までを統括するオーケストレーター
  When: app-builder完了後に /growth-engine で起動。Stage D〜Fを自動実行
  How: 価格設計→決済→オンボーディング→メール→A/Bテスト→GDPR→リテンション→スケーリングを順次/並列実行
model: claude-opus-4-6
allowed-tools:
  - Task
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# Growth Engine - 成長フェーズオーケストレーター

## 概要

app-builder で MVP をリリースした後、プロダクトを「使われるもの」から「稼げるもの」へ進化させます。
Stage D（Alpha → 有料化）、Stage E（Beta → 成長）、Stage F（GA & Scale）の3ステージを
ゲート判定付きで自動実行します。

**ユーザー介入ポイント**:
1. G4: Alpha → Beta 判定（チェックリスト形式でユーザー自己申告）
2. G5: Beta → GA 判定（チェックリスト形式でユーザー自己申告）
3. 各スキル内でのユーザー入力（価格設定の確認等）

## 起動前チェック

```bash
# app-builder の成果物が存在するか確認
test -f docs/requirements.md || { echo "docs/requirements.md が見つかりません。先に /app-builder を実行してください"; exit 1; }
test -f docs/market-research.md || echo "docs/market-research.md が見つかりません（推奨: /market-research を先に実行）"
```

## ステージ実行ワークフロー

---

### Stage D: Alpha → 有料化（Phase 9〜10）

#### Phase 9: 価格戦略設計

**実行スキル（順次）**:
1. `pricing-strategy` [**Opus**] → `docs/pricing-strategy.md`
   - Van Westendorp 価格感度分析フレーム生成
   - Unit Economics 計算（CAC/LTV/Payback Period）
   - Free/Pro/Team 3階層設計
   - 競合価格マッピング

2. `payment-integration` [**Sonnet**] → Stripe 実装コード + `docs/payment-integration.md`
   - Stripe Checkout + Webhook 実装
   - Supabase サブスクリプション管理テーブル
   - Customer Portal 統合
   - トライアル14日 + Dunning 設定

※ payment-integration は pricing-strategy の出力に依存するため**順次実行必須**。

#### Phase 10: オンボーディング + メール

**実行スキル（順次）**:
1. `onboarding-optimizer` [**Opus**] → `docs/onboarding-strategy.md`
   - TTV 分析・短縮設計
   - Aha! Moment 定義
   - チェックリスト型オンボーディングUI設計
   - Drop-off 分析ポイント定義

2. `email-strategy` [**Sonnet**] → メール実装コード + `docs/email-strategy.md`
   - Resend + React Email セットアップ
   - ドリップキャンペーン（Day0〜Day14）
   - トランザクショナルメール
   - 配信停止機能（CAN-SPAM/GDPR準拠）

※ email-strategy は onboarding-strategy の出力に依存するため**順次実行必須**。

---

### [G4] Alpha → Beta 判定ゲート

Stage D 完了後、ユーザーに以下のチェックリストを提示:

```
📋 Alpha → Beta 判定チェックリスト

以下の条件を満たしていますか？（自己申告）

[ ] 有料ユーザーが 10人以上 いる
[ ] 7日リテンション率が 20%以上 である
[ ] Sentry エラー率が 1%未満 である

上記を確認の上、Stage E（Beta → 成長）に進みますか？

1. ✅ 条件を満たしている → Stage E へ進む
2. ⏳ まだ条件を満たしていない → 現時点のアドバイスを提供して終了
3. 🔧 条件は満たしていないが強制的に進む（非推奨）
```

**判定ロジック**:
- 選択1: Stage E を開始
- 選択2: 条件達成のためのアクションプランを提示して終了
- 選択3: 警告を表示した上で Stage E を開始

---

### Stage E: Beta → 成長（Phase 11〜12）

#### Phase 11: 最適化 + コンプライアンス

**実行スキル（並列）**:
- `ab-testing` [**Sonnet**] → A/Bテスト基盤実装
- `conversion-funnel` [**Sonnet**] → コンバージョンファネル分析・最適化

**実行スキル（並列）**:
- `gdpr-compliance` [**Opus**] → GDPR/プライバシー準拠
- `data-deletion` [**Sonnet**] → データ削除パイプライン実装

#### Phase 12: リテンション戦略

**実行スキル**:
- `retention-strategy` [**Opus**] → リテンション戦略設計・実装

---

### [G5] Beta → GA 判定ゲート

Stage E 完了後、ユーザーに以下のチェックリストを提示:

```
📋 Beta → GA 判定チェックリスト

以下の条件を満たしていますか？（自己申告）

[ ] MRR（月次定期収益）が $1,000 以上 である
[ ] 30日リテンション率が 15%以上 である
[ ] 月次チャーンレートが 10%未満 である
[ ] GDPR 準拠が完了している

上記を確認の上、Stage F（GA & Scale）に進みますか？

1. ✅ 条件を満たしている → Stage F へ進む
2. ⏳ まだ条件を満たしていない → 現時点のアドバイスを提供して終了
3. 🔧 条件は満たしていないが強制的に進む（非推奨）
```

---

### Stage F: GA & Scale（Phase 13〜14）

#### Phase 13: 運用体制

**実行スキル（並列）**:
- `incident-response` [**Opus**] → インシデント対応プロセス設計
- `scaling-strategy` [**Sonnet**] → スケーリング戦略・インフラ設計

#### Phase 14: コスト最適化

**実行スキル**:
- `cost-optimization` [**Sonnet**] → インフラ・サービスコスト最適化

---

## 完了報告

```
🚀 Growth Engine 完了！

📊 実装されたもの:
  Stage D (Alpha → 有料化):
    ✅ 価格戦略（docs/pricing-strategy.md）
    ✅ Stripe 決済統合
    ✅ オンボーディング最適化（docs/onboarding-strategy.md）
    ✅ メール戦略（docs/email-strategy.md）

  Stage E (Beta → 成長):
    ✅ A/Bテスト基盤
    ✅ コンバージョンファネル最適化
    ✅ GDPR準拠
    ✅ データ削除パイプライン
    ✅ リテンション戦略

  Stage F (GA & Scale):
    ✅ インシデント対応プロセス
    ✅ スケーリング戦略
    ✅ コスト最適化

📋 次のステップ:
  - Stripe Dashboard でテストモードから本番モードに切り替え
  - ドメインの SPF/DKIM 設定を完了
  - GA4 でカスタムレポートを設定
  - 月次レビューサイクルを開始
```

## エラーハンドリング

### 3回失敗でエスカレーション

```
⚠️ [Stage X - Phase Y: スキル名] で問題が発生しました（試行: 3/3）

エラー内容:
[具体的なエラーメッセージ]

推奨アクション:
1. [具体的な修正手順]
2. このフェーズをスキップして次に進む
3. growth-engine を中断

どうしますか？
```

各スキルの実行時:
1. 1回目の失敗: 自動リトライ（エラー内容を元に修正を試行）
2. 2回目の失敗: 別のアプローチで再試行
3. 3回目の失敗: ユーザーにエスカレーション

## モデル割り当て表

| タスク | モデル | Phase |
|--------|--------|-------|
| リーダー（全体統括） | `claude-opus-4-6` | - |
| pricing-strategy | `claude-opus-4-6` | 9 |
| payment-integration | `claude-sonnet-4-6` | 9.5 |
| onboarding-optimizer | `claude-opus-4-6` | 10 |
| email-strategy | `claude-sonnet-4-6` | 10 |
| ab-testing | `claude-sonnet-4-6` | 11 |
| conversion-funnel | `claude-sonnet-4-6` | 11 |
| gdpr-compliance | `claude-opus-4-6` | 11 |
| data-deletion | `claude-sonnet-4-6` | 11 |
| retention-strategy | `claude-opus-4-6` | 12 |
| incident-response | `claude-opus-4-6` | 13 |
| scaling-strategy | `claude-sonnet-4-6` | 13 |
| cost-optimization | `claude-sonnet-4-6` | 14 |
