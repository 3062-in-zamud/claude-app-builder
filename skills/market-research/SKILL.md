---
name: market-research
description: |
  What: 競合調査と市場規模の概算を行う（Phase 0.5）
  When: idea-to-spec の前に実行
  How: ユーザーにヒアリング → 公開サイトをWebFetch → docs/market-research.md 生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - WebFetch
  - AskUserQuestion
---

# market-research: 市場調査

## 概要

アイデアの競合分析と市場規模の概算を行い、`docs/market-research.md` を生成します。

## ワークフロー

### Step 1: 競合サービスのヒアリング

```
以下を教えてください：
1. 競合または参考にしているサービスを3つ挙げてください
   （例: Notion, Airtable, Coda）
2. それらのどの点が不満ですか？
3. あなたのサービスとの差別化ポイントは何ですか？
```

注意: Product Hunt・App Store は SPA のため WebFetch では取得困難。
ユーザーのヒアリング回答に基づいて分析を進める。

### Step 2: 競合サービス分析

ユーザーから収集した競合サービスの**公式サイト**を WebFetch で取得・分析:

```
各競合サービスについて:
- 主要機能
- 料金プラン
- ターゲットユーザー
- 強み・弱み
```

### Step 3: 差別化分析

競合との比較表を作成:

| 機能 | 競合A | 競合B | 競合C | 自社 |
|------|-------|-------|-------|------|
| [機能1] | ✅/❌ | ✅/❌ | ✅/❌ | ✅ |

### Step 4: 市場規模の概算

- 対象ユーザー規模の推定
- 想定 TAM / SAM / SOM
- 収益化タイムラインの概算

### 出力

`docs/market-research.md`（競合分析レポート）

## 品質チェック

- [ ] 競合サービスが3社以上分析されているか
- [ ] 差別化ポイントが明確に記載されているか
- [ ] 市場規模の概算が記載されているか
