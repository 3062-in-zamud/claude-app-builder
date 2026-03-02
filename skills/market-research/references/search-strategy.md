# 市場トレンドスキャン - 検索戦略テンプレート

## 概要

WebSearch を使って4カテゴリの市場トレンドを調査する。
各カテゴリにつき英語・日本語の両方で検索し、多角的な情報を収集する。

**重要**: `{current_year}` は実行時の西暦に置換すること。

## カテゴリ別クエリテンプレート

### 1. 新API・プラットフォーム変更

最新の技術変化により生まれる新しい市場機会を探る。

**英語クエリ**:
- `new API launch {current_year} developer tools`
- `platform policy change {current_year} [対象プラットフォーム]`
- `[対象領域] API deprecation {current_year}`

**日本語クエリ**:
- `{current_year} 新API リリース [対象領域]`
- `{current_year} プラットフォーム 仕様変更 [対象サービス]`

**推奨 allowed_domains**: `techcrunch.com`, `theverge.com`, `dev.to`, `zenn.dev`

### 2. 消費者の不満・ペインポイント

既存サービスへの不満から生まれるビジネスチャンスを発見する。

**英語クエリ**:
- `[競合サービス名] frustration OR complaint OR "switched to" {current_year}`
- `[対象領域] pain points Reddit {current_year}`
- `"I wish [対象領域]" alternative {current_year}`

**日本語クエリ**:
- `[競合サービス名] 不満 OR 乗り換え {current_year}`
- `[対象領域] 使いにくい OR 課題 {current_year}`

**推奨 allowed_domains**: `reddit.com`, `news.ycombinator.com`, `qiita.com`, `zenn.dev`

### 3. 成長中のニッチ市場

急成長している小規模市場を特定する。

**英語クエリ**:
- `[対象領域] fastest growing niche {current_year}`
- `[対象領域] emerging market trend {current_year}`
- `micro SaaS [対象領域] {current_year}`

**日本語クエリ**:
- `[対象領域] 急成長 ニッチ {current_year}`
- `個人開発 SaaS [対象領域] トレンド {current_year}`

**推奨 allowed_domains**: `statista.com`, `similarweb.com`, `note.com`, `zenn.dev`

### 4. 規制・社会変化

法規制や社会の変化が生み出す新しいニーズを探る。

**英語クエリ**:
- `[対象領域] regulation change {current_year}`
- `[対象領域] compliance new requirement {current_year}`
- `remote work [対象領域] trend {current_year}`

**日本語クエリ**:
- `[対象領域] 法改正 OR 規制 {current_year}`
- `[対象領域] 働き方改革 OR DX {current_year}`

**推奨 allowed_domains**: `nikkei.com`, `itmedia.co.jp`, `reuters.com`

## 使用上の注意

- WebSearch の `allowed_domains` パラメータを活用し、信頼性の高いソースを優先する（`site:` 構文ではなくツールのパラメータを使う）
- 検索結果が少ない場合は `allowed_domains` を外して再検索する
- 各カテゴリで最低1件以上の有用な情報を収集することを目標とする
- 収集した情報は Step 3（差別化分析）の根拠として活用する
