---
name: landing-page-builder
description: |
  What: brand-brief.md と requirements.md からランディングページを生成する
  When: Phase 3（ブランディング・設計完了後）
  How: Next.js App Router で LP コンポーネントを生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
---

# landing-page-builder: ランディングページ生成

## ワークフロー

### Step 1: インプット読み込み

```
docs/requirements.md
docs/brand-brief.md
docs/design-system.md（存在する場合）
docs/personas.md（存在する場合のみ。存在しない場合は上記ファイルの情報のみで進行する）
```

**ペルソナ活用ルール**: コピーライティングのトーンは `brand-brief.md` のブランドボイスが**最優先**。ペルソナは具体的な言葉遣い・価値観のニュアンス（例: 「時短」を強調するか「品質」を強調するか）に活用し、ブランドボイスと矛盾させない。

### Step 2: LP コンポーネント生成

**セクション構成（必須）**:

1. **Hero**: メインキャッチコピー + サブコピー + CTA ボタン + ヒーロー画像
2. **Features**: MVP 機能3〜5点をカード形式で説明
3. **Social Proof**: （プレースホルダー：ユーザーの声・数字）
4. **CTA**: アクション喚起（メール登録 / アプリ開始）
5. **FAQ**: よくある質問 3〜5件
6. **Footer**: プライバシーポリシーリンク・利用規約リンク・サポート連絡先

**LP の重要原則**:
- 最初の5秒で「何をするサービスか」を伝える
- CTA は目立つ色・明確なテキスト（「無料で始める」など）
- モバイルファースト（Tailwind レスポンシブ）
- ページ速度優先（画像は next/image）

### Step 3: メタタグ設定

```typescript
// app/layout.tsx または app/page.tsx
export const metadata = {
  title: '[プロダクト名] - [キャッチコピー]',
  description: '[160文字以内の説明]',
  openGraph: {
    title: '[プロダクト名]',
    description: '[説明]',
    url: 'https://[domain]',
    images: [{ url: '/og', width: 1200, height: 630 }],
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: '[プロダクト名]',
    description: '[説明]',
    images: ['/og'],
  },
}
```

### Step 4: リンク確認

生成後、以下を確認:
- [ ] LP の全リンクが正しいか（/privacy, /terms）
- [ ] CTA の href が正しいか
- [ ] OGP タグが設定されているか
- [ ] favicon が設定されているか

### 出力ファイル

- `app/page.tsx` または `app/landing/page.tsx`（LP メイン）
- `components/landing/Hero.tsx`
- `components/landing/Features.tsx`
- `components/landing/CTA.tsx`
- `components/landing/FAQ.tsx`
- `components/landing/Footer.tsx`
- `app/og/route.tsx`（OGP 画像生成）

### 品質チェック

- [ ] CTA（行動喚起）が明確か
- [ ] OGP タグ（og:title, og:description, og:image）が設定されているか
- [ ] favicon が設定されているか
- [ ] LP の全リンクが動作するか
- [ ] モバイルで正しく表示されるか（Tailwind レスポンシブ）
