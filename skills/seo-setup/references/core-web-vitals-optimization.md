# Core Web Vitals 最適化チェックリスト

## 概要

Google のランキング要因である Core Web Vitals を最適化し、
ユーザー体験と検索順位の両方を向上させる。

## Core Web Vitals 基準値

| 指標 | 良好 | 改善が必要 | 不良 |
|------|------|-----------|------|
| LCP（Largest Contentful Paint） | < 2.5秒 | 2.5-4.0秒 | > 4.0秒 |
| FID（First Input Delay） | < 100ms | 100-300ms | > 300ms |
| CLS（Cumulative Layout Shift） | < 0.1 | 0.1-0.25 | > 0.25 |
| INP（Interaction to Next Paint） | < 200ms | 200-500ms | > 500ms |

## LCP 最適化

### 画像最適化

```typescript
// next/image を使用（自動最適化）
import Image from 'next/image'

<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={630}
  priority  // LCP 要素にはpriorityを指定
  sizes="(max-width: 768px) 100vw, 1200px"
/>
```

チェックリスト:
- [ ] LCP 要素の画像に `priority` を指定しているか
- [ ] `next/image` を使用しているか（自動 WebP/AVIF 変換）
- [ ] `sizes` 属性で適切なサイズを指定しているか
- [ ] 不要な大きい画像を使用していないか

### フォント最適化

```typescript
// next/font を使用（自動最適化）
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',  // FOIT を防止
  preload: true,
})
```

チェックリスト:
- [ ] `next/font` を使用しているか
- [ ] `display: 'swap'` を設定しているか
- [ ] 使用するサブセットのみ読み込んでいるか

### サーバーレスポンス最適化

- [ ] ISR（Incremental Static Regeneration）を活用しているか
- [ ] 静的ページは SSG（Static Site Generation）で生成しているか
- [ ] API レスポンスが 200ms 以内か

## FID / INP 最適化

### JavaScript 分割

```typescript
// 動的インポートで遅延読み込み
import dynamic from 'next/dynamic'

const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <Skeleton />,
  ssr: false,
})
```

チェックリスト:
- [ ] 初期表示に不要なコンポーネントを動的インポートしているか
- [ ] Third-party スクリプトに `strategy="lazyOnload"` を設定しているか
- [ ] メインスレッドをブロックする長いタスクがないか（50ms 以上）

### Script 最適化

```typescript
import Script from 'next/script'

// Analytics は遅延読み込み
<Script
  src="https://analytics.example.com/script.js"
  strategy="lazyOnload"
/>

// クリティカルなスクリプトのみ beforeInteractive
<Script
  src="/critical.js"
  strategy="beforeInteractive"
/>
```

## CLS 最適化

### 画像・動画のサイズ指定

```typescript
// 必ず width/height を指定
<Image src="/photo.jpg" width={400} height={300} alt="..." />

// アスペクト比の指定（CSS）
.video-container {
  aspect-ratio: 16 / 9;
}
```

チェックリスト:
- [ ] 全ての画像に width/height が指定されているか
- [ ] 動画/iframe に aspect-ratio が指定されているか
- [ ] 動的コンテンツ（広告、埋め込み）にスペースが確保されているか

### フォントフラッシュ防止

```css
/* font-display: swap で FOIT を防止 */
@font-face {
  font-family: 'CustomFont';
  src: url('/fonts/custom.woff2') format('woff2');
  font-display: swap;
}
```

チェックリスト:
- [ ] Web フォントに `font-display: swap` を設定しているか
- [ ] フォールバックフォントのサイズが Web フォントと近いか
- [ ] フォントのプリロードが設定されているか

### レイアウトシフト防止

- [ ] 動的に挿入される要素（バナー、通知）にスペースが確保されているか
- [ ] スケルトンローディングを使用しているか
- [ ] `min-height` でコンテンツ領域のサイズを確保しているか

## 測定ツール

| ツール | 用途 | URL |
|--------|------|-----|
| Lighthouse | ローカル測定 | Chrome DevTools |
| PageSpeed Insights | 実データ + ラボデータ | pagespeed.web.dev |
| Web Vitals Extension | リアルタイム測定 | Chrome Extension |
| Search Console | 実ユーザーデータ | search.google.com/search-console |

## Next.js 固有の最適化

### next.config.ts

```typescript
const nextConfig = {
  // 画像最適化
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200],
  },
  // バンドル分析（開発時のみ）
  // npm install @next/bundle-analyzer
  experimental: {
    optimizeCss: true,  // CSS 最適化
  },
}
```

### バンドルサイズ分析

```bash
# バンドルサイズの確認
npx @next/bundle-analyzer

# または
ANALYZE=true npm run build
```

## パフォーマンスバジェット

| リソース | バジェット | 測定方法 |
|----------|-----------|---------|
| JavaScript（合計） | < 200KB (gzip) | next build |
| CSS（合計） | < 50KB (gzip) | next build |
| 画像（LCP要素） | < 200KB | DevTools |
| フォント | < 100KB | DevTools |
| First Load JS | < 100KB | next build 出力 |
