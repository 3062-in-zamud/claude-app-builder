---
name: legal-docs-generator
description: |
  What: プライバシーポリシーと利用規約のテンプレートを生成する
  When: Phase 3（LP 生成後）
  How: requirements.md の情報を元にカスタマイズされたテンプレートを生成
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
---

# legal-docs-generator: 法務ドキュメント生成

## 免責事項

**このツールが生成する文書はテンプレートです。法的効力については必ず弁護士・法律専門家にレビューを依頼してください。特に個人情報の取り扱いに関しては、お客様の所在国・事業内容に応じた法律が適用されます。**

## ワークフロー

### Step 1: インプット読み込み

```
docs/requirements.md（サービス名・機能・対象ユーザー）
```

### Step 2: プライバシーポリシー生成

`references/privacy-template.md` を元に以下をカスタマイズ:
- サービス名
- 収集データの種類（認証・DB 有無に応じて）
- 外部サービス（Supabase・Vercel・Sentry など）

### Step 3: 利用規約生成

`references/terms-template.md` を元にカスタマイズ

### Step 4: App Store 対応確認

- [ ] プライバシーポリシーが公開 URL にアクセスできる状態か
- [ ] 連絡先メールが記載されているか
- [ ] 最終更新日が記載されているか

### 出力ファイル

- `app/privacy/page.tsx`（プライバシーポリシーページ）
- `app/terms/page.tsx`（利用規約ページ）

### 品質チェック

- [ ] 「専門家レビュー推奨」の注記が含まれているか
- [ ] 連絡先情報が記載されているか
- [ ] 最終更新日が記載されているか
- [ ] App Store 必須要件を満たしているか
