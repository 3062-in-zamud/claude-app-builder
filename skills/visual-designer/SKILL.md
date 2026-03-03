---
name: visual-designer
description: |
  What: brand-brief.md からデザインシステムを策定する
  When: Phase 2（ブランディング完了後）
  How: ブランドカラーをTailwindで体系化 → デザイントークン → design-system.md 生成
model: claude-opus-4-6
allowed-tools:
  - Read
  - Write
---

# visual-designer: デザインシステム策定

## ワークフロー

### Step 1: ブランド情報読み込み

```
docs/brand-brief.md を読み込む
docs/personas.md を読み込む（存在する場合のみ。存在しない場合は brand-brief.md の情報のみで進行する）
```

### Step 2: デザインシステム策定

**カラーシステム**:
- Tailwind カスタムカラー設定（tailwind.config.ts）
- WCAG AA 準拠確認（コントラスト比 4.5:1 以上）
- ダークモード対応
- personas.md がある場合: ペルソナの色彩の印象・UIの好みからカラートーンを差別化する（例: 効率派→クールなモノトーン、感覚派→温かみのあるアースカラー）

**タイポグラフィ・コンポーネントスタイル**:
- personas.md がある場合: ペルソナのUIの好み・参考サービスからスタイル方向性を決定する（例: ミニマル好み→余白重視・フラットデザイン、データ密度高→コンパクトなカード・テーブルレイアウト）

**スペーシング・レイアウト**:
- グリッドシステム（12カラム）
- ブレークポイント（sm/md/lg/xl）
- コンポーネントスペーシング

**コンポーネント設計（shadcn/ui ベース）**:
- Button バリエーション（primary/secondary/ghost/destructive）
- Form 要素（Input/Textarea/Select/Checkbox）
- Card レイアウト
- Navigation（Header/Sidebar）
- Alert/Toast 通知

**OGP画像仕様**:
```typescript
// @vercel/og による動的生成
// サイズ: 1200x630px
// 内容: プロダクト名 + スローガン + ブランドカラー背景
export async function GET() {
  return new ImageResponse(
    <div style={{ background: '#[color]', width: '100%', height: '100%' }}>
      <h1>[プロダクト名]</h1>
      <p>[スローガン]</p>
    </div>,
    { width: 1200, height: 630 }
  )
}
```

**Favicon**:
- `/public/favicon.ico`（絵文字またはシンプルアイコン）
- `/public/apple-touch-icon.png`（180x180px）

### 出力ファイル

- `docs/design-system.md`（デザインシステムドキュメント）
- `tailwind.config.ts`（カスタムカラー設定）
- `app/og/route.tsx`（OGP画像生成ルート）

## デザイントークン3層構造

`references/design-tokens-hierarchy.md` に従い、デザイントークンを3層で定義する:

```
Global Tokens（基盤）
  → color.blue.500: #3B82F6
  → spacing.4: 16px

Alias Tokens（セマンティック）
  → color.primary: {color.blue.500}
  → color.bg.surface: {color.white}

Component Tokens（コンポーネント固有）
  → button.primary.bg: {color.primary}
  → button.primary.text: {color.white}
```

design-system.md に「デザイントークン」セクションとして記載し、
tailwind.config.ts にもトークン構造を反映する。

## モーション/アニメーション設計

`references/motion-guidelines.md` に従い、UI アニメーションの基準を定義する:

| 用途 | duration | easing | 例 |
|------|----------|--------|-----|
| マイクロインタラクション | 150-200ms | ease-out | ボタンホバー、トグル |
| トランジション | 200-300ms | ease-in-out | モーダル開閉、タブ切替 |
| エントランス | 300-500ms | ease-out | ページ遷移、リスト表示 |
| 強調 | 400-600ms | spring | 通知バッジ、成功表示 |

```typescript
// Framer Motion のデフォルトバリアント
export const fadeIn = {
  initial: { opacity: 0, y: 8 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.3, ease: 'easeOut' },
}

export const staggerContainer = {
  animate: { transition: { staggerChildren: 0.05 } },
}
```

**アクセシビリティ**: `prefers-reduced-motion` メディアクエリで、モーションを無効化できるようにする。

## ダークモード体系

`references/dark-mode-design-guide.md` に従い、ダークモード対応を設計する:

**Semantic Color Tokens**:
```css
:root {
  --color-bg-primary: #FFFFFF;
  --color-bg-secondary: #F9FAFB;
  --color-text-primary: #111827;
  --color-text-secondary: #6B7280;
  --color-border: #E5E7EB;
}

.dark {
  --color-bg-primary: #111827;
  --color-bg-secondary: #1F2937;
  --color-text-primary: #F9FAFB;
  --color-text-secondary: #9CA3AF;
  --color-border: #374151;
}
```

Tailwind の `darkMode: 'class'` を使用し、
`next-themes` で OS 設定連動 + 手動切替を実装する。

### 品質チェック（wcag-checklist.md 参照）

- [ ] カラーコントラスト比が WCAG AA 基準を満たすか
- [ ] フォーカスインジケーターが視認できるか
- [ ] OGP 画像が 1200x630px 仕様か
- [ ] Favicon が設定されているか
- [ ] デザイントークンが3層構造（Global/Alias/Component）で定義されているか
- [ ] モーションガイドラインが定義されているか
- [ ] `prefers-reduced-motion` 対応が含まれているか
- [ ] ダークモードの semantic color tokens が定義されているか
- [ ] ダークモードでも WCAG AA コントラスト比を満たすか
