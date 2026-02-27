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
```

### Step 2: デザインシステム策定（Opus で戦略・Sonnet で実装詳細）

**カラーシステム**:
- Tailwind カスタムカラー設定（tailwind.config.ts）
- WCAG AA 準拠確認（コントラスト比 4.5:1 以上）
- ダークモード対応

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

### 品質チェック（wcag-checklist.md 参照）

- [ ] カラーコントラスト比が WCAG AA 基準を満たすか
- [ ] フォーカスインジケーターが視認できるか
- [ ] OGP 画像が 1200x630px 仕様か
- [ ] Favicon が設定されているか
