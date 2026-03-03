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

**ファーストビュー5秒テスト基準**:
- [ ] 5秒で「何のサービスか」が伝わるか
- [ ] 5秒で「自分に関係あるか」が判断できるか
- [ ] 5秒で「次に何をすればいいか」が分かるか
- [ ] ヒーロー画像/イラストがサービス内容を補強しているか
- [ ] CTAボタンがスクロールなしで視認できるか

### Step 2.5: CRO（LIFT Model）適用

各セクションに対して LIFT Model の6要素で最適化する（詳細は `references/cro-lift-model.md`）:

| LIFT要素 | チェック内容 | 適用箇所 |
|---------|------------|---------|
| **Value Proposition** | 提供価値が一目で伝わるか | Hero見出し |
| **Relevance** | ターゲットの課題と一致しているか | Hero + Features |
| **Clarity** | メッセージが明確で曖昧さがないか | 全コピー |
| **Urgency** | 今行動する理由があるか | CTA周辺 |
| **Anxiety** | 不安要素を解消しているか | Social Proof + FAQ |
| **Distraction** | 余計な要素で注意が散らないか | ページ全体 |

### Step 2.6: コピーライティングフレーム適用

セクションごとに最適なフレームワークを選択（詳細は `references/copywriting-frameworks.md`）:

- **Hero**: PAS（Problem → Agitation → Solution）で課題を顕在化し解決策を提示
- **Features**: FAB（Feature → Advantage → Benefit）で機能を価値に変換
- **CTA**: AIDA（Attention → Interest → Desire → Action）で行動を促す

```
// PAS 適用例（Hero）
Problem:  「毎日2時間を○○に費やしていませんか？」
Agitation: 「その時間、年間730時間。もっと価値あることに使えるはずです」
Solution:  「[プロダクト名]なら、ワンクリックで完了」
```

### Step 2.7: Cialdini 心理学6原則の実装

各セクションで以下の原則を意識的に適用（詳細は `references/psychology-design-principles.md`）:

| 原則 | 実装パターン | 適用セクション |
|------|------------|--------------|
| **Reciprocity** | 無料トライアル・無料ガイド提供 | CTA |
| **Commitment** | 段階的なマイクロコンバージョン | CTA |
| **Social Proof** | ユーザー数・レビュー・ロゴ | Social Proof |
| **Authority** | メディア掲載・専門家推薦 | Social Proof |
| **Liking** | 親しみやすいトーン・共感コピー | Hero + Features |
| **Scarcity** | 期間限定・残り枠数 | CTA |

### Step 2.8: A/Bテスト設計

LP公開後のA/Bテスト計画を `docs/ab-test-plan.md` に記載:

**テスト優先順位（インパクト順）**:
1. **Hero見出し**: PAS vs AIDA のコピーバリエーション
2. **CTAボタン**: テキスト・色・配置の変更
3. **Social Proof**: 数字 vs テキスト vs 動画
4. **ページ長さ**: ロングフォーム vs ショートフォーム

**テスト設計テンプレート**:
```markdown
## A/Bテスト: [テスト名]
- 仮説: [Xを変更すると、Yが改善する。なぜなら...]
- 変更箇所: [具体的な変更内容]
- 計測指標: [主指標: CTR / 副指標: 離脱率]
- 必要サンプル数: [最低1000 PV/バリアント]
- 期間: [最低2週間]
- 判定基準: [統計的有意差 p < 0.05]
```

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
- [ ] ファーストビュー5秒テスト基準をクリアしているか
- [ ] LIFT Model 6要素が考慮されているか
- [ ] コピーが PAS/AIDA/FAB いずれかのフレームに沿っているか
- [ ] Cialdini 原則が少なくとも3つ以上適用されているか
- [ ] A/Bテスト計画が `docs/ab-test-plan.md` に記載されているか
