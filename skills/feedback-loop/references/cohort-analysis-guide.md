# コホート分析ガイド

## コホート分析とは

ユーザーを「登録時期」でグループ化し、各グループのリテンション（定着率）を追跡する分析手法。

## 基本SQL: 週別コホートリテンション

```sql
-- Supabase 用: 週別コホートリテンション分析
WITH cohorts AS (
  SELECT
    id AS user_id,
    DATE_TRUNC('week', created_at)::date AS cohort_week
  FROM auth.users
),
activity AS (
  SELECT DISTINCT
    user_id,
    DATE_TRUNC('week', created_at)::date AS activity_week
  FROM public.events
)
SELECT
  c.cohort_week,
  COUNT(DISTINCT c.user_id) AS cohort_size,
  ROUND(100.0 * COUNT(DISTINCT CASE
    WHEN a.activity_week = c.cohort_week THEN a.user_id
  END) / COUNT(DISTINCT c.user_id), 1) AS week_0_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE
    WHEN a.activity_week = c.cohort_week + 7 THEN a.user_id
  END) / COUNT(DISTINCT c.user_id), 1) AS week_1_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE
    WHEN a.activity_week = c.cohort_week + 14 THEN a.user_id
  END) / COUNT(DISTINCT c.user_id), 1) AS week_2_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE
    WHEN a.activity_week = c.cohort_week + 21 THEN a.user_id
  END) / COUNT(DISTINCT c.user_id), 1) AS week_3_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE
    WHEN a.activity_week = c.cohort_week + 28 THEN a.user_id
  END) / COUNT(DISTINCT c.user_id), 1) AS week_4_pct
FROM cohorts c
LEFT JOIN activity a ON c.user_id = a.user_id
GROUP BY c.cohort_week
ORDER BY c.cohort_week DESC;
```

## 日別アクティブユーザー（DAU）トレンド

```sql
SELECT
  DATE_TRUNC('day', created_at)::date AS day,
  COUNT(DISTINCT user_id) AS dau
FROM public.events
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY day
ORDER BY day;
```

## 機能別利用状況

```sql
SELECT
  event_name,
  COUNT(*) AS total_events,
  COUNT(DISTINCT user_id) AS unique_users,
  ROUND(100.0 * COUNT(DISTINCT user_id) / (
    SELECT COUNT(*) FROM auth.users
  ), 1) AS adoption_pct
FROM public.events
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY event_name
ORDER BY unique_users DESC;
```

## 可視化方法

### コホートテーブルの読み方

```
cohort_week | cohort_size | week_0 | week_1 | week_2 | week_3
2025-01-06  |     50      | 100%   |  60%   |  40%   |  35%
2025-01-13  |     80      | 100%   |  55%   |  38%   |   -
2025-01-20  |    120      | 100%   |  50%   |   -    |   -
```

- **week_0**: 登録週のアクティブ率（通常100%近い）
- **week_1 の低下**: オンボーディングの問題を示唆
- **week_2-3 の安定**: プロダクト・マーケット・フィットの兆候

### 可視化ツール

| ツール | 用途 | コスト |
|--------|------|--------|
| Supabase Dashboard | SQL直接実行 | 無料 |
| Metabase（self-hosted） | ダッシュボード | 無料 |
| Google Sheets + IMPORTDATA | 簡易グラフ | 無料 |
| Vercel Analytics | ページビュー分析 | 無料枠あり |

## 業界ベンチマーク

| 指標 | 良好 | 普通 | 要改善 |
|------|------|------|--------|
| Day-1 リテンション | > 40% | 20-40% | < 20% |
| Week-1 リテンション | > 25% | 10-25% | < 10% |
| Month-1 リテンション | > 15% | 5-15% | < 5% |
| DAU/MAU 比率 | > 20% | 10-20% | < 10% |
