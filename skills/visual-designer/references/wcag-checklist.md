# WCAG 2.2 AA アクセシビリティチェックリスト

## カラーコントラスト

| 要素 | 最低コントラスト比 | 確認ツール |
|------|----------------|-----------|
| 通常テキスト (< 18pt) | **4.5:1** | [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) |
| 大きなテキスト (≥ 18pt / bold 14pt) | **3:1** | 同上 |
| UI コンポーネント・グラフィック | **3:1** | 同上 |

## フォーカス管理

- [ ] すべてのインタラクティブ要素がキーボードフォーカスを受け取れる
- [ ] フォーカスインジケーターが視認できる（`:focus-visible` スタイル）
- [ ] フォーカス順序が論理的（DOM 順）

## セマンティックHTML

- [ ] 見出しが階層的に使用されている（h1 > h2 > h3）
- [ ] `<button>` vs `<a>` が適切に使い分けられている
- [ ] 画像に `alt` 属性がある（装飾画像は `alt=""`）
- [ ] フォームに `<label>` が関連付けられている

## ARIA

- [ ] 必要な場所のみに `aria-*` を使用（過剰な使用を避ける）
- [ ] `aria-label` または `aria-labelledby` で名前が付いている
- [ ] `role` が適切に設定されている

## OGP / メタタグチェックリスト

- [ ] `<title>` タグ（60文字以内）
- [ ] `<meta name="description">` （160文字以内）
- [ ] `og:title`（60文字以内）
- [ ] `og:description`（160文字以内）
- [ ] `og:image`（1200x630px, < 8MB）
- [ ] `og:url`
- [ ] `og:type`
- [ ] `twitter:card` = "summary_large_image"
- [ ] `twitter:image`
- [ ] `link rel="icon"` (favicon)
- [ ] `link rel="apple-touch-icon"` (180x180px)

## Tailwind CSS アクセシビリティユーティリティ

```css
/* フォーカスリング */
.focus-visible:focus-visible {
  @apply outline-2 outline-offset-2 outline-blue-500;
}

/* スクリーンリーダーのみ */
.sr-only {
  @apply absolute w-px h-px p-0 -m-px overflow-hidden clip-rect-0 whitespace-nowrap border-0;
}
```
