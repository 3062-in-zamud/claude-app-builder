---
name: cookie-consent
description: |
  What: GDPR準拠のCookie同意バナーとカテゴリ別同意管理を実装する
  When: Phase 4（legal-docs-generator と並列、EU対象時は必須）
  How: ライブラリ選定 → バナーUI生成 → カテゴリ別同意管理 → Google Consent Mode v2対応
model: claude-haiku-4-5-20251001
allowed-tools:
  - Read
  - Write
---

# cookie-consent: Cookie同意管理

## 免責事項

**このツールが生成するCookie同意バナーはテンプレートです。GDPR/ePrivacy指令への完全な準拠については法律専門家にレビューを依頼してください。**

## ワークフロー

### Step 1: 要件確認

`docs/requirements.md` を読み込み、以下を確認:
- 対象地域（EU含む場合はGDPR準拠必須）
- 使用する外部サービス（Analytics、広告等）
- 技術スタック（Next.js / React）

### Step 2: ライブラリ選定

| ライブラリ | 特徴 | バンドルサイズ | 推奨度 |
|-----------|------|-------------|--------|
| `@cookie-consent/react` | React向け、カスタマイズ性高 | ~8KB | ✅ 推奨 |
| `vanilla-cookieconsent` | フレームワーク非依存、軽量 | ~5KB | ✅ |
| `react-cookie-consent` | シンプル、導入容易 | ~3KB | ✅ MVP向け |
| Cookiebot / OneTrust | 企業向け、自動スキャン | 外部スクリプト | エンタープライズ向け |

**MVP推奨**: `react-cookie-consent`（最小構成）→ 成長後に `vanilla-cookieconsent` に移行

### Step 3: Cookie カテゴリ定義

```typescript
// lib/cookie-categories.ts
export const COOKIE_CATEGORIES = {
  necessary: {
    name: '必須Cookie',
    description: 'サービスの基本機能に必要なCookieです。無効にできません。',
    required: true,
    cookies: [
      { name: 'supabase-auth-token', purpose: '認証状態の維持', expiry: 'セッション' },
      { name: 'cookie-consent', purpose: 'Cookie同意設定の保存', expiry: '1年' },
    ],
  },
  analytics: {
    name: '分析Cookie',
    description: 'サービスの利用状況を分析し、改善に役立てるためのCookieです。',
    required: false,
    cookies: [
      { name: '_vercel_insights', purpose: 'Vercel Analytics', expiry: '1年' },
    ],
  },
  marketing: {
    name: 'マーケティングCookie',
    description: '広告の効果測定やパーソナライズに使用するCookieです。',
    required: false,
    cookies: [
      { name: '_ga', purpose: 'Google Analytics', expiry: '2年' },
      { name: '_fbp', purpose: 'Facebook Pixel', expiry: '3ヶ月' },
    ],
  },
} as const;
```

### Step 4: Cookie同意バナーUI生成

```tsx
// components/cookie-banner.tsx
'use client';

import { useState, useEffect } from 'react';

type ConsentState = {
  necessary: true; // 常にtrue
  analytics: boolean;
  marketing: boolean;
};

const CONSENT_KEY = 'cookie-consent';

export function CookieBanner() {
  const [visible, setVisible] = useState(false);
  const [showDetails, setShowDetails] = useState(false);
  const [consent, setConsent] = useState<ConsentState>({
    necessary: true,
    analytics: false,
    marketing: false,
  });

  useEffect(() => {
    const stored = localStorage.getItem(CONSENT_KEY);
    if (!stored) {
      setVisible(true);
    }
  }, []);

  const saveConsent = (state: ConsentState) => {
    localStorage.setItem(CONSENT_KEY, JSON.stringify(state));
    setVisible(false);
    updateConsentMode(state);
  };

  const acceptAll = () => {
    saveConsent({ necessary: true, analytics: true, marketing: true });
  };

  const rejectOptional = () => {
    saveConsent({ necessary: true, analytics: false, marketing: false });
  };

  const saveCustom = () => {
    saveConsent(consent);
  };

  if (!visible) return null;

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 p-4 bg-white border-t shadow-lg">
      <div className="max-w-4xl mx-auto">
        <p className="text-sm text-gray-700 mb-3">
          当サイトではCookieを使用しています。必須Cookieはサービスの動作に必要です。
          分析・マーケティングCookieは任意です。
          <a href="/cookies" className="underline text-blue-600 ml-1">
            Cookieポリシー
          </a>
        </p>

        {showDetails && (
          <div className="mb-3 space-y-2">
            <label className="flex items-center gap-2 text-sm">
              <input type="checkbox" checked disabled />
              必須Cookie（無効化不可）
            </label>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={consent.analytics}
                onChange={e => setConsent(prev => ({ ...prev, analytics: e.target.checked }))}
              />
              分析Cookie
            </label>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={consent.marketing}
                onChange={e => setConsent(prev => ({ ...prev, marketing: e.target.checked }))}
              />
              マーケティングCookie
            </label>
          </div>
        )}

        <div className="flex flex-wrap gap-2">
          <button
            onClick={acceptAll}
            className="px-4 py-2 bg-blue-600 text-white text-sm rounded"
          >
            すべて許可
          </button>
          <button
            onClick={rejectOptional}
            className="px-4 py-2 bg-gray-200 text-gray-700 text-sm rounded"
          >
            必須のみ
          </button>
          {!showDetails ? (
            <button
              onClick={() => setShowDetails(true)}
              className="px-4 py-2 text-sm text-gray-500 underline"
            >
              詳細設定
            </button>
          ) : (
            <button
              onClick={saveCustom}
              className="px-4 py-2 bg-gray-600 text-white text-sm rounded"
            >
              カスタム設定を保存
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
```

### Step 5: Google Consent Mode v2 対応

```typescript
// lib/consent-mode.ts

declare global {
  interface Window {
    dataLayer: Record<string, unknown>[];
    gtag: (...args: unknown[]) => void;
  }
}

type ConsentState = {
  necessary: boolean;
  analytics: boolean;
  marketing: boolean;
};

/**
 * Google Consent Mode v2 のデフォルト設定（同意取得前）
 * ページ読み込み時に呼び出す
 */
export function initConsentMode() {
  window.dataLayer = window.dataLayer || [];
  function gtag(...args: unknown[]) {
    window.dataLayer.push(Object.fromEntries(args.map((a, i) => [i, a])));
  }
  window.gtag = gtag;

  // デフォルト: 全て拒否
  gtag('consent', 'default', {
    ad_storage: 'denied',
    ad_user_data: 'denied',
    ad_personalization: 'denied',
    analytics_storage: 'denied',
    functionality_storage: 'granted', // 必須Cookie
    personalization_storage: 'denied',
    security_storage: 'granted', // セキュリティ関連は常に許可
  });
}

/**
 * ユーザーの同意選択に基づいてConsent Modeを更新
 */
export function updateConsentMode(consent: ConsentState) {
  if (typeof window.gtag !== 'function') return;

  window.gtag('consent', 'update', {
    ad_storage: consent.marketing ? 'granted' : 'denied',
    ad_user_data: consent.marketing ? 'granted' : 'denied',
    ad_personalization: consent.marketing ? 'granted' : 'denied',
    analytics_storage: consent.analytics ? 'granted' : 'denied',
    personalization_storage: consent.analytics ? 'granted' : 'denied',
  });
}
```

### Step 6: Server-Side Consent 状態管理

```typescript
// lib/get-consent.ts
import { cookies } from 'next/headers';

type ConsentState = {
  necessary: true;
  analytics: boolean;
  marketing: boolean;
};

/**
 * サーバーサイドでCookie同意状態を取得
 * Server Component や API Route から使用
 */
export async function getServerConsent(): Promise<ConsentState> {
  const cookieStore = await cookies();
  const consent = cookieStore.get('cookie-consent');

  if (!consent?.value) {
    // 同意未取得: 必須のみ許可
    return { necessary: true, analytics: false, marketing: false };
  }

  try {
    const parsed = JSON.parse(consent.value);
    return {
      necessary: true,
      analytics: !!parsed.analytics,
      marketing: !!parsed.marketing,
    };
  } catch {
    return { necessary: true, analytics: false, marketing: false };
  }
}
```

### Step 7: layout.tsx への統合

```tsx
// app/layout.tsx に追加
import { CookieBanner } from '@/components/cookie-banner';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <head>
        {/* Google Consent Mode v2 初期化（gtag読み込み前に実行） */}
        <script
          dangerouslySetInnerHTML={{
            __html: `
              window.dataLayer = window.dataLayer || [];
              function gtag(){dataLayer.push(arguments);}
              gtag('consent', 'default', {
                'ad_storage': 'denied',
                'ad_user_data': 'denied',
                'ad_personalization': 'denied',
                'analytics_storage': 'denied',
                'functionality_storage': 'granted',
                'security_storage': 'granted'
              });
            `,
          }}
        />
      </head>
      <body>
        {children}
        <CookieBanner />
      </body>
    </html>
  );
}
```

## 出力ファイル

- `components/cookie-banner.tsx`（Cookie同意バナー）
- `lib/cookie-categories.ts`（Cookieカテゴリ定義）
- `lib/consent-mode.ts`（Google Consent Mode v2）
- `lib/get-consent.ts`（サーバーサイド同意状態取得）

## 品質チェック

- [ ] 同意取得前にトラッキングCookieが設置されていないか
- [ ] 「すべて許可」「必須のみ」「詳細設定」の3つの選択肢があるか
- [ ] 同意設定はいつでも変更可能か
- [ ] Cookieポリシーページへのリンクがあるか
- [ ] Google Consent Mode v2 のデフォルトが「denied」か
- [ ] 同意状態がサーバーサイドからも取得可能か
- [ ] 必須Cookieは無効化できないようになっているか
