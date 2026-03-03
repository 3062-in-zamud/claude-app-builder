---
name: feedback-loop
description: |
  What: デプロイ後のユーザーフィードバック収集設計と次イテレーション計画
  When: Phase 8（リリース報告後）
  How: NSM定義 → RICE優先順位付け → コホート/ファネル分析設計 → NPS計測 → スプリント計画
model: claude-sonnet-4-6
allowed-tools:
  - Read
  - Write
---

# feedback-loop: フィードバック設計

## 概要

リリース後のユーザーフィードバック収集の設計と、次のイテレーション計画を策定します。

## ワークフロー

### Step 1: フィードバック収集チャネルの設計

`docs/requirements.md` と `docs/brand-brief.md` を読み込んでターゲットユーザーを確認する。

### Step 2: フィードバックツール選定

| ツール | 用途 | 無料枠 | 推奨度 |
|--------|------|--------|--------|
| Google Forms | ユーザーアンケート | 無制限回答 | ✅ 最初の選択肢 |
| Tally | 高機能アンケート | 無制限回答 | ✅ おすすめ |
| Canny | 機能リクエスト収集 | Free プラン有り | ✅ |
| Crisp | カスタマーサポートチャット | Free プラン有り | ✅ |
| Typeform | 高機能アンケート | **10回/月（少ない）** | ⚠️ 有料なら検討 |

### Step 3: 2週間フィードバック計画

```
Week 1: 初期ユーザー獲得
  - Product Hunt でローンチ
  - 初期ユーザー5名にインタビュー依頼

Week 2: データ分析
  - Vercel Analytics でユーザー行動を確認
  - Sentry でエラーを監視
  - Typeform アンケート結果を分析
```

### Step 4: 次イテレーション計画書の作成

`docs/feedback-strategy.md` を生成:

```markdown
# フィードバック戦略

## 収集チャネル
- [選定ツール] → [設定手順]

## KPI（2週間後に確認）
- **DAU**: [目標数] ← 最低でも 10 DAU を 2週間維持できれば継続の価値あり
- **リテンション率（7日）**: [目標%] ← 業界平均 20〜30% を参考に
- **NPS スコア**: [目標値] ← 0以上でニュートラル、30以上で優良
- **Sentry エラー率**: 全セッションの 1% 未満

## アラート基準
- DAU が目標の 50% 未満が3日続いた場合 → 仮説を見直す
- Sentry エラー率が 5% 超 → 即座に修正対応

## 次のP1機能（フィードバック次第）
- [機能候補1]
- [機能候補2]
```

### Step 5: North Star Metric（NSM）定義

詳細は `references/north-star-metric-guide.md` 参照。

プロダクトの成功を測る唯一の指標を定義する。`docs/requirements.md` のプロダクトタイプに応じて選定:

| プロダクトタイプ | NSM 候補 |
|----------------|---------|
| SaaS / ツール | Weekly Active Users（WAU） |
| マーケットプレイス | 週間取引数 |
| コンテンツ | 週間エンゲージメント時間 |
| コミュニティ | 週間投稿数 |

```markdown
## North Star Metric
- **NSM**: [指標名]
- **定義**: [具体的な計測方法]
- **現在値**: 0（ローンチ直後）
- **2週間目標**: [数値]
- **計測方法**: [Vercel Analytics / カスタムイベント]
```

### Step 6: RICE/ICE スコアリングによる優先順位付け

詳細は `references/rice-scoring-template.md` 参照。

フィードバックから得られた機能要望を以下のフレームワークで優先順位付け:

```markdown
## 機能要望の優先順位（RICE スコアリング）

| 機能 | Reach | Impact | Confidence | Effort | RICE Score |
|------|-------|--------|------------|--------|-----------|
| [機能A] | /10 | /3 | /100% | 人週 | 自動計算 |
| [機能B] | /10 | /3 | /100% | 人週 | 自動計算 |

RICE = (Reach × Impact × Confidence) / Effort
```

### Step 7: コホート分析テンプレート

詳細は `references/cohort-analysis-guide.md` 参照。

ユーザーの定着率を登録週別に追跡する SQL テンプレートを生成:

```sql
-- コホート分析: 週別リテンション率
WITH cohorts AS (
  SELECT
    id AS user_id,
    DATE_TRUNC('week', created_at) AS cohort_week
  FROM auth.users
),
activity AS (
  SELECT DISTINCT
    user_id,
    DATE_TRUNC('week', created_at) AS activity_week
  FROM public.events  -- analytics-events で設定したテーブル
)
SELECT
  c.cohort_week,
  COUNT(DISTINCT c.user_id) AS cohort_size,
  COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '1 week' THEN a.user_id END) AS week_1,
  COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '2 weeks' THEN a.user_id END) AS week_2
FROM cohorts c
LEFT JOIN activity a ON c.user_id = a.user_id
GROUP BY c.cohort_week
ORDER BY c.cohort_week;
```

### Step 8: ファネル分析設計（analytics-events 連携）

`analytics-events` スキルで設定したカスタムイベントを使ったファネル分析:

```markdown
## ファネル定義

1. **Awareness**: ランディングページ訪問（pageview）
2. **Interest**: CTA クリック / サインアップページ遷移
3. **Activation**: アカウント作成完了
4. **Engagement**: コア機能を初回利用
5. **Retention**: 7日後に再訪問

## 各ステップの計測イベント

| ステップ | イベント名 | 計測方法 |
|---------|-----------|---------|
| Awareness | page_view | Vercel Analytics |
| Interest | cta_click | カスタムイベント |
| Activation | sign_up_complete | Supabase Auth |
| Engagement | core_action | カスタムイベント |
| Retention | return_visit | カスタムイベント |
```

### Step 9: NPS 計測フロー

詳細は `references/nps-implementation-guide.md` 参照。

```markdown
## NPS 計測設計

### タイミング
- 初回: アカウント作成から7日後
- 定期: 月1回（月初の火曜日）
- トリガー: コア機能を5回以上使用した時点

### 質問
「このサービスを友人や同僚に薦める可能性はどのくらいですか？（0-10）」

### 分類
- Promoter（9-10）: ロイヤルユーザー
- Passive（7-8）: 満足だが推奨しない
- Detractor（0-6）: 不満あり

### NPS = %Promoter - %Detractor
- 目標: 0以上（ニュートラル）→ 30以上（優良）
```

### Step 10: Churned User インタビュー計画

```markdown
## 離脱ユーザーインタビュー計画

### 対象者の定義
- 登録後7日間アクティビティなし
- または最後のログインから14日以上経過

### 抽出クエリ
SELECT id, email, created_at, last_sign_in_at
FROM auth.users
WHERE last_sign_in_at < NOW() - INTERVAL '14 days'
  AND created_at > NOW() - INTERVAL '60 days'
ORDER BY created_at DESC
LIMIT 20;

### インタビュー質問（5分以内）
1. なぜ登録しましたか？（期待）
2. 実際に使ってみてどうでしたか？（現実）
3. 使わなくなった理由は？（離脱要因）
4. どうなっていれば使い続けましたか？（改善ヒント）
5. 今は代わりに何を使っていますか？（競合）
```

### Step 11: スプリントプランニングテンプレート

```markdown
## Sprint [番号] 計画（[開始日] - [終了日]）

### スプリントゴール
[1文で表現]

### NSM 目標
- 現在値: [数値]
- 目標値: [数値]

### タスク（RICE スコア順）

| # | タスク | RICE | 担当 | 見積もり | ステータス |
|---|--------|------|------|---------|-----------|
| 1 | [最優先タスク] | [スコア] | - | [h/d] | TODO |
| 2 | [次優先タスク] | [スコア] | - | [h/d] | TODO |

### 振り返り（スプリント終了時に記入）
- **Keep**: うまくいったこと
- **Problem**: 問題だったこと
- **Try**: 次に試すこと
```

## 出力ファイル

`docs/feedback-strategy.md` に以下を含む:
- North Star Metric 定義
- フィードバック収集チャネル設計
- RICE スコアリングテンプレート
- コホート分析 SQL
- ファネル定義
- NPS 計測設計
- Churned User インタビュー計画
- スプリントプランニングテンプレート

## 完了条件

- [ ] `docs/feedback-strategy.md` が生成されている
- [ ] North Star Metric が定義されている
- [ ] RICE/ICE スコアリングテンプレートが含まれている
- [ ] コホート分析 SQL が含まれている
- [ ] ファネル分析設計が含まれている
- [ ] NPS 計測フローが含まれている
- [ ] フィードバック収集ツールの設定手順が記載されている
- [ ] 次イテレーションのP1機能候補が記載されている
- [ ] スプリントプランニングテンプレートが含まれている
