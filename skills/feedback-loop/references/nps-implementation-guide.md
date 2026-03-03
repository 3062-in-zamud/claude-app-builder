# NPS（Net Promoter Score）実装ガイド

## NPS とは

「このサービスを友人や同僚に薦める可能性はどのくらいですか？（0-10）」
という単一の質問で顧客ロイヤルティを測定する指標。

## 分類

| スコア | 分類 | 意味 |
|--------|------|------|
| 9-10 | Promoter（推奨者） | 積極的に推奨する |
| 7-8 | Passive（中立者） | 満足だが積極的ではない |
| 0-6 | Detractor（批判者） | 不満を持っている |

**NPS = %Promoter - %Detractor**（-100 〜 +100）

## 目標値

| NPS | 評価 |
|-----|------|
| 70+ | 世界クラス |
| 50-69 | 優秀 |
| 30-49 | 良好 |
| 0-29 | 改善の余地あり |
| < 0 | 要緊急対応 |

## 計測タイミング

### 推奨トリガー

| タイミング | 条件 | 理由 |
|-----------|------|------|
| オンボーディング完了後 | アカウント作成から7日経過 | 初期体験の評価 |
| コア機能利用後 | 主要機能を5回以上使用 | 価値を実感したタイミング |
| 定期計測 | 月1回（月初の火曜日） | トレンド把握 |
| 重要イベント後 | 有料プラン開始後14日 | 課金ユーザーの満足度 |

### 避けるべきタイミング

- 登録直後（まだ使っていない）
- エラー発生直後（一時的な不満が反映される）
- 1日に複数回（ユーザー疲れ）

## UI 実装例

### モーダル型（推奨）

```tsx
// components/nps-survey.tsx
'use client';

import { useState } from 'react';

interface NPSSurveyProps {
  onSubmit: (score: number, feedback: string) => void;
  onDismiss: () => void;
}

export function NPSSurvey({ onSubmit, onDismiss }: NPSSurveyProps) {
  const [score, setScore] = useState<number | null>(null);
  const [feedback, setFeedback] = useState('');
  const [step, setStep] = useState<'score' | 'feedback' | 'thanks'>('score');

  const handleScoreSelect = (s: number) => {
    setScore(s);
    setStep('feedback');
  };

  const handleSubmit = () => {
    if (score !== null) {
      onSubmit(score, feedback);
      setStep('thanks');
      setTimeout(onDismiss, 2000);
    }
  };

  if (step === 'thanks') {
    return (
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6 max-w-md">
          <p className="text-center text-lg">ご回答ありがとうございます</p>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <button onClick={onDismiss} className="float-right text-gray-400">
          ×
        </button>

        {step === 'score' && (
          <>
            <p className="text-lg font-medium mb-4">
              このサービスを友人や同僚に薦める可能性はどのくらいですか？
            </p>
            <div className="flex gap-1 justify-between mb-2">
              {[0,1,2,3,4,5,6,7,8,9,10].map(n => (
                <button
                  key={n}
                  onClick={() => handleScoreSelect(n)}
                  className="w-8 h-8 rounded text-sm border hover:bg-blue-100"
                >
                  {n}
                </button>
              ))}
            </div>
            <div className="flex justify-between text-xs text-gray-500">
              <span>全く薦めない</span>
              <span>強く薦める</span>
            </div>
          </>
        )}

        {step === 'feedback' && (
          <>
            <p className="text-lg font-medium mb-2">
              スコア: {score}/10
            </p>
            <p className="text-sm text-gray-600 mb-3">
              {score !== null && score <= 6
                ? 'どうすれば改善できますか？'
                : score !== null && score <= 8
                ? '何が足りないですか？'
                : '特に気に入っている点は？'}
            </p>
            <textarea
              value={feedback}
              onChange={e => setFeedback(e.target.value)}
              className="w-full border rounded p-2 text-sm"
              rows={3}
              placeholder="任意: フィードバックをお聞かせください"
            />
            <button
              onClick={handleSubmit}
              className="mt-3 w-full bg-blue-600 text-white rounded py-2"
            >
              送信
            </button>
          </>
        )}
      </div>
    </div>
  );
}
```

## データ保存（Supabase）

```sql
-- NPS 回答テーブル
CREATE TABLE public.nps_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 10),
  feedback TEXT,
  trigger_type TEXT NOT NULL, -- 'onboarding', 'periodic', 'event'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.nps_responses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert own responses"
  ON public.nps_responses FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## 集計クエリ

```sql
-- NPS 計算（直近30日）
WITH scores AS (
  SELECT
    CASE
      WHEN score >= 9 THEN 'promoter'
      WHEN score >= 7 THEN 'passive'
      ELSE 'detractor'
    END AS category
  FROM public.nps_responses
  WHERE created_at >= NOW() - INTERVAL '30 days'
)
SELECT
  COUNT(*) AS total_responses,
  ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'promoter') / COUNT(*), 1) AS promoter_pct,
  ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'passive') / COUNT(*), 1) AS passive_pct,
  ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'detractor') / COUNT(*), 1) AS detractor_pct,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE category = 'promoter') / COUNT(*) -
    100.0 * COUNT(*) FILTER (WHERE category = 'detractor') / COUNT(*),
    1
  ) AS nps
FROM scores;
```

## 改善アクション

| NPS 区間 | アクション |
|---------|-----------|
| < 0 | Detractor に個別連絡。主要な不満を特定して緊急修正 |
| 0-29 | フィードバック内容をRICEスコアリングで優先順位付け |
| 30-49 | Passive → Promoter 転換施策。差別化機能を強化 |
| 50+ | Promoter にリファラルプログラムを案内。口コミ促進 |
