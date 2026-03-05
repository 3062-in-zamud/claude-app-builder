---
name: incident-response
description: |
  What: インシデント対応計画・ランブック・ポストモーテムテンプレートを生成する
  When: Phase 13（GA/Scale）でプロダクション運用のインシデント管理体制を整備するとき
  How: 重要度分類・エスカレーションフロー・provider別ロールバック判断・ステータス運用をまとめた対応計画を作成する
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
  - Edit
---

# incident-response: プロダクション・インシデント対応計画

## 概要

プロダクション環境で発生するインシデントに対して、迅速かつ体系的に対応するための計画・テンプレート・ランブックを生成する。
ソロ開発者〜小規模チームを想定し、`deployment_provider`（`vercel` / `cloudflare-pages`）に追従した実践的な対応手順を提供する。

## ワークフロー

### Step 1: プロジェクトコンテキスト読み込み

以下のファイルが存在すれば読み込み、プロジェクトのインフラ構成を把握する:

- `docs/monitoring-setup.md`
- `docs/deploy-setup.md`
- `docs/tech-stack.md`
- `docs/architecture.md`

`docs/tech-stack.md` がある場合は `deployment_provider` を必ず確認する。

```bash
extract_value() {
  local key="$1"
  grep -E "^[[:space:]-]*${key}:" docs/tech-stack.md 2>/dev/null | head -1 | sed -E "s/^[[:space:]-]*${key}:[[:space:]]*//" | tr -d '\r'
}

if [ -f docs/tech-stack.md ]; then
  DEPLOYMENT_PROVIDER="$(extract_value deployment_provider)"
  [ -n "$DEPLOYMENT_PROVIDER" ] || { echo "❌ deployment_provider が未定義です"; exit 1; }
fi
```

### Step 2: 重要度分類（Severity Levels）定義

以下の4段階の重要度を定義し、それぞれの判断基準・対応時間・通知先を明記する:

#### P1 (Critical) - サービス全停止・データ損失
- **判断基準**: 全ユーザーが利用不可、またはデータ損失/破損リスクが高い
- **対応開始**: 即時（検知から15分以内）
- **通知**: 即時通知（Slack/Discord/PagerDuty等）

#### P2 (Major) - 主要機能停止・重大劣化
- **判断基準**: 主要機能停止、または深刻な性能劣化（レスポンス5秒超）
- **対応開始**: 1時間以内
- **通知**: 1時間以内

#### P3 (Minor) - 一部機能の問題・回避策あり
- **判断基準**: 一部機能に問題があるが回避策が存在
- **対応開始**: 営業時間内（24時間以内）
- **通知**: 日次レポート

#### P4 (Low) - 軽微な問題
- **判断基準**: 軽微な不具合、UX改善レベル
- **対応開始**: 次スプリント
- **通知**: バックログ登録

### Step 3: エスカレーションフロー設計

ソロ開発者を前提としたエスカレーションフローを設計する:

```
検知（監視アラート / ユーザー報告）
  ↓
重要度判定（P1-P4）
  ↓
┌─ P1/P2 → 即時対応開始
│   ├─ 自力解決可能 → 対応・復旧・ポストモーテム
│   └─ 自力解決困難
│       ├─ deployment provider 問題 → provider Status / Support
│       ├─ Supabase 問題 → Supabase Status / Support
│       ├─ Stripe 問題 → Stripe Status / Support
│       └─ 不明 → コミュニティ / 外部支援
│
└─ P3/P4 → バックログ登録 → 通常開発フローで対応
```

外部サポート連絡先リストを含める:
- provider（Vercel / Cloudflare）のステータスページURL
- Supabase / Stripe / Sentry のステータスページURL
- サポートチケット作成URL

### Step 4: ロールバック判断フローチャート

デプロイ起因インシデントのロールバック判断フローを作成する:

```
インシデント発生
  ↓
直近のデプロイが原因か？
  ├─ Yes
  │   ├─ deployment provider 起因？
  │   │   ├─ Yes → provider別ロールバック手順を実行
  │   │   └─ No ↓
  │   ├─ Supabase migration 起因？
  │   │   ├─ Yes → forward-only前提で逆マイグレーション
  │   │   └─ No ↓
  │   └─ 環境変数・設定変更起因？ → 前の設定値に復元
  │
  └─ No → 根本原因調査を継続
```

各ロールバック手順の具体コマンドを記載する:
- provider（Vercel / Cloudflare Pages）ロールバック
- Supabase 逆マイグレーション
- 環境変数復元

### Step 5: ポストモーテムテンプレート作成

以下のセクションを含むポストモーテムテンプレートを作成する:

```markdown
# ポストモーテム: [インシデントタイトル]

## 概要
- **日時**: YYYY-MM-DD HH:MM - HH:MM (JST)
- **重要度**: P1/P2/P3/P4
- **影響範囲**: [影響を受けたユーザー数・機能]
- **対応者**: [対応した人]
- **ステータス**: 解決済み / 監視中

## Timeline（時系列）
| 時刻 | イベント |
|------|---------|
| HH:MM | [検知方法と検知内容] |
| HH:MM | [対応開始] |
| HH:MM | [実施したアクション] |
| HH:MM | [復旧確認] |

## Root Cause（根本原因）
[技術的な根本原因の詳細な説明]

## Impact（影響）
- **ユーザー影響**: [何人のユーザーがどの程度影響を受けたか]
- **ビジネス影響**: [売上・信頼への影響]
- **データ影響**: [データ損失の有無]

## Action Items（改善アクション）
| # | アクション | 担当 | 期限 | ステータス |
|---|-----------|------|------|-----------|
| 1 | [再発防止策] | | | |
| 2 | [監視強化] | | | |
| 3 | [プロセス改善] | | | |

## Lessons Learned（学び）
### うまくいったこと
-

### 改善すべきこと
-

### 幸運だったこと
-
```

### Step 6: ステータスページ設定ガイド

無料〜低コストのステータスページツール比較と設定ガイドを作成する:

- **Instatus**（Free tier）
- **Better Stack / Better Uptime**（Free tier）
- **GitHub Status運用**（Issueベース）
- **Cachet**（Self-hosted）

推奨コンポーネント:
- Webアプリ
- API
- データベース
- 認証
- 決済
- メール通知

### Step 7: インシデント対応ランブック（Runbook）テンプレート

よくあるシナリオごとのランブックを作成する:

1. DB接続エラー
2. デプロイ失敗 / ビルドエラー（provider別）
3. 認証エラー多発
4. 決済処理エラー
5. パフォーマンス劣化（provider Analytics + Sentry）
6. セキュリティインシデント

各ランブックには以下を含める:
- 検知方法（どのアラートで気づくか）
- 初動対応（最初の5分）
- 調査手順（ログと確認コマンド）
- 復旧手順（具体ステップ）
- 事後対応（ポストモーテム実施判断）

## 出力ファイル

- `docs/incident-response-plan.md` - インシデント対応計画（全セクション統合）

## 品質チェック

- [ ] 全重要度（P1-P4）の判断基準と対応時間が定義されているか
- [ ] `deployment_provider` に対応したロールバック手順が具体的か
- [ ] Supabase rollback（forward-only前提）が明記されているか
- [ ] ポストモーテムテンプレートが実用的か
- [ ] エスカレーションフローがソロ開発の現実に即しているか
- [ ] ランブックが確認項目と手順を含んでいるか
- [ ] ステータスページ設定手順が記載されているか
- [ ] 外部サポート連絡先が一覧化されているか
