# LP コンポーネントガイド

## Hero コンポーネント（必須要素）

```tsx
// components/landing/Hero.tsx
export function Hero() {
  return (
    <section className="min-h-screen flex items-center justify-center bg-gradient-to-b from-primary-50 to-white">
      <div className="max-w-4xl mx-auto px-4 text-center">
        <h1 className="text-5xl font-bold text-gray-900 mb-6">
          [メインキャッチコピー]
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          [サブコピー：誰のどんな問題を解決するか]
        </p>
        <a
          href="/signup"
          className="inline-block bg-primary-600 text-white px-8 py-4 rounded-lg text-lg font-semibold hover:bg-primary-700 transition"
        >
          無料で始める →
        </a>
        <p className="mt-4 text-sm text-gray-500">クレジットカード不要</p>
      </div>
    </section>
  )
}
```

## Features コンポーネント

```tsx
const features = [
  {
    icon: '📚',
    title: '[機能名]',
    description: '[機能の説明・ユーザーへの価値]',
  },
  // ...
]

export function Features() {
  return (
    <section className="py-20 bg-white">
      <div className="max-w-6xl mx-auto px-4">
        <h2 className="text-3xl font-bold text-center mb-12">主な機能</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {features.map((f) => (
            <div key={f.title} className="p-6 rounded-xl border border-gray-100 hover:shadow-md transition">
              <div className="text-4xl mb-4">{f.icon}</div>
              <h3 className="text-xl font-semibold mb-2">{f.title}</h3>
              <p className="text-gray-600">{f.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
```

## FAQ コンポーネント

```tsx
const faqs = [
  { q: '無料で使えますか？', a: '[回答]' },
  { q: 'データは安全ですか？', a: 'はい。すべてのデータは暗号化して保存されます。' },
  // ...
]
```

## CTA の文言パターン

| シーン | 文言例 |
|--------|--------|
| メール登録 | "無料で始める" / "早期アクセスに参加" |
| アプリ開始 | "今すぐ試す" / "デモを見る" |
| ダウンロード | "App Storeでダウンロード" |
| 有料転換 | "プランを見る" / "14日間無料トライアル" |
