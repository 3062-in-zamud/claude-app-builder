# デザイントークン3層構造

## 概要

デザイントークンを3層に分離し、テーマ変更やリブランディングに強い設計を実現する。

## 3層構造

```
Layer 1: Global Tokens（原子レベル）
  └─ 具体的な値を持つ。ブランドに依存しない汎用的な名前。
     例: color.gray.900, spacing.4, font.size.lg

Layer 2: Alias Tokens（セマンティックレベル）
  └─ Global Tokens を参照する。用途に基づく意味的な名前。
     例: color.primary, color.text.default, spacing.section

Layer 3: Component Tokens（コンポーネントレベル）
  └─ Alias Tokens を参照する。特定コンポーネント固有の名前。
     例: button.bg.primary, card.padding, input.border.focus
```

## Layer 1: Global Tokens

### カラー

```typescript
// tailwind.config.ts
const globalTokens = {
  colors: {
    // Gray scale
    gray: {
      50: '#F9FAFB',
      100: '#F3F4F6',
      200: '#E5E7EB',
      300: '#D1D5DB',
      400: '#9CA3AF',
      500: '#6B7280',
      600: '#4B5563',
      700: '#374151',
      800: '#1F2937',
      900: '#111827',
      950: '#030712',
    },
    // Brand colors（プロジェクトごとに変更）
    blue: {
      50: '#EFF6FF',
      100: '#DBEAFE',
      200: '#BFDBFE',
      300: '#93C5FD',
      400: '#60A5FA',
      500: '#3B82F6',
      600: '#2563EB',
      700: '#1D4ED8',
      800: '#1E40AF',
      900: '#1E3A8A',
    },
    // Semantic colors
    red: { /* error/danger */ },
    green: { /* success */ },
    yellow: { /* warning */ },
  },
  spacing: {
    px: '1px',
    0.5: '2px',
    1: '4px',
    2: '8px',
    3: '12px',
    4: '16px',
    5: '20px',
    6: '24px',
    8: '32px',
    10: '40px',
    12: '48px',
    16: '64px',
    20: '80px',
    24: '96px',
  },
  fontSize: {
    xs: ['0.75rem', { lineHeight: '1rem' }],
    sm: ['0.875rem', { lineHeight: '1.25rem' }],
    base: ['1rem', { lineHeight: '1.5rem' }],
    lg: ['1.125rem', { lineHeight: '1.75rem' }],
    xl: ['1.25rem', { lineHeight: '1.75rem' }],
    '2xl': ['1.5rem', { lineHeight: '2rem' }],
    '3xl': ['1.875rem', { lineHeight: '2.25rem' }],
    '4xl': ['2.25rem', { lineHeight: '2.5rem' }],
  },
  borderRadius: {
    none: '0',
    sm: '0.125rem',
    DEFAULT: '0.25rem',
    md: '0.375rem',
    lg: '0.5rem',
    xl: '0.75rem',
    '2xl': '1rem',
    full: '9999px',
  },
}
```

## Layer 2: Alias Tokens

```typescript
// CSS Custom Properties で定義
const aliasTokens = {
  light: {
    // Background
    '--color-bg-primary': 'var(--gray-50)',     // #F9FAFB
    '--color-bg-secondary': 'var(--white)',      // #FFFFFF
    '--color-bg-tertiary': 'var(--gray-100)',    // #F3F4F6
    '--color-bg-inverse': 'var(--gray-900)',     // #111827

    // Text
    '--color-text-primary': 'var(--gray-900)',   // #111827
    '--color-text-secondary': 'var(--gray-500)', // #6B7280
    '--color-text-tertiary': 'var(--gray-400)',  // #9CA3AF
    '--color-text-inverse': 'var(--white)',       // #FFFFFF

    // Brand
    '--color-brand-primary': 'var(--blue-600)',  // #2563EB
    '--color-brand-hover': 'var(--blue-700)',    // #1D4ED8
    '--color-brand-subtle': 'var(--blue-50)',    // #EFF6FF

    // Feedback
    '--color-success': 'var(--green-600)',
    '--color-warning': 'var(--yellow-500)',
    '--color-error': 'var(--red-600)',
    '--color-info': 'var(--blue-500)',

    // Border
    '--color-border-default': 'var(--gray-200)', // #E5E7EB
    '--color-border-strong': 'var(--gray-300)',   // #D1D5DB
    '--color-border-focus': 'var(--blue-500)',    // #3B82F6

    // Spacing（セマンティック）
    '--spacing-section': 'var(--spacing-16)',     // 64px
    '--spacing-card': 'var(--spacing-6)',         // 24px
    '--spacing-inline': 'var(--spacing-2)',       // 8px
  },
  dark: {
    // ダークモードのオーバーライド
    '--color-bg-primary': 'var(--gray-900)',
    '--color-bg-secondary': 'var(--gray-800)',
    '--color-text-primary': 'var(--gray-50)',
    // ... 他のダークモード値
  },
}
```

## Layer 3: Component Tokens

```typescript
const componentTokens = {
  button: {
    primary: {
      bg: 'var(--color-brand-primary)',
      bgHover: 'var(--color-brand-hover)',
      text: 'var(--color-text-inverse)',
      border: 'transparent',
      padding: 'var(--spacing-2) var(--spacing-4)',
      borderRadius: 'var(--radius-md)',
    },
    secondary: {
      bg: 'transparent',
      bgHover: 'var(--color-bg-tertiary)',
      text: 'var(--color-text-primary)',
      border: 'var(--color-border-default)',
    },
    ghost: {
      bg: 'transparent',
      bgHover: 'var(--color-bg-tertiary)',
      text: 'var(--color-text-secondary)',
      border: 'transparent',
    },
  },
  card: {
    bg: 'var(--color-bg-secondary)',
    border: 'var(--color-border-default)',
    padding: 'var(--spacing-card)',
    borderRadius: 'var(--radius-lg)',
    shadow: '0 1px 3px rgba(0,0,0,0.1)',
  },
  input: {
    bg: 'var(--color-bg-secondary)',
    border: 'var(--color-border-default)',
    borderFocus: 'var(--color-border-focus)',
    text: 'var(--color-text-primary)',
    placeholder: 'var(--color-text-tertiary)',
    padding: 'var(--spacing-2) var(--spacing-3)',
    borderRadius: 'var(--radius-md)',
  },
}
```

## Tailwind CSS での実装

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // Alias tokens を Tailwind クラスとして使用
        bg: {
          primary: 'var(--color-bg-primary)',
          secondary: 'var(--color-bg-secondary)',
          tertiary: 'var(--color-bg-tertiary)',
        },
        text: {
          primary: 'var(--color-text-primary)',
          secondary: 'var(--color-text-secondary)',
        },
        brand: {
          DEFAULT: 'var(--color-brand-primary)',
          hover: 'var(--color-brand-hover)',
          subtle: 'var(--color-brand-subtle)',
        },
      },
    },
  },
}
```

## 変更時の影響範囲

| 変更内容 | 影響レイヤー | 影響範囲 |
|----------|------------|---------|
| ブランドカラー変更 | Global | 全体に自動波及 |
| ダークモード調整 | Alias | テーマ全体 |
| ボタンデザイン変更 | Component | ボタンのみ |
| 新テーマ追加 | Alias | 新規 Alias セット追加 |
