---
name: idea-to-spec
description: |
  What: アイデアをヒアリングして要件定義書（requirements.md）を生成する
  When: 新規アプリ開発の最初のステップ。/idea-to-spec "アイデア" で起動
  How: 5つの質問でヒアリング → requirements.md を生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

# idea-to-spec: アイデア → 要件定義

## ワークフロー

### Step 1: ヒアリング

以下の項目をユーザーに確認します（不明な場合のみ質問）:

1. **解決する課題**: 誰のどんな問題を解決するか（1文で）
2. **ターゲットユーザー**: 主要ユーザー像（具体的に）
3. **MVP機能**: 最初のバージョンで必須な機能（最大5個）
4. **マネタイズ方針**: 無料/フリーミアム/有料/広告など
5. **成功指標**: 3ヶ月後にどうなっていれば成功か

既にアイデアに情報が含まれている場合は、確認のみ行います。

### Step 2: 要件定義書の生成

`docs/requirements.md` を `references/requirements-template.md` を元に生成します。

### Step 3: ドメイン候補確認

プロダクト名から候補ドメインを3〜5個提示し、確認コマンドを案内:
```bash
# ドメイン空き確認
whois [domain].com
```

### 出力ファイル

- `docs/requirements.md` - 要件定義書

### 品質チェック

- [ ] 解決する課題が1文で言えるか
- [ ] ターゲットユーザーが具体的か
- [ ] MVP機能が5個以内に絞れているか
- [ ] マネタイズ方針が決まっているか
- [ ] プロダクト名候補が3案以上あるか
