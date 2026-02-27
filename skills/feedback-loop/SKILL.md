---
name: feedback-loop
description: |
  What: デプロイ後のユーザーフィードバック収集設計と次イテレーション計画
  When: Phase 8（リリース報告後）
  How: Typeform/Canny設定案内 → docs/feedback-strategy.md 生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
---

# feedback-loop: フィードバック設計

## 概要

リリース後のユーザーフィードバック収集の設計と、次のイテレーション計画を策定します。

## ワークフロー

### Step 1: フィードバック収集チャネルの設計

`docs/requirements.md` と `docs/brand-brief.md` を読み込んでターゲットユーザーを確認する。

### Step 2: フィードバックツール選定

| ツール | 用途 | 無料枠 |
|--------|------|--------|
| Typeform | ユーザーアンケート | 10回/月 |
| Canny | 機能リクエスト収集 | Free プラン有り |
| Crisp | カスタマーサポートチャット | Free プラン有り |

### Step 3: 2週間フィードバック計画

```
Week 1: 初期ユーザー獲得
  - Product Hunt でローンチ
  - 初期ユーザー5名にインタビュー依頼

Week 2: データ分析
  - Vercel Analytics でユーザー行動を確認
  - Sentry でエラーを監視
  - Typeform アンケート結果を分析
```

### Step 4: 次イテレーション計画書の作成

`docs/feedback-strategy.md` を生成:

```markdown
# フィードバック戦略

## 収集チャネル
- [選定ツール] → [設定手順]

## KPI（2週間後に確認）
- DAU: [目標数]
- リテンション率: [目標%]
- NPS スコア: [目標値]

## 次のP1機能（フィードバック次第）
- [機能候補1]
- [機能候補2]
```

## 完了条件

- [ ] `docs/feedback-strategy.md` が生成されている
- [ ] フィードバック収集ツールの設定手順が記載されている
- [ ] 次イテレーションのP1機能候補が記載されている
