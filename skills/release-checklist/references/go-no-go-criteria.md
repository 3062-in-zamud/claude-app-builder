# Go/No-Go 判断基準

## 概要

リリース判定を主観で行わないため、必須条件と推奨条件を分離する。

## 必須条件（1つでもNoならNo-Go）

| # | 条件 | 確認方法 |
|---|------|---------|
| 1 | CRITICAL項目が全てPASS | checklist-50items.md |
| 2 | 本番ビルド成功 | `npm run build` |
| 3 | provider環境の環境変数が設定済み | Vercel/Cloudflare Dashboard |
| 4 | Supabaseマイグレーション適用済み | `supabase db status` |
| 5 | セキュリティレビュー完了 | `security-hardening` 結果 |
| 6 | `/api/health` が200 | スモークテスト |

## 推奨条件（Goの品質評価）

| # | 条件 | 目標値 |
|---|------|------|
| 7 | HIGH項目PASS率 | 90%+ |
| 8 | カバレッジ | 80%+ |
| 9 | Lighthouse Performance | 90+ |
| 10 | Lighthouse Accessibility | 95+ |
| 11 | npm audit HIGH | 0件 |

## 判断フロー

1. 必須条件を評価
2. 1つでもNoなら `No-Go`
3. 全てYesなら推奨条件を評価
4. 推奨条件が不足しても、期限付き改善計画があれば `Conditional Go`

## Conditional Go 許容条件

- ユーザー影響が限定的
- 改善期限と担当者が明確
- provider別ロールバック手順が確認済み
- Sentry/Analytics監視体制が有効

## 判定レポートテンプレート

```markdown
# Go/No-Go 判定レポート

- 日時: YYYY-MM-DD HH:MM
- deployment_provider: [vercel | cloudflare-pages]
- 判定: Go / Conditional Go / No-Go

## 必須条件
- [ ] CRITICAL全PASS
- [ ] ビルド成功
- [ ] 環境変数設定済み
- [ ] DB適用済み
- [ ] セキュリティレビュー完了
- [ ] /api/health = 200

## 推奨条件
- [ ] HIGH項目 90%+
- [ ] カバレッジ 80%+
- [ ] Lighthouse P90+/A95+
- [ ] npm audit HIGH 0

## 未達項目と対応
| 項目 | 期限 | 担当 | 対応 |
|------|------|------|------|
| | | | |
```
