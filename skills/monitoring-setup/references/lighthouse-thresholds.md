# Lighthouse CI 閾値ガイド

## App Builder 標準閾値

| カテゴリ | 最低スコア | 理由 |
|---------|-----------|------|
| Performance | 90+ | ユーザー体験・SEO |
| Accessibility | 95+ | WCAG AA 準拠 |
| Best Practices | 90+ | セキュリティ・品質 |
| SEO | 90+ | 検索流入 |

## Core Web Vitals 閾値

| メトリクス | 良好 | 要改善 | 悪い |
|-----------|------|--------|------|
| LCP（最大コンテンツ描画） | < 2.5s | 2.5〜4s | > 4s |
| FID/INP（インタラクション） | < 200ms | 200〜500ms | > 500ms |
| CLS（累積レイアウトシフト） | < 0.1 | 0.1〜0.25 | > 0.25 |
| FCP（最初のコンテンツ描画） | < 1.8s | 1.8〜3s | > 3s |
| TBT（合計ブロッキング時間） | < 200ms | 200〜600ms | > 600ms |

## Performance 向上のヒント

- `next/image` で画像最適化
- `next/font` でフォント最適化
- 不要な JS を遅延ロード（`dynamic()` import）
- `React.memo` / `useMemo` で不要な再レンダリングを防ぐ
- API レスポンスをキャッシュ

## Accessibility 向上のヒント

- 画像に `alt` 属性を必ず設定
- カラーコントラスト比 4.5:1 以上を確認
- フォームに `<label>` を関連付け
- キーボードナビゲーションのテスト
