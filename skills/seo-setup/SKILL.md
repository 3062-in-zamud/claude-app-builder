---
name: seo-setup
description: |
  What: サイトマップ・robots.txt・JSON-LD構造化データを設定
  When: Phase 3（landing-page-builder 完了後）
  How: App Router ネイティブの sitemap.ts + robots.ts + JSON-LD
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
---

# seo-setup: SEO設定

## 概要

Next.js App Router ネイティブの方法で SEO 設定を行います（外部パッケージ不要）。

## ワークフロー

### Step 1: docs/brand-brief.md と docs/requirements.md を読み込む

プロダクト名・説明・URL を取得する。

### Step 2: サイトマップ生成

`src/app/sitemap.ts` を生成:

```typescript
import { MetadataRoute } from 'next'

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://example.com'

  return [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 1,
    },
    {
      url: `${baseUrl}/privacy`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.3,
    },
    {
      url: `${baseUrl}/terms`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.3,
    },
  ]
}
```

### Step 3: robots.txt 生成

`src/app/robots.ts` を生成:

```typescript
import { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://example.com'

  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/api/', '/dashboard/'],
    },
    sitemap: `${baseUrl}/sitemap.xml`,
  }
}
```

### Step 4: JSON-LD 構造化データ

`src/app/layout.tsx` に JSON-LD `<script>` を追加:

```typescript
// layout.tsx の <body> 内に追加
<script
  type="application/ld+json"
  dangerouslySetInnerHTML={{
    __html: JSON.stringify({
      '@context': 'https://schema.org',
      '@type': 'WebApplication',
      name: '[プロダクト名]',
      description: '[プロダクト説明]',
      url: process.env.NEXT_PUBLIC_APP_URL,
    }),
  }}
/>
```

### Step 5: コンテンツ SEO 戦略

`references/content-seo-strategy.md` に従い、SEO コンテンツ戦略を策定する:

- キーワードリサーチ: プロダクトに関連する検索キーワード候補を整理
- コンテンツカレンダー: ブログ/ガイド記事の公開計画
- 内部リンク構造: ページ間のリンク設計

出力: `docs/seo-strategy.md`（コンテンツSEO戦略ドキュメント）

### Step 6: Core Web Vitals 最適化

`references/core-web-vitals-optimization.md` に従い、パフォーマンス最適化を実施する:

| 指標 | 基準 | 最適化手法 |
|------|------|-----------|
| LCP（Largest Contentful Paint） | < 2.5秒 | 画像最適化, フォントプリロード |
| FID（First Input Delay） | < 100ms | JS分割, 遅延読み込み |
| CLS（Cumulative Layout Shift） | < 0.1 | 画像サイズ指定, フォントフラッシュ防止 |
| INP（Interaction to Next Paint） | < 200ms | イベントハンドラ最適化 |

### Step 7: 構造化データ拡充

Step 4 の JSON-LD に加え、プロダクト種類に応じて追加の構造化データを設定:

```typescript
// FAQ 構造化データ
const faqSchema = {
  '@context': 'https://schema.org',
  '@type': 'FAQPage',
  mainEntity: [
    {
      '@type': 'Question',
      name: '[質問1]',
      acceptedAnswer: {
        '@type': 'Answer',
        text: '[回答1]',
      },
    },
  ],
}

// BreadcrumbList 構造化データ
const breadcrumbSchema = {
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: [
    { '@type': 'ListItem', position: 1, name: 'ホーム', item: baseUrl },
    { '@type': 'ListItem', position: 2, name: '[ページ名]', item: `${baseUrl}/[path]` },
  ],
}
```

対応する構造化データタイプ:
- `WebApplication`（デフォルト）
- `FAQPage`（FAQ ページがある場合）
- `HowTo`（チュートリアルがある場合）
- `Product`（SaaS の場合）
- `BreadcrumbList`（ナビゲーション）

### Step 8: Search Console 統合ガイド

ユーザーに以下の手順を案内する:

```
📋 Google Search Console 設定手順

1. https://search.google.com/search-console にアクセス
2. 「プロパティを追加」→ URL プレフィックス → [本番URL] を入力
3. 所有権の確認:
   - 推奨: HTML タグ（<meta name="google-site-verification" content="..." />）
   - layout.tsx の <head> に追加

4. サイトマップの送信:
   - サイトマップ → 新しいサイトマップ → sitemap.xml を送信

5. インデックス登録のリクエスト:
   - URL 検査 → 本番 URL を入力 → インデックス登録をリクエスト
```

## 完了条件

- [ ] `src/app/sitemap.ts` が生成されている
- [ ] `src/app/robots.ts` が生成されている
- [ ] `src/app/layout.tsx` に JSON-LD が追加されている
- [ ] コンテンツ SEO 戦略が `docs/seo-strategy.md` に記載されているか
- [ ] Core Web Vitals の最適化施策が実施されているか
- [ ] 追加の構造化データ（FAQ, BreadcrumbList 等）が必要に応じて設定されているか
- [ ] Search Console の設定手順が案内されているか

## 出力

- `src/app/sitemap.ts`
- `src/app/robots.ts`
- `src/app/layout.tsx`（JSON-LD追加）
- `docs/seo-strategy.md`（コンテンツSEO戦略）
