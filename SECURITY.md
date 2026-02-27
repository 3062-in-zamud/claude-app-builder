# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest  | ✅ |

## Reporting a Vulnerability

セキュリティ脆弱性を発見した場合:

1. **公開Issueには報告しないでください**
2. GitHub の [Security Advisories](https://github.com/[username]/claude-app-builder/security/advisories/new) から非公開で報告してください
3. 以下の情報を含めてください:
   - 脆弱性の種類
   - 影響を受けるコンポーネント
   - 再現手順
   - 潜在的な影響

通常72時間以内に初回対応します。

## AI Generated Code Risks

このツールは AI 生成コードを扱います。以下のリスクに注意してください:

- **Prompt Injection**: 悪意のある `.claude/` 設定を持つ外部リポジトリを開かないこと
- **IDOR**: 生成されたAPIは必ず所有者確認を含めること
- **Supabase RLS**: 全テーブルに Row Level Security を設定すること
- **シークレット管理**: API キーは環境変数で管理し、コミットしないこと
