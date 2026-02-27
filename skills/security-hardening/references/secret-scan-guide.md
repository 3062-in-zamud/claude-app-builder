# シークレットスキャンガイド

## TruffleHog（推奨）

### インストール

```bash
# macOS
brew install trufflehog

# または直接ダウンロード
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
```

### 実行方法

```bash
# 現在のリポジトリの全履歴をスキャン
trufflehog git file://. --only-verified

# JSON 形式で出力（CI/CD 用）
trufflehog git file://. --json --fail

# GitHub リポジトリをスキャン
trufflehog github --repo https://github.com/[user]/[repo]
```

### 出力の解読

```json
{
  "SourceMetadata": { "Data": { "Git": { "commit": "abc123" } } },
  "SourceName": "trufflehog - git",
  "DetectorName": "ANTHROPIC",
  "Raw": "sk-ant-...",  // 漏洩したシークレット（一部マスク）
  "Verified": true      // 実際に有効なシークレット
}
```

## git-secrets（補助）

```bash
# インストール
brew install git-secrets

# リポジトリで有効化
git secrets --install
git secrets --register-aws  # AWS パターン追加

# スキャン実行
git secrets --scan-history
```

## 漏洩が見つかった場合の対処

1. **即座にシークレットをローテーション**（最優先）
   - Anthropic API キー: [console.anthropic.com](https://console.anthropic.com) で無効化
   - Supabase キー: プロジェクト設定 → API → キーを再生成
   - その他: 各サービスの管理画面で無効化

2. **Git 履歴から削除**
   ```bash
   # BFG Repo-Cleaner を使用
   brew install bfg
   bfg --delete-files .env
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   git push --force-with-lease
   ```

3. **全関係者に通知**（共有リポジトリの場合）

## .gitignore の確認

```bash
# .env* が .gitignore に含まれているか確認
cat .gitignore | grep -E "\.env"
# 期待する出力: .env, .env.*, .env.local など
```

## pre-commit フック（推奨）

```bash
# シークレットが含まれるコミットを自動ブロック
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
trufflehog git file://. --since-commit HEAD --only-verified --fail
EOF
chmod +x .git/hooks/pre-commit
```
