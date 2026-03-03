# Cialdini 6原則 - LP実装パターン

Robert Cialdini の「影響力の武器」6原則をランディングページに適用するガイド。

## 1. Reciprocity（返報性）

**原則**: 先に価値を提供すると、相手は「お返し」したくなる

### 実装パターン

```tsx
// パターンA: 無料リソース提供
<section className="py-12 bg-gray-50">
  <h2 className="text-2xl font-bold text-center mb-4">
    無料ガイドをダウンロード
  </h2>
  <p className="text-center text-gray-600 mb-6">
    [ターゲット]のための[テーマ]完全ガイド（PDF 32ページ）
  </p>
  <form className="max-w-sm mx-auto">
    <input type="email" placeholder="メールアドレス" />
    <Button type="submit">無料でダウンロード</Button>
  </form>
</section>

// パターンB: 無料トライアル
<Button size="lg">14日間無料で試す</Button>
<p className="text-sm text-gray-500">クレジットカード不要</p>

// パターンC: 無料ツール提供
// 例: 計算ツール、診断ツール、テンプレート
```

### チェックリスト
- [ ] 登録前に価値を提供しているか（無料ツール・ガイド・テンプレート）
- [ ] 無料トライアルに障壁がないか（クレカ不要）
- [ ] 提供価値が十分に高いか（「お返し」したくなるレベル）

## 2. Commitment & Consistency（コミットメントと一貫性）

**原則**: 小さなコミットメントをすると、一貫した行動を取りたくなる

### 実装パターン

```tsx
// パターンA: マイクロコンバージョン（段階的な関与）
// Step 1: 簡単な質問に答える
<div className="text-center">
  <p className="text-lg mb-4">あなたのチーム規模は？</p>
  <div className="flex gap-4 justify-center">
    <Button variant="outline">1-5人</Button>
    <Button variant="outline">6-20人</Button>
    <Button variant="outline">21人以上</Button>
  </div>
</div>
// Step 2: 結果に基づいたプラン提案
// Step 3: メールアドレス入力
// Step 4: アカウント作成

// パターンB: プログレスバー
<div className="w-full bg-gray-200 rounded-full h-2 mb-4">
  <div className="bg-primary h-2 rounded-full" style={{ width: '33%' }} />
</div>
<p className="text-sm text-gray-500">ステップ 1/3: 基本情報</p>

// パターンC: インタラクティブデモ
// 実際に操作させて「使い始めた感覚」を作る
```

### チェックリスト
- [ ] 最初のステップが非常に簡単か（メアドのみ、クリックのみ）
- [ ] 段階的にコミットメントを深める設計か
- [ ] プログレス表示で「ここまで来た感」を演出しているか

## 3. Social Proof（社会的証明）

**原則**: 他の人がやっていることを正しいと判断する

### 実装パターン

```tsx
// パターンA: 数字で示す
<div className="flex justify-center gap-12 py-8">
  <div className="text-center">
    <p className="text-4xl font-bold">2,500+</p>
    <p className="text-sm text-gray-500">導入企業数</p>
  </div>
  <div className="text-center">
    <p className="text-4xl font-bold">98%</p>
    <p className="text-sm text-gray-500">顧客満足度</p>
  </div>
  <div className="text-center">
    <p className="text-4xl font-bold">4.8</p>
    <p className="text-sm text-gray-500">⭐ 平均評価</p>
  </div>
</div>

// パターンB: 顧客ロゴ
<div className="flex items-center justify-center gap-8 opacity-60">
  <Image src="/logos/company-a.svg" alt="Company A" />
  <Image src="/logos/company-b.svg" alt="Company B" />
  {/* ... */}
</div>

// パターンC: テスティモニアル
<blockquote className="border-l-4 border-primary pl-4">
  <p>"[具体的な成果を含む推薦文]"</p>
  <footer className="mt-2 flex items-center gap-3">
    <Image src="/avatars/user.jpg" className="rounded-full w-10 h-10" />
    <div>
      <p className="font-medium">[名前]</p>
      <p className="text-sm text-gray-500">[肩書き] / [会社名]</p>
    </div>
  </footer>
</blockquote>

// パターンD: リアルタイム表示
<div className="fixed bottom-4 left-4 bg-white shadow-lg rounded-lg p-3">
  <p className="text-sm">
    <span className="font-medium">東京の田中さん</span>が3分前に登録しました
  </p>
</div>
```

### チェックリスト
- [ ] 具体的な数値が含まれているか（「多くの企業」ではなく「2,500社」）
- [ ] ターゲットと同じ属性のユーザーの声があるか
- [ ] 推薦文に具体的な成果が含まれているか

## 4. Authority（権威）

**原則**: 専門家や権威ある存在の意見を信頼する

### 実装パターン

```tsx
// パターンA: メディア掲載
<div className="text-center py-8">
  <p className="text-sm text-gray-500 mb-4">掲載メディア</p>
  <div className="flex items-center justify-center gap-8 opacity-60">
    <Image src="/media/techcrunch.svg" alt="TechCrunch" />
    <Image src="/media/nikkei.svg" alt="日経新聞" />
  </div>
</div>

// パターンB: 認証・受賞
<div className="flex gap-4">
  <Badge>SOC2 Type II 認証</Badge>
  <Badge>AWS パートナー</Badge>
  <Badge>2024 Best SaaS Award</Badge>
</div>

// パターンC: 専門家推薦
<div className="bg-gray-50 p-6 rounded-lg">
  <p className="italic">"[専門的観点からの推薦コメント]"</p>
  <div className="mt-4 flex items-center gap-3">
    <Image src="/experts/expert.jpg" className="rounded-full w-12 h-12" />
    <div>
      <p className="font-medium">[専門家名]</p>
      <p className="text-sm text-gray-500">[大学教授/CTO/業界著名人]</p>
    </div>
  </div>
</div>
```

### チェックリスト
- [ ] 業界での認知度を示す要素があるか
- [ ] セキュリティ・品質の認証を表示しているか
- [ ] 専門家や著名人の推薦があるか

## 5. Liking（好意）

**原則**: 好感を持つ相手からの提案を受け入れやすい

### 実装パターン

```tsx
// パターンA: 親しみやすいトーン
// NG: 「弊社ソリューションをご検討ください」
// OK: 「一緒に、もっと良い方法を見つけましょう」

// パターンB: チームの顔を見せる
<section className="py-12">
  <h2 className="text-2xl font-bold text-center mb-8">
    私たちが作っています
  </h2>
  <div className="grid grid-cols-3 gap-8">
    {team.map(member => (
      <div key={member.name} className="text-center">
        <Image src={member.photo} className="rounded-full w-24 h-24 mx-auto" />
        <p className="font-medium mt-2">{member.name}</p>
        <p className="text-sm text-gray-500">{member.role}</p>
      </div>
    ))}
  </div>
</section>

// パターンC: 共感を示すコピー
<p className="text-lg text-gray-700">
  私たちも同じ課題に苦しんでいました。だから、このツールを作りました。
</p>
```

### チェックリスト
- [ ] ブランドボイスが一貫して親しみやすいか
- [ ] チームの人間味が伝わる要素があるか
- [ ] ユーザーとの共通点・共感ポイントがあるか

## 6. Scarcity（希少性）

**原則**: 手に入りにくいものほど価値があると感じる

### 実装パターン

```tsx
// パターンA: 期間限定
<div className="bg-amber-50 border border-amber-200 rounded-lg p-4 text-center">
  <p className="font-bold text-amber-800">ローンチ記念キャンペーン</p>
  <p className="text-amber-700">
    3月31日まで: 年間プラン <span className="line-through">¥12,000</span>{' '}
    <span className="text-2xl font-bold">¥7,200</span>/年
  </p>
</div>

// パターンB: 数量限定
<div className="text-center">
  <p className="text-sm text-red-600 font-medium">
    ベータ版: 残り{spotsLeft}枠
  </p>
  <div className="w-full bg-gray-200 rounded-full h-2 mt-2">
    <div
      className="bg-red-500 h-2 rounded-full"
      style={{ width: `${(100 - spotsLeft) / 100 * 100}%` }}
    />
  </div>
</div>

// パターンC: 独占アクセス
<Button size="lg">早期アクセスに申し込む</Button>
<p className="text-sm text-gray-500">招待制: 審査後にご案内します</p>
```

### 注意事項
- 虚偽の希少性は信頼を損なう（嘘のカウントダウンなど）
- 正当な理由がある場合のみ使用する（実際にベータ枠が限られている等）

### チェックリスト
- [ ] 希少性の理由が正当か（虚偽ではないか）
- [ ] 期限・数量が具体的に明示されているか
- [ ] 希少性がCTAの近くに配置されているか

## 原則の組み合わせ例

効果的なLPは複数の原則を組み合わせる:

```
Hero:       Liking（共感コピー）+ Social Proof（数字）
Features:   Authority（認証バッジ）
Social Proof: Social Proof（テスティモニアル）+ Authority（専門家推薦）
CTA:        Reciprocity（無料トライアル）+ Scarcity（期間限定）+ Commitment（簡単な第一歩）
FAQ:        不安解消（Anxiety除去）
```
