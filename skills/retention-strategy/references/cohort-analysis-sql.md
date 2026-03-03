# コホート分析 SQL クエリ集（Supabase）

## 週次リテンションカーブ

```sql
WITH cohorts AS (
  SELECT
    id AS user_id,
    date_trunc('week', created_at) AS cohort_week
  FROM auth.users
),
activity AS (
  SELECT
    user_id,
    date_trunc('week', created_at) AS activity_week
  FROM activity_logs
)
SELECT
  c.cohort_week,
  COUNT(DISTINCT c.user_id) AS cohort_size,
  COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '1 week' THEN c.user_id END) AS week_1,
  COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '2 weeks' THEN c.user_id END) AS week_2,
  COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '3 weeks' THEN c.user_id END) AS week_3,
  COUNT(DISTINCT CASE WHEN a.activity_week = c.cohort_week + INTERVAL '4 weeks' THEN c.user_id END) AS week_4
FROM cohorts c
LEFT JOIN activity a ON c.user_id = a.user_id
GROUP BY c.cohort_week
ORDER BY c.cohort_week;
```

## チャーンリスクスコアリング

```sql
SELECT
  u.id,
  u.email,
  CASE
    WHEN last_active < now() - INTERVAL '30 days' THEN 'high'
    WHEN last_active < now() - INTERVAL '14 days' THEN 'medium'
    WHEN last_active < now() - INTERVAL '7 days' THEN 'low'
    ELSE 'active'
  END AS churn_risk,
  last_active,
  now() - last_active AS days_inactive
FROM auth.users u
LEFT JOIN (
  SELECT user_id, MAX(created_at) AS last_active
  FROM activity_logs
  GROUP BY user_id
) a ON u.id = a.user_id
WHERE last_active < now() - INTERVAL '7 days'
ORDER BY last_active ASC;
```

## Re-engagement トリガー

| 非活動期間 | リスク | アクション |
|-----------|--------|-----------|
| 7日 | Low | プッシュ通知 or メール（新機能紹介） |
| 14日 | Medium | パーソナライズメール（未使用機能ハイライト） |
| 30日 | High | Winbackメール（特典付き復帰促進） |
| 60日+ | Very High | 最終メール + アカウント非アクティブ通知 |

## 業界ベンチマーク

| 指標 | 良好 | 平均 | 要改善 |
|------|------|------|--------|
| Day 1 リテンション | > 40% | 25-40% | < 25% |
| Day 7 リテンション | > 20% | 10-20% | < 10% |
| Day 30 リテンション | > 10% | 5-10% | < 5% |
| 月次チャーン（B2C SaaS） | < 5% | 5-8% | > 8% |
