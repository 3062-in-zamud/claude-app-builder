# Feature Flag 実装ガイド

## 選択肢比較

| | Vercel Edge Config | PostHog | 自前実装 |
|--|-------------------|---------|---------|
| 費用 | Vercel Pro必要($20/月) | 無料〜(1M events/月) | 無料 |
| 速度 | Edge(超高速) | API呼び出し | DB依存 |
| 統計 | なし | 内蔵 | なし |
| 推奨 | Vercel Pro利用者 | 無料で始めたい | 最小構成 |

## useExperiment Hook

```typescript
// hooks/useExperiment.ts
'use client';
import { useEffect, useState } from 'react';

interface ExperimentConfig {
  name: string;
  variants: string[];
  defaultVariant?: string;
}

export function useExperiment({ name, variants, defaultVariant }: ExperimentConfig) {
  const [variant, setVariant] = useState(defaultVariant ?? variants[0]);

  useEffect(() => {
    // ユーザーIDベースの決定的割り当て
    const userId = getUserId(); // auth or anonymous ID
    const hash = simpleHash(`${name}:${userId}`);
    const index = hash % variants.length;
    setVariant(variants[index]);

    // 実験参加イベント送信
    track('experiment_viewed', { experiment: name, variant: variants[index] });
  }, [name]);

  return { variant, isControl: variant === variants[0] };
}

function simpleHash(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = ((hash << 5) - hash) + str.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash);
}
```

## 使用例

```tsx
function PricingPage() {
  const { variant } = useExperiment({
    name: 'pricing_cta_text',
    variants: ['control', 'treatment'],
  });

  return (
    <Button onClick={handleUpgrade}>
      {variant === 'control' ? 'アップグレード' : '今すぐ始める'}
    </Button>
  );
}
```

## ライフサイクル管理

1. **作成**: 実験設計テンプレートを記入
2. **有効化**: Feature Flag をON、トラフィック配分設定
3. **データ収集**: 最低2週間 or 必要サンプルサイズ到達まで
4. **判定**: 統計的有意性チェック + Guardrail確認
5. **クリーンアップ**: 勝者を恒久化、Feature Flagコードを削除
