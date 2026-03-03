# TTV（Time to Value）最適化ガイド

## 概要

TTV はユーザーがサインアップしてから最初の価値を感じるまでの時間。
TTV が短いほどアクティベーション率・リテンションが向上する。

---

## Aha! Moment の定義

### Aha! Moment とは

ユーザーが「このプロダクトは自分の課題を解決する」と確信する瞬間。
データで定義し、再現可能な状態にすることが目標。

### 有名プロダクトの Aha! Moment 例

| プロダクト | Aha! Moment | 指標 |
|-----------|-------------|------|
| Facebook | 10日以内に7人の友達 | Day10までのfriend追加数 >= 7 |
| Slack | チームで2,000メッセージ | 累計メッセージ数 >= 2000 |
| Dropbox | 1つのファイルをフォルダに保存 | ファイルアップロード >= 1 |
| Zoom | 初回ミーティング完了 | ミーティング完了 >= 1 |
| Notion | 3つ以上のページ作成 | ページ作成数 >= 3 |

### 自社プロダクトの Aha! Moment 定義手順

```markdown
## Step 1: リテンションとの相関分析

1. Day 7 / Day 30 リテンションが高いユーザー群を特定
2. そのユーザー群が初日〜3日目に行ったアクションを集計
3. アクション別にリテンション率の差を比較

## Step 2: 候補アクションの絞り込み

| アクション候補 | 実行者のD30リテンション | 未実行者のD30リテンション | 差分 |
|---------------|----------------------|------------------------|------|
| プロジェクト作成 | __% | __% | __pp |
| チームメンバー招待 | __% | __% | __pp |
| 初回タスク完了 | __% | __% | __pp |
| テンプレート利用 | __% | __% | __pp |
| インテグレーション接続 | __% | __% | __pp |

→ 差分が最大のアクションが Aha! Moment 候補

## Step 3: 閾値の決定

「プロジェクト作成」が最有力候補の場合:
- 1プロジェクト作成 → リテンション 45%
- 2プロジェクト作成 → リテンション 62%
- 3プロジェクト作成 → リテンション 71%
- 4プロジェクト作成 → リテンション 73%（ほぼ頭打ち）

→ Aha! Moment: 「3日以内に3プロジェクト作成」
```

---

## オンボーディングチェックリスト UI

### React 実装例

```tsx
// components/onboarding/checklist.tsx
"use client";

import { useState, useEffect } from "react";
import { CheckCircle2, Circle, ChevronRight } from "lucide-react";

interface OnboardingStep {
  id: string;
  title: string;
  description: string;
  completed: boolean;
  action: () => void;
  skippable: boolean;
}

interface OnboardingChecklistProps {
  userId: string;
}

export function OnboardingChecklist({ userId }: OnboardingChecklistProps) {
  const [steps, setSteps] = useState<OnboardingStep[]>([]);
  const [isExpanded, setIsExpanded] = useState(true);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    fetchOnboardingProgress(userId).then(setSteps);
  }, [userId]);

  const completedCount = steps.filter((s) => s.completed).length;
  const totalCount = steps.length;
  const progress = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  if (dismissed || completedCount === totalCount) return null;

  return (
    <div className="fixed bottom-4 right-4 w-80 bg-white rounded-lg shadow-lg border">
      {/* ヘッダー */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full p-4 flex items-center justify-between"
      >
        <div>
          <h3 className="font-semibold text-sm">Getting Started</h3>
          <p className="text-xs text-gray-500">
            {completedCount}/{totalCount} completed
          </p>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-16 h-2 bg-gray-200 rounded-full">
            <div
              className="h-2 bg-blue-500 rounded-full transition-all"
              style={{ width: `${progress}%` }}
            />
          </div>
          <ChevronRight
            className={`w-4 h-4 transition-transform ${
              isExpanded ? "rotate-90" : ""
            }`}
          />
        </div>
      </button>

      {/* ステップ一覧 */}
      {isExpanded && (
        <div className="px-4 pb-4 space-y-2">
          {steps.map((step) => (
            <button
              key={step.id}
              onClick={step.action}
              disabled={step.completed}
              className={`w-full flex items-start gap-3 p-2 rounded text-left
                ${step.completed
                  ? "opacity-60"
                  : "hover:bg-gray-50 cursor-pointer"
                }`}
            >
              {step.completed ? (
                <CheckCircle2 className="w-5 h-5 text-green-500 mt-0.5 shrink-0" />
              ) : (
                <Circle className="w-5 h-5 text-gray-300 mt-0.5 shrink-0" />
              )}
              <div>
                <p className="text-sm font-medium">{step.title}</p>
                <p className="text-xs text-gray-500">{step.description}</p>
              </div>
            </button>
          ))}

          <button
            onClick={() => setDismissed(true)}
            className="w-full text-xs text-gray-400 hover:text-gray-600 mt-2"
          >
            Dismiss
          </button>
        </div>
      )}
    </div>
  );
}
```

### ステップ定義の例

```typescript
// lib/onboarding/steps.ts
import { useRouter } from "next/navigation";

export function useOnboardingSteps() {
  const router = useRouter();

  return [
    {
      id: "create_profile",
      title: "Complete your profile",
      description: "Add your name and avatar",
      action: () => router.push("/settings/profile"),
      skippable: true,
    },
    {
      id: "create_first_project",
      title: "Create your first project",
      description: "Start with a blank project or use a template",
      action: () => router.push("/projects/new"),
      skippable: false,
    },
    {
      id: "invite_team_member",
      title: "Invite a team member",
      description: "Collaboration makes everything better",
      action: () => router.push("/settings/team"),
      skippable: true,
    },
    {
      id: "connect_integration",
      title: "Connect an integration",
      description: "Link Slack, GitHub, or other tools",
      action: () => router.push("/settings/integrations"),
      skippable: true,
    },
    {
      id: "complete_first_task",
      title: "Complete your first task",
      description: "Mark a task as done to see the workflow",
      action: () => router.push("/projects"),
      skippable: false,
    },
  ];
}
```

### 進捗の永続化

```typescript
// lib/onboarding/progress.ts
import { createClient } from "@/lib/supabase/client";

export async function fetchOnboardingProgress(userId: string) {
  const supabase = createClient();

  const { data } = await supabase
    .from("onboarding_progress")
    .select("step_id, completed_at")
    .eq("user_id", userId);

  return data ?? [];
}

export async function markStepCompleted(userId: string, stepId: string) {
  const supabase = createClient();

  await supabase.from("onboarding_progress").upsert(
    {
      user_id: userId,
      step_id: stepId,
      completed_at: new Date().toISOString(),
    },
    { onConflict: "user_id,step_id" }
  );
}

// DBスキーマ
// CREATE TABLE onboarding_progress (
//   user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
//   step_id TEXT NOT NULL,
//   completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
//   PRIMARY KEY (user_id, step_id)
// );
```

---

## セグメント別オンボーディング分岐

### ユーザーセグメントの決定

```typescript
// lib/onboarding/segmentation.ts

type UserSegment =
  | "solo_creator"    // 個人利用
  | "team_lead"       // チームリーダー
  | "team_member"     // 招待されたメンバー
  | "evaluator";      // トライアル評価者

interface SegmentQuestion {
  question: string;
  options: { label: string; segment: UserSegment }[];
}

export const segmentQuestions: SegmentQuestion[] = [
  {
    question: "How will you be using this tool?",
    options: [
      { label: "Personal projects", segment: "solo_creator" },
      { label: "Managing a team", segment: "team_lead" },
      { label: "I was invited by someone", segment: "team_member" },
      { label: "Evaluating for my company", segment: "evaluator" },
    ],
  },
];
```

### セグメント別ステップ構成

```markdown
## solo_creator（個人利用）
1. プロフィール設定
2. テンプレートからプロジェクト作成（推奨テンプレ提示）
3. 最初のタスク完了
4. カスタマイズ（テーマ・通知設定）

## team_lead（チームリーダー）
1. プロフィール設定
2. チームワークスペース作成
3. メンバー招待（最低1人）
4. プロジェクト作成
5. 権限設定の確認

## team_member（招待メンバー）
1. プロフィール設定
2. チーム確認・参加
3. 既存プロジェクトの閲覧
4. 最初のタスク完了

## evaluator（評価者）
1. プロフィール設定（企業名含む）
2. デモデータ付きプロジェクト自動生成
3. 主要機能のガイドツアー
4. レポート・分析機能の体験
5. 価格プラン比較ページへ誘導
```

---

## Drop-off 分析

### ファネル定義

```
Sign Up
  ↓ (Drop-off率 = A%)
Welcome Survey 完了
  ↓ (Drop-off率 = B%)
最初のアクション完了
  ↓ (Drop-off率 = C%)
Aha! Moment 到達
  ↓ (Drop-off率 = D%)
Day 7 リテンション
  ↓ (Drop-off率 = E%)
Day 30 リテンション
```

### 計測すべきイベント

```typescript
// lib/analytics/onboarding-events.ts

export const ONBOARDING_EVENTS = {
  // ファネル
  SIGNUP_COMPLETED: "onboarding.signup_completed",
  WELCOME_SURVEY_COMPLETED: "onboarding.welcome_survey_completed",
  WELCOME_SURVEY_SKIPPED: "onboarding.welcome_survey_skipped",
  FIRST_ACTION_COMPLETED: "onboarding.first_action_completed",
  AHA_MOMENT_REACHED: "onboarding.aha_moment_reached",
  ONBOARDING_COMPLETED: "onboarding.completed",
  ONBOARDING_DISMISSED: "onboarding.dismissed",

  // ステップ別
  STEP_STARTED: "onboarding.step_started",
  STEP_COMPLETED: "onboarding.step_completed",
  STEP_SKIPPED: "onboarding.step_skipped",

  // エンゲージメント
  CHECKLIST_OPENED: "onboarding.checklist_opened",
  CHECKLIST_CLOSED: "onboarding.checklist_closed",
  TOOLTIP_SHOWN: "onboarding.tooltip_shown",
  TOOLTIP_DISMISSED: "onboarding.tooltip_dismissed",

  // 時間計測
  TIME_TO_FIRST_ACTION: "onboarding.time_to_first_action",
  TIME_TO_AHA_MOMENT: "onboarding.time_to_aha_moment",
} as const;

export function trackOnboardingEvent(
  event: string,
  properties?: Record<string, unknown>
) {
  analytics.track(event, {
    ...properties,
    timestamp: new Date().toISOString(),
  });
}
```

### Drop-off 対策マトリクス

| Drop-off ポイント | 主な原因 | 対策 |
|------------------|---------|------|
| Sign Up → Welcome Survey | サーベイが長い | 質問を3問以下に削減 |
| Welcome → First Action | 何をすべきか不明 | 自動的に最初のアクションへ誘導 |
| First Action → Aha! Moment | 価値を感じない | テンプレート/サンプルデータ提供 |
| Aha! → Day 7 | 習慣化しない | Day 2, 5 にリエンゲージメントメール |
| Day 7 → Day 30 | 代替ツールへ移行 | 固有の価値提案、インテグレーション |

---

## TTV 改善チェックリスト

```markdown
## TTV 最適化チェックリスト

### サインアップフロー
- [ ] ソーシャルログイン（Google/GitHub）対応
- [ ] サインアップフォームは最小項目（メール+パスワード or OAuth のみ）
- [ ] メール確認はバックグラウンドで（ブロッキングにしない）
- [ ] サインアップ後に即座に製品画面へ遷移

### 初期体験
- [ ] Welcome Survey は3問以内
- [ ] セグメント別のオンボーディング分岐
- [ ] サンプルデータ / テンプレートの提供
- [ ] 空の状態（Empty State）にアクション誘導を配置

### ガイダンス
- [ ] インタラクティブなステップバイステップチュートリアル
- [ ] コンテキストに応じたツールチップ
- [ ] プログレスバー付きチェックリスト
- [ ] 「次にやること」の明確な提示

### 技術的最適化
- [ ] 初回ロード時間 < 3秒
- [ ] 最初の有意義なアクションまでのクリック数 < 5
- [ ] モバイル対応（レスポンシブ）
- [ ] エラー時の親切なメッセージとリカバリー手段

### 計測と改善
- [ ] Aha! Moment をデータで定義済み
- [ ] オンボーディングファネルの計測設定済み
- [ ] Drop-off ポイントの週次レビュー
- [ ] A/B テストの実施体制
```

---

## 計測ダッシュボード項目

```markdown
## オンボーディング KPI ダッシュボード

### 主要指標
- サインアップ → Aha! Moment 到達率: __%
- 平均 TTV（Time to Value）: __ 時間
- オンボーディング完了率: __%
- Day 1 リテンション: __%
- Day 7 リテンション: __%

### ステップ別メトリクス
| ステップ | 開始率 | 完了率 | 平均所要時間 | スキップ率 |
|---------|--------|--------|------------|----------|
| プロフィール設定 | __% | __% | __分 | __% |
| 最初のプロジェクト | __% | __% | __分 | __% |
| メンバー招待 | __% | __% | __分 | __% |
| インテグレーション | __% | __% | __分 | __% |
| 最初のタスク完了 | __% | __% | __分 | __% |

### セグメント別比較
| セグメント | Aha到達率 | 平均TTV | D7リテンション |
|-----------|----------|---------|---------------|
| solo_creator | __% | __ h | __% |
| team_lead | __% | __ h | __% |
| team_member | __% | __ h | __% |
| evaluator | __% | __ h | __% |
```
