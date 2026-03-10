# Troubleshooting

Claude App Builder のよくある問題と解決方法をまとめています。

---

## 1. install.sh の失敗

### 前提ツールが見つからない

`install.sh` は以下のツールを確認しますが、未インストールでも警告のみでインストール自体は続行します。ただし、スキル実行時にエラーになります。

| ツール | 用途 | インストール方法 |
|--------|------|-----------------|
| `gh` | GitHub リポジトリ作成・設定 | [cli.github.com](https://cli.github.com/) |
| `supabase` | バックエンド構築 | `npm install -g supabase` |
| `vercel` | Vercel デプロイ | `npm install -g vercel` |
| `wrangler` | Cloudflare Pages デプロイ | `npm install -g wrangler` |
| `node` | ビルド・開発サーバー | [nodejs.org](https://nodejs.org/) |
| `git` | バージョン管理 | [git-scm.com](https://git-scm.com/) |

### git clone の失敗

```
fatal: could not read from remote repository
```

**原因**: ネットワーク接続の問題、または GitHub への認証が未設定。

**対処法**:
1. ネットワーク接続を確認
2. `gh auth status` で GitHub CLI の認証状態を確認
3. 必要に応じて `gh auth login` を実行
4. プロキシ環境の場合は `git config --global http.proxy` を設定

### symlink 作成の失敗

```
ln: failed to create symbolic link: Permission denied
```

**原因**: `~/.claude/skills/` ディレクトリへの書き込み権限がない、または同名のファイル（非symlink）が既に存在。

**対処法**:
1. `ls -la ~/.claude/skills/` で既存ファイルを確認
2. 競合するファイルがあれば手動で削除またはリネーム
3. 権限の問題なら `chmod u+w ~/.claude/skills/` を実行

### `~/.claude/` ディレクトリが存在しない

`install.sh` は `mkdir -p` で自動作成しますが、ホームディレクトリの権限が特殊な場合は失敗することがあります。

**対処法**:
```bash
mkdir -p ~/.claude/skills ~/.claude/commands
```

を手動で実行してから再度 `install.sh` を実行してください。

---

## 2. スキル実行エラー

### SKILL.md が読み込めない

```
Error: skill not found: app-builder
```

**原因**: symlink が切れている、またはスキルが正しくインストールされていない。

**対処法**:
1. `ls -la ~/.claude/skills/` で symlink の状態を確認
2. リンク先が存在しない場合は `bash install.sh` を再実行
3. `cat ~/.claude/.claude-app-builder/skills.txt` でインストール済みスキル一覧を確認

### コマンドが認識されない

`/app-builder` 等のスラッシュコマンドが認識されない場合:

**対処法**:
1. `ls ~/.claude/commands/` にコマンドファイルが存在するか確認
2. 存在しない場合は `bash install.sh` を再実行
3. Claude Code のセッションを再起動（コマンド一覧はセッション開始時に読み込まれる）

### 依存スキルの不足

一部のスキルは前段スキルの出力を入力として期待します:

| スキル | 必要な入力ファイル | 生成元スキル |
|--------|-------------------|-------------|
| `brand-foundation` | `requirements.md` | `idea-to-spec` |
| `visual-designer` | `brand-brief.md` | `brand-foundation` |
| `stack-selector` | `requirements.md`, `brand-brief.md` | `idea-to-spec`, `brand-foundation` |
| `landing-page-builder` | `brand-brief.md`, `requirements.md` | `brand-foundation`, `idea-to-spec` |
| `project-scaffold` | `docs/tech-stack.md` | `stack-selector` |
| `implementation` | プロジェクト雛形 | `project-scaffold` |

**対処法**: `app-builder` オーケストレーターを使えば依存関係は自動的に解決されます。個別スキルを使う場合は、上流スキルを先に実行してください。

---

## 3. Claude Code バージョン互換性

### 必要な最低バージョン

Claude App Builder は Claude Code の **カスタムスラッシュコマンド** (`/commands`) と **スキル** (`skills/`) 機能を使用します。これらの機能をサポートする Claude Code バージョンが必要です。

### バージョン確認方法

```bash
claude --version
```

### `/commands` サポートの確認

```bash
ls ~/.claude/commands/
```

ファイルが配置されているのにコマンドが認識されない場合、Claude Code のバージョンが古い可能性があります。

**対処法**:
```bash
npm update -g @anthropic-ai/claude-code
```

---

## 4. FAQ

### アンインストール方法

```bash
bash ~/.claude-app-builder/uninstall.sh
```

以下が削除されます:
- `~/.claude/skills/` 内の Claude App Builder 由来の symlink
- `~/.claude/commands/` 内のコマンドファイル
- `~/.claude/.claude-app-builder/` のマニフェストファイル
- `~/.claude/CLAUDE.md` 内の plugin 注記

ローカルリポジトリ（`~/.claude-app-builder/`）の削除は確認プロンプトが表示されます。

### 更新方法

```bash
bash ~/.claude-app-builder/update.sh
```

リモートリポジトリから `git pull` して、スキルとコマンドを再リンク/再コピーします。

### Cloudflare Pages vs Vercel の選択

`stack-selector` スキルで `deployment_provider` を設定します:

| 項目 | Vercel | Cloudflare Pages |
|------|--------|-----------------|
| Next.js サポート | ネイティブ | `@cloudflare/next-on-pages` が必要 |
| Edge Runtime | 部分的 | フルサポート |
| 無料枠 | 100GB帯域/月 | 無制限帯域 |
| グローバルCDN | あり | あり |

`deployment_provider` を `cloudflare-pages` に設定した場合、追加で `cloudflare_pages_project`、`cloudflare_build_command`、`cloudflare_build_dir` の設定が必要です（0.2.0 の Breaking Change を参照）。

### ローカルインストール vs リモートインストール

- **リモートインストール** (`curl | bash`): `~/.claude-app-builder/` にリポジトリをクローン
- **ローカルインストール** (リポジトリ内で `bash install.sh`): クローン済みディレクトリをそのまま使用

どちらも `~/.claude/skills/` への symlink を作成するため、動作は同じです。
