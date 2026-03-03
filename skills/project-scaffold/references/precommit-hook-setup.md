# Pre-commit フック設定（Husky + lint-staged）

## 概要

コミット前に自動で lint/format を実行し、品質の低いコードがリポジトリに入るのを防ぐ。

## セットアップ手順

### 1. パッケージインストール

```bash
npm install -D husky lint-staged
```

### 2. Husky 初期化

```bash
npx husky init
```

これにより以下が行われる:
- `.husky/` ディレクトリが作成される
- `package.json` に `prepare` スクリプトが追加される
- `.husky/pre-commit` ファイルが作成される

### 3. pre-commit フック設定

```bash
echo "npx lint-staged" > .husky/pre-commit
```

### 4. lint-staged 設定

`package.json` に追加:

```json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,yml,yaml}": [
      "prettier --write"
    ],
    "*.css": [
      "prettier --write"
    ]
  }
}
```

## 動作フロー

```
git commit
  → Husky が .husky/pre-commit を実行
    → lint-staged が「ステージされたファイルのみ」を処理
      → .ts/.tsx: ESLint fix → Prettier format
      → .json/.md/.yml: Prettier format
    → 全ファイル成功 → コミット実行
    → エラーあり → コミット中断 + エラー表示
```

## トラブルシューティング

### フックが動作しない

```bash
# Husky のパーミッション確認
chmod +x .husky/pre-commit

# Git hooks パスの確認
git config core.hooksPath
# → .husky であることを確認
```

### CI でフックをスキップしたい

CI 環境では `prepare` スクリプトを無効化:

```json
{
  "scripts": {
    "prepare": "husky || true"
  }
}
```

### 特定のコミットでスキップしたい場合

```bash
# 非推奨だが緊急時のみ
git commit --no-verify -m "hotfix: critical bug"
```

## 追加のフック（オプション）

### commit-msg（コミットメッセージ検証）

```bash
# Conventional Commits の検証
npm install -D @commitlint/cli @commitlint/config-conventional
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
```

`commitlint.config.js`:
```javascript
module.exports = { extends: ['@commitlint/config-conventional'] }
```

### pre-push（プッシュ前テスト）

```bash
echo "npm test" > .husky/pre-push
```
