---
name: documentation-suite
description: |
  What: tech-stack.md と requirements.md からプロジェクトドキュメントを生成する
  When: Phase 3（設計完了後）
  How: README.md・CONTRIBUTING.md・ARCHITECTURE.md を生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
---

# documentation-suite: ドキュメント生成

## ワークフロー

### Step 1: インプット読み込み

```
docs/requirements.md
docs/tech-stack.md
docs/brand-brief.md
```

### Step 2: README.md 生成

**必須セクション**:
1. プロダクト名 + キャッチコピー
2. スクリーンショット/デモ URL（プレースホルダー）
3. 機能一覧（MVP 機能を箇条書き）
4. **5分セットアップ手順**（必須）:
   - Prerequisites
   - Clone & Install
   - 環境変数設定（`.env.example` 参照）
   - DB セットアップ
   - 開発サーバー起動
5. テスト実行方法
6. デプロイ方法
7. コントリビューション
8. ライセンス

### Step 3: CONTRIBUTING.md 生成

- 開発環境セットアップ
- コーディングスタイル（ESLint + Prettier）
- PR の作成方法
- テストの書き方

### Step 4: ARCHITECTURE.md 生成

- ディレクトリ構成
- データフロー図（Mermaid）
- 主要コンポーネント説明
- 外部サービス依存関係

### 出力ファイル

- `README.md`（プロジェクトルート）
- `docs/CONTRIBUTING.md`
- `docs/ARCHITECTURE.md`

### Step 5: ADR 連携

`docs/adr/` ディレクトリが存在する場合（stack-selector で生成）、
ARCHITECTURE.md に ADR へのリンクを追加する:

```markdown
## アーキテクチャ決定記録（ADR）

技術的な意思決定の記録は以下を参照:

| # | タイトル | ステータス |
|---|---------|-----------|
| [ADR-0001](./adr/0001-xxx.md) | [タイトル] | Accepted |
| [ADR-0002](./adr/0002-xxx.md) | [タイトル] | Accepted |
```

### Step 6: Changelog 標準化

`references/changelog-format.md` に従い、`CHANGELOG.md` を Keep a Changelog 形式で生成する:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial MVP release

## [0.1.0] - YYYY-MM-DD

### Added
- [機能1]
- [機能2]
```

### Step 7: Runbook 生成

`references/runbook-template.md` に従い、`docs/runbook.md`（オペレーション手順書）を生成する:

- デプロイ手順
- ロールバック手順
- 障害対応手順（よくある障害パターンと対処法）
- 環境変数の変更手順

### 出力ファイル

- `README.md`（プロジェクトルート）
- `docs/CONTRIBUTING.md`
- `docs/ARCHITECTURE.md`
- `CHANGELOG.md`
- `docs/runbook.md`

### 品質チェック

- [ ] README に「5分でセットアップできる」手順があるか
- [ ] `.env.example` の参照が含まれているか
- [ ] テスト実行コマンドが記載されているか
- [ ] Mermaid 図が正しく記述されているか
- [ ] ADR へのリンクが ARCHITECTURE.md に含まれているか（ADR 存在時）
- [ ] CHANGELOG.md が Keep a Changelog 形式で作成されているか
- [ ] Runbook（docs/runbook.md）が作成されているか
