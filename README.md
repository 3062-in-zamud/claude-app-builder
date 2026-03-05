# Claude App Builder

> アイデアを入力するだけで **0 → MVP → MRR $50K まで全自動化**する Claude Code プラグイン

> **注意**: プログラミングの基礎知識（コードレビュー・デバッグ）を前提とします

## インストール

### 方法1: スクリプトインストール（推奨）

```bash
curl -fsSL https://raw.githubusercontent.com/3062-in-zamud/claude-app-builder/main/install.sh | bash
```

または直接クローン:

```bash
git clone https://github.com/3062-in-zamud/claude-app-builder ~/.claude-app-builder
bash ~/.claude-app-builder/install.sh
```

次回 Claude Code 起動時から `/app-builder` が使えます。

## 初回セットアップ（プラグイン使用前）

1. [Supabase アカウント作成](https://supabase.com) → `supabase login`
2. [GitHub CLI セットアップ](https://cli.github.com/) → `gh auth login`
3. デプロイ先を選択してログイン
   - Vercel を使う場合: [Vercel アカウント作成](https://vercel.com/signup) → `vercel login`
   - Cloudflare Pages を使う場合: [Cloudflare アカウント作成](https://dash.cloudflare.com/) → `wrangler login`

### 無料プランの制限事項

| サービス | 制限 | 商用利用推奨プラン |
|---------|------|-----------------|
| Vercel Hobby | **commercial use 禁止** | Pro ($20/月) |
| Cloudflare Pages Free | 無料枠は大きいが機能上限・サポート制限あり | Pro/Business を検討 |
| Supabase Free | 500MB DB・2PJ・7日非アクティブで一時停止 | Pro ($25/月) |

### 方法2: Claude Code プラグインシステム（推奨）

```bash
# マーケットプレイスを追加（初回のみ）
claude plugin marketplace add 3062-in-zamud/claude-app-builder

# プラグインをインストール
claude plugin install claude-app-builder@claude-app-builder
```

> **注記**: 公式マーケットプレイスへの申請は審査中です（2025/2/27〜）。
> 上記コマンドは GitHub リポジトリを自前マーケットプレイスとして利用します。

### 前提ツール

| ツール | 用途 | インストール |
|--------|------|------------|
| [gh](https://cli.github.com/) | GitHub操作 | `brew install gh` |
| [vercel](https://vercel.com/cli) | デプロイ（Vercel選択時） | `npm install -g vercel` |
| [wrangler](https://developers.cloudflare.com/workers/wrangler/install-and-update/) | デプロイ（Cloudflare選択時） | `npm install -g wrangler` |
| [supabase](https://supabase.com/docs/reference/cli) | DB管理 | `npm install -g supabase` |
| Node.js 18+ | 実行環境 | [nodejs.org](https://nodejs.org/) |

## 対応デプロイプロバイダ（web-fullstack）

| provider | 対応状況 | 備考 |
|----------|---------|------|
| `vercel` | ✅ 対応 | 従来どおりの標準フロー |
| `cloudflare-pages` | ✅ 対応（第1弾） | デプロイ層のみ対応（DB/Auth は Supabase 維持） |

## パイプライン概要（6ステージ・5ゲート）

```
=== Stage A: Discovery (Phase 0〜1) ===
  user-research → market-research → idea-to-spec + brand-foundation
  [G1: 要件定義承認]

=== Stage B: Design & Build (Phase 2〜5.5) ===
  stack-selector + visual-designer → project-scaffold + github-repo-setup + ci-setup
  → documentation-suite + landing-page-builder + legal-docs-generator + seo-setup + cookie-consent
  → implementation + analytics-events → security-hardening
  [G2: セキュリティゲート]

=== Stage C: MVP Launch (Phase 6〜8) ===
  monitoring-setup + release-checklist → deploy-setup → feedback-loop
  [G3: MVP品質ゲート]

=== Stage D: Alpha → 有料化 (Phase 9〜10) ===
  pricing-strategy → payment-integration → onboarding-optimizer → email-strategy
  [G4: Alpha→Beta判定]

=== Stage E: Beta → 成長 (Phase 11〜12) ===
  ab-testing + conversion-funnel → gdpr-compliance + data-deletion → retention-strategy
  [G5: Beta→GA判定]

=== Stage F: GA & Scale (Phase 13〜14) ===
  incident-response + scaling-strategy → cost-optimization
```

## ゲート通過条件

| ゲート | 主要条件 |
|--------|---------|
| G1 | ユーザーが requirements.md + brand-brief.md を承認 |
| G2 | CRITICAL脆弱性=0, npm audit HIGH=0 |
| G3 | ヘルスチェックOK, テストカバレッジ80%+, Lighthouse P90+/A95+ |
| G4 | 有料ユーザー10人+, 7日リテンション20%+, Sentryエラー率<1% |
| G5 | MRR $1K+, 30日リテンション15%+, 月次チャーン<10%, GDPR準拠完了 |

## 使い方

### 0 → MVP（Stage A〜C）

```
/app-builder "ユーザーが自分の読んだ本を記録してレビューを書けるSNS"
```

```
/app-builder "フリーランサー向け請求書管理ツール"
```

`/app-builder` は Stage A（Discovery）から Stage C（MVP Launch）までを自動実行します。
Phase 0〜8 の全スキルを順次呼び出し、5つのゲートのうち G1〜G3 を通過してデプロイまで完了します。

### MVP → MRR 成長（Stage D〜F）

```
/growth-engine
```

`/growth-engine` は MVP リリース後の成長フェーズ（Stage D〜F）を自動実行します。
有料化・ユーザー獲得・リテンション・スケーリングまでを G4〜G5 ゲートで品質管理しながら進めます。

### 個別スキルを直接呼び出す

```
/idea-to-spec "月次の家計を可視化するダッシュボード"
/brand-foundation
/landing-page-builder
/security-hardening
/deploy-setup
/pricing-strategy
/payment-integration
/ab-testing
/retention-strategy
/incident-response
/cost-optimization
```

## スキル一覧（33 + オーケストレーター2）

| スキル | Phase | モデル | 役割 |
|--------|-------|--------|------|
| `app-builder` | 全体 (A〜C) | **Opus** | オーケストレーター（0→MVP） |
| `growth-engine` | 全体 (D〜F) | **Opus** | オーケストレーター（MVP→MRR成長） |
| `user-research` | 0 | Sonnet | ペルソナ・インタビューガイド・仮説検証 |
| `market-research` | 0.5 | Sonnet | 競合調査・市場分析 |
| `idea-to-spec` | 1 | Sonnet | アイデア→requirements.md |
| `brand-foundation` | 1 | **Opus** | ブランド戦略 |
| `stack-selector` | 2 | Sonnet | 技術スタック選定 |
| `visual-designer` | 2 | **Opus** | デザインシステム（WCAG AA） |
| `project-scaffold` | 3 | Haiku | Next.js / CLI テンプレート展開 |
| `github-repo-setup` | 3 | Sonnet | Branch Protection + Dependabot |
| `ci-setup` | 3 | Sonnet | GitHub Actions CI設定 |
| `documentation-suite` | 4 | Sonnet | README + ARCHITECTURE |
| `landing-page-builder` | 4 | Sonnet | LP + OGP + メタタグ |
| `legal-docs-generator` | 4 | Sonnet | プライバシー・利用規約 |
| `seo-setup` | 4 | Sonnet | サイトマップ・robots.txt・JSON-LD |
| `cookie-consent` | 4 | Haiku | Cookie同意バナー・GDPR対応 |
| `implementation` | 5 | Sonnet | TDD実装・テスト |
| `analytics-events` | 5 | Sonnet | 計測イベント設計・provider別Analytics実装 |
| `security-hardening` | 5.5 | **Opus** | IDOR / RLS / シークレット自動スキャン |
| `monitoring-setup` | 6 | Sonnet | Sentry + provider別Analytics + Lighthouse CI |
| `release-checklist` | 6 | Sonnet | 全項目チェック（CRITICAL明記） |
| `deploy-setup` | 7 | Sonnet | provider別デプロイ（Vercel/Cloudflare Pages）+ Supabase |
| `feedback-loop` | 8 | Sonnet | フィードバック設計 |
| `pricing-strategy` | 9 | **Opus** | 価格戦略・プラン設計 |
| `payment-integration` | 9 | Sonnet | Stripe統合・サブスクリプション |
| `onboarding-optimizer` | 10 | **Opus** | オンボーディングフロー最適化 |
| `email-strategy` | 10 | Sonnet | メールマーケティング（Resend / SendGrid） |
| `ab-testing` | 11 | Sonnet | A/Bテスト設計・実装 |
| `conversion-funnel` | 11 | **Opus** | コンバージョンファネル分析・最適化 |
| `gdpr-compliance` | 11.5 | **Opus** | GDPR完全準拠・DPA対応 |
| `data-deletion` | 11.5 | Sonnet | データ削除パイプライン・Right to Erasure |
| `retention-strategy` | 12 | **Opus** | リテンション戦略・チャーン分析 |
| `incident-response` | 13 | Sonnet | インシデント対応・ランブック |
| `scaling-strategy` | 13 | Sonnet | スケーリング戦略・パフォーマンス計画 |
| `cost-optimization` | 14 | Sonnet | インフラコスト最適化 |

## MRR 成長ロードマップ

| フェーズ | 目標 MRR | 期間目安 | 主要スキル |
|---------|---------|---------|-----------|
| Alpha（Stage D） | $0 → $1K | 0〜3ヶ月 | pricing-strategy, payment-integration, onboarding-optimizer, email-strategy |
| Beta（Stage E） | $1K → $5K | 3〜6ヶ月 | ab-testing, conversion-funnel, gdpr-compliance, data-deletion, retention-strategy |
| GA / Scale（Stage F） | $5K → $50K | 6〜18ヶ月 | incident-response, scaling-strategy, cost-optimization |

## セキュリティ

`security-hardening` スキルは AI 生成コード特有の脆弱性を検査します（Opus 担当）:

- **IDOR**: 全APIで所有者確認
- **Supabase RLS**: 全テーブル有効化確認
- **Service Role Key**: フロントエンド混入チェック
- **シークレット漏洩**: TruffleHog で全コミットスキャン
- **CSRF / JWT / Rate Limiting**: セキュリティベストプラクティス確認

CRITICAL 問題がある場合はデプロイに進めません。

詳細: [SECURITY.md](SECURITY.md)

## アップデート

```bash
# プラグインシステムでインストールした場合
claude plugin update claude-app-builder

# スクリプトインストールの場合
bash ~/.claude-app-builder/update.sh
```

## アンインストール

```bash
# プラグインシステムでインストールした場合
claude plugin uninstall claude-app-builder

# スクリプトインストールの場合
bash ~/.claude-app-builder/uninstall.sh
```

## ライセンス

MIT
