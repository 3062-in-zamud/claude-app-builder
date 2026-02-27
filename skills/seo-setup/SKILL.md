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

## 完了条件

- [ ] `src/app/sitemap.ts` が生成されている
- [ ] `src/app/robots.ts` が生成されている
- [ ] `src/app/layout.tsx` に JSON-LD が追加されている

## 出力

- `src/app/sitemap.ts`
- `src/app/robots.ts`
- `src/app/layout.tsx`（JSON-LD追加）
