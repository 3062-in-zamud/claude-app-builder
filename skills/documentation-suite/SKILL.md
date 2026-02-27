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

### 品質チェック

- [ ] README に「5分でセットアップできる」手順があるか
- [ ] `.env.example` の参照が含まれているか
- [ ] テスト実行コマンドが記載されているか
- [ ] Mermaid 図が正しく記述されているか
