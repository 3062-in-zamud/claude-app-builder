# コピーライティングフレームワーク

## 1. PAS（Problem → Agitation → Solution）

最も汎用的なフレームワーク。課題を顕在化してから解決策を提示する。

### 構造

| ステップ | 目的 | 手法 |
|---------|------|------|
| **Problem** | 課題を特定 | ターゲットが「そうそう」と頷く課題を提示 |
| **Agitation** | 痛みを増幅 | 課題を放置した場合のコスト・機会損失を具体化 |
| **Solution** | 解決策を提示 | プロダクトがどう課題を解決するかを説明 |

### 適用箇所: Hero セクション

### テンプレート

```tsx
// Hero コンポーネント - PAS パターン
<section className="py-20 text-center">
  {/* Problem */}
  <p className="text-lg text-gray-600 mb-2">
    [ターゲット]の[X%]が[課題]に悩んでいます
  </p>

  {/* Agitation */}
  <h1 className="text-4xl font-bold mb-4">
    [課題]を放置すると、[具体的な損失]に
  </h1>

  {/* Solution */}
  <p className="text-xl text-gray-700 mb-8">
    [プロダクト名]なら、[ベネフィット]を[期間]で実現
  </p>

  <Button size="lg">[CTA テキスト]</Button>
</section>
```

### 記入例

```
Problem:  「毎週5時間を手動レポート作成に費やしていませんか？」
Agitation: 「年間260時間。それはフルタイム社員1.5ヶ月分の人件費です」
Solution:  「ReportAIなら、ワンクリックで完璧なレポートを自動生成」
```

## 2. AIDA（Attention → Interest → Desire → Action）

段階的に関心を高めてから行動を促す。CTAセクション向き。

### 構造

| ステップ | 目的 | 手法 |
|---------|------|------|
| **Attention** | 注意を引く | 衝撃的な数値・質問・逆説 |
| **Interest** | 興味を持たせる | 独自性・差別化ポイント |
| **Desire** | 欲求を喚起 | ベネフィット・成功イメージ |
| **Action** | 行動を促す | 明確なCTA + 不安解消 |

### 適用箇所: CTA セクション、メール件名

### テンプレート

```tsx
<section className="py-16 bg-primary-50">
  {/* Attention */}
  <h2 className="text-3xl font-bold text-center mb-4">
    [衝撃的な事実/質問]
  </h2>

  {/* Interest */}
  <p className="text-center text-lg text-gray-700 mb-6">
    [プロダクト名]は[独自のアプローチ]で[課題]を解決します
  </p>

  {/* Desire */}
  <div className="flex justify-center gap-8 mb-8">
    <div className="text-center">
      <p className="text-3xl font-bold text-primary">[数値]%</p>
      <p className="text-sm text-gray-600">[指標]改善</p>
    </div>
    {/* ... */}
  </div>

  {/* Action */}
  <div className="text-center">
    <Button size="lg">[具体的なCTA]</Button>
    <p className="text-sm text-gray-500 mt-2">[不安解消テキスト]</p>
  </div>
</section>
```

## 3. FAB（Feature → Advantage → Benefit）

機能を価値に変換する。Features セクション向き。

### 構造

| ステップ | 説明 | 例 |
|---------|------|-----|
| **Feature** | 機能・仕様 | 「AI自動分類エンジン」 |
| **Advantage** | 他と比べた優位性 | 「手動分類より10倍速い」 |
| **Benefit** | ユーザーが得る価値 | 「毎日30分の作業時間を節約」 |

### 適用箇所: Features セクション

### テンプレート

```tsx
<div className="grid grid-cols-1 md:grid-cols-3 gap-8">
  {features.map(({ icon, feature, advantage, benefit }) => (
    <div key={feature} className="p-6 rounded-lg border">
      <div className="mb-4">{icon}</div>
      {/* Feature */}
      <h3 className="font-semibold text-lg mb-2">{feature}</h3>
      {/* Advantage */}
      <p className="text-gray-600 mb-2">{advantage}</p>
      {/* Benefit */}
      <p className="text-primary font-medium">{benefit}</p>
    </div>
  ))}
</div>
```

### 記入例

```typescript
const features = [
  {
    icon: <ZapIcon />,
    feature: 'ワンクリック自動生成',         // Feature
    advantage: '従来ツールの10倍の速度',     // Advantage
    benefit: '毎週5時間を節約できます',       // Benefit
  },
  {
    icon: <ShieldIcon />,
    feature: 'エンタープライズグレードの暗号化', // Feature
    advantage: 'SOC2 Type II 認証取得済み',     // Advantage
    benefit: '安心してデータを預けられます',     // Benefit
  },
]
```

## 4. BAB（Before → After → Bridge）

変化のストーリーを描く。Social Proof・事例紹介向き。

### 構造

```
Before:  [現状の課題・痛み]
After:   [理想の状態・解決後のイメージ]
Bridge:  [プロダクトがその橋渡しをする]
```

### テンプレート

```tsx
<section className="py-16">
  <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
    {/* Before */}
    <div className="p-6 bg-red-50 rounded-lg">
      <h3 className="font-bold text-red-700 mb-2">Before</h3>
      <p>[導入前の課題・痛みの描写]</p>
    </div>

    {/* Bridge */}
    <div className="p-6 bg-primary-50 rounded-lg flex items-center justify-center">
      <div>
        <ArrowRightIcon className="mx-auto mb-2" />
        <p className="font-bold">[プロダクト名]で解決</p>
      </div>
    </div>

    {/* After */}
    <div className="p-6 bg-green-50 rounded-lg">
      <h3 className="font-bold text-green-700 mb-2">After</h3>
      <p>[導入後の理想状態]</p>
    </div>
  </div>
</section>
```

## フレームワーク選択ガイド

| セクション | 推奨フレームワーク | 理由 |
|-----------|-----------------|------|
| Hero | PAS | 課題認識→解決策の流れが自然 |
| Features | FAB | 機能を価値に変換 |
| Social Proof | BAB | Before/After で変化を実感 |
| CTA | AIDA | 段階的に行動を促す |
| FAQ | - | 不安解消に特化（フレーム不要） |

## コピーの品質チェック

- [ ] 主語が「私たち」ではなく「あなた」になっているか
- [ ] 具体的な数値が含まれているか（「多くの」→「2,500社以上の」）
- [ ] 専門用語を使っていないか（使う場合は即座に説明）
- [ ] 1文が40文字以内に収まっているか
- [ ] 能動態で書かれているか（「〜される」→「〜する」）
