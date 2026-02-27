---
name: brand-foundation
description: |
  What: requirements.md からブランディング基礎（brand-brief.md）を生成する
  When: 要件定義完了後。brand-foundation で起動
  How: requirements.md を読み込み → ブランド名・カラー・ボイスを策定
model: claude-opus-4-6
allowed-tools:
  - Read
  - Write
---

# brand-foundation: ブランディング基礎の策定

## ワークフロー

### Step 1: インプット読み込み

```
docs/requirements.md を読み込む
```

### Step 2: ブランド戦略策定（Opus で実行）

以下を決定します:

1. **プロダクト名** 3案（ユニーク・発音しやすい・ドメイン取りやすい）
2. **ブランドパーソナリティ** (例: 親しみやすい・プロフェッショナル・革新的)
3. **ブランドボイス** (例: カジュアル/フォーマル、ユーモア有無)
4. **カラーパレット**
   - プライマリカラー（ブランドの主張）
   - セカンダリカラー（補色）
   - ニュートラル（テキスト・背景）
   - アクセント（CTA・警告など）
5. **タイポグラフィ**
   - ヘッディング: [フォント名]
   - ボディ: [フォント名]
6. **ロゴコンセプト**
   - SVGテキストロゴを自動生成
   - 外部ツール案内: Looka.com / Canva

### Step 3: ドメイン候補提示

```bash
# 推奨ドメイン確認コマンド
whois [name1].com
whois [name1].io
whois [name1].app
```

### 出力ファイル

- `docs/brand-brief.md`

### 品質チェック

- [ ] プロダクト名候補が3案以上
- [ ] ドメイン候補の確認コマンドを提示済み
- [ ] カラーパレットが4色以上
- [ ] ブランドボイスが明確に定義済み
