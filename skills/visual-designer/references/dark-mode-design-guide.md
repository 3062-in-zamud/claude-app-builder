# ダークモード設計ガイド

## 概要

ダークモードは単に色を反転するだけではなく、
コントラスト・深度・アクセシビリティを考慮した体系的な設計が必要。

## 設計原則

### 1. 純黒（#000000）を避ける

純黒の背景は目が疲れやすく、OLED ディスプレイでの「スミア効果」も発生する。

| 用途 | NG | OK |
|------|-----|-----|
| 最も暗い背景 | #000000 | #111827 (gray-900) |
| カード背景 | #000000 | #1F2937 (gray-800) |
| 入力フィールド | #000000 | #374151 (gray-700) |

### 2. 深度はエレベーションで表現

ライトモードでは影で深度を表現するが、ダークモードでは **背景色の明るさ** で深度を表現する。

```
深度0（ベース）:     #111827 (gray-900)
深度1（カード）:     #1F2937 (gray-800)
深度2（モーダル）:   #374151 (gray-700)
深度3（ポップオーバー）: #4B5563 (gray-600)
```

### 3. テキストコントラスト

| テキスト種類 | ライト | ダーク | コントラスト比 |
|-------------|--------|--------|-------------|
| プライマリ | #111827 | #F9FAFB | 15.4:1 / 14.1:1 |
| セカンダリ | #6B7280 | #9CA3AF | 5.7:1 / 4.6:1 |
| 無効 | #9CA3AF | #6B7280 | 2.6:1 / 2.6:1 |

WCAG AA 基準: 通常テキスト 4.5:1 以上、大きいテキスト 3:1 以上。

### 4. ブランドカラーの調整

ダークモードではブランドカラーの彩度を下げる。

```
ライト: blue-600 (#2563EB) → ダーク: blue-400 (#60A5FA)
ライト: green-600 (#16A34A) → ダーク: green-400 (#4ADE80)
ライト: red-600 (#DC2626) → ダーク: red-400 (#F87171)
```

高彩度の色はダーク背景上で目に刺さるため、明るく彩度を落とした色を使用する。

## Semantic Color Tokens

```css
/* globals.css */
:root {
  /* Background */
  --color-bg-primary: #FFFFFF;
  --color-bg-secondary: #F9FAFB;
  --color-bg-tertiary: #F3F4F6;
  --color-bg-inverse: #111827;

  /* Surface（カード、モーダル等） */
  --color-surface-default: #FFFFFF;
  --color-surface-raised: #FFFFFF;
  --color-surface-overlay: rgba(0, 0, 0, 0.5);

  /* Text */
  --color-text-primary: #111827;
  --color-text-secondary: #6B7280;
  --color-text-tertiary: #9CA3AF;
  --color-text-disabled: #D1D5DB;
  --color-text-inverse: #FFFFFF;

  /* Border */
  --color-border-default: #E5E7EB;
  --color-border-strong: #D1D5DB;
  --color-border-focus: #3B82F6;

  /* Brand */
  --color-brand-default: #2563EB;
  --color-brand-hover: #1D4ED8;
  --color-brand-active: #1E40AF;
  --color-brand-subtle: #EFF6FF;

  /* Feedback */
  --color-success-default: #16A34A;
  --color-success-subtle: #F0FDF4;
  --color-warning-default: #CA8A04;
  --color-warning-subtle: #FEFCE8;
  --color-error-default: #DC2626;
  --color-error-subtle: #FEF2F2;
  --color-info-default: #2563EB;
  --color-info-subtle: #EFF6FF;
}

.dark {
  /* Background */
  --color-bg-primary: #111827;
  --color-bg-secondary: #1F2937;
  --color-bg-tertiary: #374151;
  --color-bg-inverse: #F9FAFB;

  /* Surface */
  --color-surface-default: #1F2937;
  --color-surface-raised: #374151;
  --color-surface-overlay: rgba(0, 0, 0, 0.7);

  /* Text */
  --color-text-primary: #F9FAFB;
  --color-text-secondary: #9CA3AF;
  --color-text-tertiary: #6B7280;
  --color-text-disabled: #4B5563;
  --color-text-inverse: #111827;

  /* Border */
  --color-border-default: #374151;
  --color-border-strong: #4B5563;
  --color-border-focus: #60A5FA;

  /* Brand（彩度を落とす） */
  --color-brand-default: #60A5FA;
  --color-brand-hover: #93C5FD;
  --color-brand-active: #3B82F6;
  --color-brand-subtle: #1E3A5F;

  /* Feedback（彩度を落とす） */
  --color-success-default: #4ADE80;
  --color-success-subtle: #14532D;
  --color-warning-default: #FACC15;
  --color-warning-subtle: #422006;
  --color-error-default: #F87171;
  --color-error-subtle: #450A0A;
  --color-info-default: #60A5FA;
  --color-info-subtle: #1E3A5F;
}
```

## next-themes 実装

```typescript
// app/providers.tsx
'use client'

import { ThemeProvider } from 'next-themes'

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      {children}
    </ThemeProvider>
  )
}
```

```typescript
// components/theme-toggle.tsx
'use client'

import { useTheme } from 'next-themes'
import { Button } from '@/components/ui/button'
import { Sun, Moon, Monitor } from 'lucide-react'

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={() => {
        if (theme === 'light') setTheme('dark')
        else if (theme === 'dark') setTheme('system')
        else setTheme('light')
      }}
    >
      <Sun className="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
    </Button>
  )
}
```

## 画像・メディアの対応

| 要素 | ライトモード | ダークモード |
|------|------------|------------|
| ロゴ | 通常版 | 明るい色版 or 白版 |
| イラスト | 通常 | 明るさ -10%, 彩度 -20% |
| 写真 | 通常 | brightness(0.9) |
| 影 | box-shadow | なし or 非常に薄い |
| divider | gray-200 | gray-700 |

```css
/* 画像のダークモード自動調整 */
.dark img:not([data-theme-aware]) {
  filter: brightness(0.9);
}
```

## チェックリスト

- [ ] 純黒 (#000000) を背景に使用していないか
- [ ] ダークモードで WCAG AA コントラスト比を満たすか
- [ ] ブランドカラーの彩度をダークモード用に調整したか
- [ ] 深度をエレベーション（背景色の明度差）で表現しているか
- [ ] `prefers-color-scheme` に対応しているか（OS設定連動）
- [ ] テーマ切替の手動トグルが存在するか
- [ ] ロゴがダークモードで視認できるか
- [ ] フォーム要素（入力、セレクト等）がダークモードで使いやすいか
