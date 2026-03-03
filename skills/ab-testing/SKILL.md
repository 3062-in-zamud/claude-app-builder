---
name: ab-testing
description: |
  What: A/Bテストの実験設計・Feature Flag実装・統計的有意性判定を行う
  When: Phase 11（グロース最適化フェーズ）
  How: 実験設計 → Feature Flag実装 → 統計判定ロジック → レポートテンプレート生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# ab-testing: A/Bテスト実験基盤

## 概要

「データなき最適化は推測に過ぎない」。仮説駆動のA/Bテスト基盤を構築し、
Feature Flag による安全な実験と統計的に有意な意思決定を支援します。

## ワークフロー

### Step 1: 入力ドキュメントの読み込み

以下のファイルを読み込み、実験対象と計測基盤を把握:

- `docs/requirements.md` - ビジネス要件・KPI
- `docs/analytics-plan.md` - 計測イベント設計
- `docs/pricing-strategy.md` - 価格戦略（存在する場合）

### Step 2: Feature Flag 基盤の選定

Vercel Pro プランの有無で最適な基盤を選定:

| 条件 | 推奨基盤 | 理由 |
|------|----------|------|
| Vercel Pro あり | Vercel Edge Config + Feature Flags | ゼロレイテンシ、Vercelネイティブ |
| Vercel Pro なし | PostHog Feature Flags | 無料枠あり、分析統合 |
| 最小構成 | 環境変数ベース | 外部依存なし、シンプル |

### Step 3: useExperiment カスタムHook実装

`src/hooks/useExperiment.ts` を生成:

```typescript
/**
 * useExperiment - A/Bテスト用カスタムHook
 *
 * 使用方法:
 *   const { variant, track } = useExperiment('pricing-page-v2')
 *   if (variant === 'B') return <NewPricingPage />
 */

type Variant = 'A' | 'B' | string

interface ExperimentConfig {
  name: string
  variants: Variant[]
  weights?: number[] // デフォルト: 均等配分
  defaultVariant: Variant // Feature Flag 取得失敗時のフォールバック
}

export function useExperiment(experimentName: string): {
  variant: Variant
  isLoading: boolean
  track: (event: string, properties?: Record<string, unknown>) => void
}
```

### Step 4: 実験設計テンプレート

各実験に必要な設計書テンプレートを定義:

```markdown
## 実験設計書: [実験名]

### 仮説
- **現状**: [現在の状態/問題]
- **変更**: [何を変えるか]
- **期待**: [どう改善されるか]
- **指標**: [主要指標（1つ）+ 副次指標]

### バリアント定義
| バリアント | 説明 | トラフィック配分 |
|-----------|------|----------------|
| A (Control) | 現行版 | 50% |
| B (Treatment) | 変更版 | 50% |

### サンプルサイズ計算
- ベースライン転換率: [現在の値]%
- 最小検出効果量（MDE）: [目標改善幅]%
- 有意水準（α）: 0.05
- 検出力（1-β）: 0.80
- 必要サンプルサイズ: [計算結果] / バリアント
- 推定実験期間: [日数]日

### Guardrail Metrics（悪化させてはいけない指標）
- [ ] ページ読み込み時間 < 3秒
- [ ] エラー率 < 1%
- [ ] 直帰率が 10% 以上悪化しないこと
```

### Step 5: 統計的有意性判定ロジック

`src/lib/experiment-stats.ts` を生成:

```typescript
/**
 * 二項比率の Z 検定（コンバージョン率の比較）
 */
export function zTestForProportions(
  controlConversions: number,
  controlTotal: number,
  treatmentConversions: number,
  treatmentTotal: number,
  alpha?: number // デフォルト 0.05
): {
  controlRate: number
  treatmentRate: number
  relativeUplift: number
  zScore: number
  pValue: number
  isSignificant: boolean
  confidenceInterval: [number, number]
}

/**
 * カイ二乗検定（3バリアント以上の比較）
 */
export function chiSquaredTest(
  observed: number[][],
  alpha?: number
): {
  chiSquared: number
  degreesOfFreedom: number
  pValue: number
  isSignificant: boolean
}
```

### Step 6: Guardrail Metrics 定義

実験中に監視すべき安全指標を定義:

- **パフォーマンス**: ページ読み込み時間、API レスポンスタイム
- **エラー率**: JavaScript エラー率、API エラー率
- **エンゲージメント**: 直帰率、セッション時間
- **ビジネス**: 収益（実験が収益に悪影響を与えていないか）

Guardrail が閾値を超えた場合の自動停止ルールも定義。

### Step 7: 実験レポートテンプレート

```markdown
## 実験結果レポート: [実験名]

### サマリー
- **期間**: YYYY/MM/DD - YYYY/MM/DD
- **サンプルサイズ**: Control [N] / Treatment [N]
- **結果**: [勝者バリアント] が統計的に有意に優位

### 結果詳細
| 指標 | Control | Treatment | 差分 | p値 | 有意 |
|------|---------|-----------|------|-----|------|

### Guardrail Metrics
| 指標 | 基準値 | 実測値 | 状態 |
|------|--------|--------|------|

### 学び
1. [何がわかったか]
2. [予想と異なった点]

### 次のアクション
- [ ] [勝者バリアントの全展開 / ロールバック]
- [ ] [Feature Flag のクリーンアップ]
- [ ] [次の実験計画]
```

## 出力ファイル

- `src/hooks/useExperiment.ts` - 実験用カスタムHook
- `src/lib/experiment-stats.ts` - 統計判定ロジック
- `docs/ab-testing-guide.md` - A/Bテスト運用ガイド（設計テンプレート + レポートテンプレート含む）

## 品質チェック

- [ ] Feature Flag のデフォルト値が設定されている（取得失敗時にクラッシュしない）
- [ ] サンプルサイズ計算が実験設計に含まれている
- [ ] Guardrail Metrics が定義されている
- [ ] 実験終了後の Feature Flag クリーンアップ手順が記載されている
- [ ] 統計判定ロジックに有意水準（α）が明示されている
- [ ] 実験レポートテンプレートに「学び」と「次のアクション」が含まれている
