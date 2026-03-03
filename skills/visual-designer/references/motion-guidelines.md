# モーション/アニメーション設計ガイドライン

## 概要

UIアニメーションは「意味のある動き」で UX を向上させる。
過剰なアニメーションは逆効果になるため、目的に応じた適切な設計が必要。

## アニメーションの目的

| 目的 | 説明 | 例 |
|------|------|-----|
| フィードバック | ユーザー操作への応答 | ボタンのプレス、フォーム送信成功 |
| 状態変化 | UI状態の変化を伝達 | トグルの切替、アコーディオン開閉 |
| 注目誘導 | 重要な要素への注意喚起 | 通知バッジ、エラー表示 |
| 空間的連続性 | 画面遷移のつながり | ページトランジション、モーダル |
| 待機時間の緩和 | ロード中の体感時間短縮 | スケルトンローディング |

## Duration（持続時間）ガイド

| カテゴリ | Duration | 用途 |
|----------|----------|------|
| Instant | 0-100ms | 色変化、opacity 変化 |
| Quick | 100-200ms | ホバー、フォーカス、トグル |
| Normal | 200-350ms | モーダル、ドロワー、タブ切替 |
| Slow | 350-500ms | ページトランジション、複雑なレイアウト変更 |
| Deliberate | 500ms+ | エントランスアニメーション、ステップ表示 |

**原則**: 小さい要素は速く、大きい要素は遅くする。

## Easing（イージング）ガイド

| Easing | CSS値 | 用途 |
|--------|------|------|
| ease-out | `cubic-bezier(0, 0, 0.2, 1)` | 要素の出現（勢いよく出て減速） |
| ease-in | `cubic-bezier(0.4, 0, 1, 1)` | 要素の退場（加速して消える） |
| ease-in-out | `cubic-bezier(0.4, 0, 0.2, 1)` | 状態変化（滑らかな遷移） |
| spring | `type: "spring", stiffness: 300, damping: 20` | 強調・バウンス効果 |
| linear | `cubic-bezier(0, 0, 1, 1)` | プログレスバー等の一定速度 |

## Framer Motion 標準バリアント

```typescript
// lib/motion.ts

// フェードイン（汎用）
export const fadeIn = {
  initial: { opacity: 0, y: 8 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -8 },
  transition: { duration: 0.3, ease: [0, 0, 0.2, 1] },
}

// スライドイン（サイドバー・ドロワー）
export const slideIn = {
  initial: { x: '-100%' },
  animate: { x: 0 },
  exit: { x: '-100%' },
  transition: { duration: 0.3, ease: [0.4, 0, 0.2, 1] },
}

// スケールイン（モーダル・ダイアログ）
export const scaleIn = {
  initial: { opacity: 0, scale: 0.95 },
  animate: { opacity: 1, scale: 1 },
  exit: { opacity: 0, scale: 0.95 },
  transition: { duration: 0.2, ease: [0, 0, 0.2, 1] },
}

// スタッガー（リスト表示）
export const staggerContainer = {
  animate: {
    transition: {
      staggerChildren: 0.05,
      delayChildren: 0.1,
    },
  },
}

export const staggerItem = {
  initial: { opacity: 0, y: 16 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.3, ease: [0, 0, 0.2, 1] },
}

// パルス（通知バッジ）
export const pulse = {
  animate: {
    scale: [1, 1.1, 1],
    transition: { duration: 0.6, repeat: 2 },
  },
}

// スケルトンローディング
export const shimmer = {
  animate: {
    backgroundPosition: ['200% 0', '-200% 0'],
    transition: { duration: 1.5, repeat: Infinity, ease: 'linear' },
  },
}
```

## アクセシビリティ対応

```css
/* prefers-reduced-motion 対応 */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

```typescript
// Framer Motion での対応
import { useReducedMotion } from 'framer-motion'

function MyComponent() {
  const shouldReduceMotion = useReducedMotion()

  return (
    <motion.div
      animate={{ opacity: 1, y: shouldReduceMotion ? 0 : 8 }}
      transition={{ duration: shouldReduceMotion ? 0 : 0.3 }}
    />
  )
}
```

## パフォーマンス注意事項

| プロパティ | GPU加速 | 推奨度 |
|-----------|---------|--------|
| transform (translate, scale, rotate) | あり | 推奨 |
| opacity | あり | 推奨 |
| width, height | なし | 避ける |
| top, left, right, bottom | なし | 避ける |
| background-color | なし | 短時間なら可 |
| box-shadow | なし | 避ける（filter: drop-shadow を代用） |

**原則**: `transform` と `opacity` のみアニメーションする（Compositor Layer で処理）。
