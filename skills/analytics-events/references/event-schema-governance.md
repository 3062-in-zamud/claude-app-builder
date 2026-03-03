# イベントスキーマガバナンス

## イベント命名規則

### フォーマット

```
{object}_{action}
```

- **snake_case** を使用
- `{object}`: 対象のエンティティ（名詞）
- `{action}`: 実行されたアクション（過去分詞）

### 命名例

| OK | NG | 理由 |
|-----|------|------|
| `sign_up_completed` | `signUpCompleted` | camelCase は禁止 |
| `post_created` | `create-post` | ハイフン禁止、動詞始まり禁止 |
| `feature_used` | `FeatureUsed` | PascalCase は禁止 |
| `upgrade_clicked` | `clicked_upgrade` | object が先、action が後 |
| `page_viewed` | `pageview` | 単語は分割してアンダースコアで接続 |

### アクション語彙（統一辞書）

| アクション | 意味 | 使用例 |
|-----------|------|--------|
| `viewed` | 画面・要素が表示された | `page_viewed`, `pricing_viewed` |
| `clicked` | ボタン・リンクをクリック | `cta_clicked`, `upgrade_clicked` |
| `started` | プロセスを開始 | `sign_up_started`, `onboarding_started` |
| `completed` | プロセスが完了 | `sign_up_completed`, `purchase_completed` |
| `created` | リソースを新規作成 | `post_created`, `comment_created` |
| `updated` | リソースを更新 | `profile_updated`, `settings_updated` |
| `deleted` | リソースを削除 | `post_deleted`, `account_deleted` |
| `sent` | メッセージ・招待を送信 | `invite_sent`, `message_sent` |
| `cancelled` | プロセスをキャンセル | `subscription_cancelled` |
| `failed` | プロセスが失敗 | `payment_failed`, `upload_failed` |
| `searched` | 検索を実行 | `content_searched` |

### 禁止パターン

- `click_button` → ボタンクリックは `{element}_clicked` で表現
- `user_action` → 曖昧。具体的なアクションを使う
- `track_event` → メタイベントは不要
- `misc` / `other` → 不明確なカテゴリ禁止

## イベントプロパティ規則

### 共通プロパティ（全イベントに自動付与）

```typescript
interface CommonProperties {
  // 自動付与（analytics.ts 内で設定）
  timestamp: string       // ISO 8601
  session_id: string      // セッション識別子
  page_url: string        // 現在のページURL
  page_title: string      // ページタイトル

  // ユーザーコンテキスト（ログイン時のみ）
  user_id?: string        // ユーザーID（匿名時は除外）
  signup_date?: string    // 登録日（コホート分析用）
  plan_type?: string      // プランタイプ
}
```

### プロパティ命名規則

```
snake_case を使用。型は string | number | boolean のみ。
```

| OK | NG | 理由 |
|-----|------|------|
| `feature_name` | `featureName` | camelCase 禁止 |
| `days_since_signup` | `daysSinceSignup` | camelCase 禁止 |
| `is_first_purchase` | `firstPurchase` | boolean は `is_` プレフィックス |
| `visit_count` | `count` | 曖昧な名前は禁止 |

### プロパティ型制約

```typescript
// 許可される型
type PropertyValue = string | number | boolean

// 禁止される型
// - object（ネストされたオブジェクト）
// - array（配列）
// - null / undefined（送信しない）
// - Date（ISO 8601 文字列に変換する）
```

## スキーマバージョニング

### バージョン管理方針

```typescript
// イベントスキーマにバージョンを含める
interface EventEnvelope {
  schema_version: string  // セマンティックバージョニング
  event: string           // イベント名
  timestamp: string
  properties: Record<string, string | number | boolean>
}

// バージョン更新ルール
// MAJOR: プロパティの削除・型変更（破壊的変更）
// MINOR: プロパティの追加（後方互換）
// PATCH: プロパティの説明変更（動作変更なし）
```

### スキーマ変更ログ

```markdown
# Event Schema Changelog

## v1.1.0 (YYYY-MM-DD)
- Added: `signup_source` property to `sign_up_completed`
- Added: `referral_completed` event

## v1.0.0 (YYYY-MM-DD)
- Initial release
- Defined AARRR events
```

## 型定義（TypeScript）

### イベントカタログ

```typescript
// src/lib/analytics/event-types.ts

// イベントカタログ: 全イベントの型定義
interface EventCatalog {
  // Acquisition
  page_viewed: {
    page: string
    utm_source?: string
    utm_medium?: string
    utm_campaign?: string
    referrer: string
  }
  cta_clicked: {
    cta_id: string
    cta_text: string
  }

  // Activation
  sign_up_started: {
    source: string
  }
  sign_up_completed: {
    method: 'email' | 'google' | 'github'
    signup_date: string
  }
  onboarding_step_completed: {
    step: number
    total_steps: number
    completion_rate: number
  }
  onboarding_completed: {
    days_to_complete: number
  }
  first_value_moment: {
    action: string
  }

  // Retention
  session_started: {
    days_since_signup: number
    is_return_visit: boolean
  }
  feature_used: {
    feature_name: string
    [key: string]: string | number | boolean
  }
  return_visit: {
    days_since_signup: number
    visit_count: number
  }

  // Revenue
  pricing_viewed: {
    source: string
  }
  upgrade_clicked: {
    plan: string
    trigger: string
  }
  purchase_completed: {
    plan: string
    amount: number
    currency: string
    is_first_purchase: boolean
  }
  subscription_started: {
    plan: string
    interval: 'monthly' | 'yearly'
  }
  subscription_cancelled: {
    plan: string
    reason: string
    months_active: number
  }

  // Referral
  share_clicked: {
    platform: string
    content_type: string
  }
  invite_sent: {
    method: 'email' | 'link' | 'social'
    invite_count: number
  }
  referral_completed: {
    referrer_id: string
  }
}

// 型安全な track 関数
export function track<E extends keyof EventCatalog>(
  event: E,
  properties: EventCatalog[E],
): void {
  // 実装...
}
```

### 使用例

```typescript
import { track } from '@/lib/analytics/event-types'

// OK: 型チェックが効く
track('sign_up_completed', { method: 'email', signup_date: '2024-01-01' })

// NG: TypeScript エラー（method が不正）
track('sign_up_completed', { method: 'facebook', signup_date: '2024-01-01' })

// NG: TypeScript エラー（必須プロパティ不足）
track('sign_up_completed', { method: 'email' })
```

## スキーマレビュープロセス

### 新規イベント追加時

```markdown
## イベント追加チェックリスト

- [ ] 命名規則 `{object}_{action}` に従っているか
- [ ] 同様の目的の既存イベントがないか確認したか
- [ ] プロパティが snake_case で定義されているか
- [ ] プロパティの型が string | number | boolean のみか
- [ ] PII（個人情報）がプロパティに含まれていないか
- [ ] EventCatalog の型定義に追加したか
- [ ] スキーマ変更ログを更新したか
- [ ] analytics-plan.md のイベント一覧に追加したか
```

### 定期レビュー（月次）

```markdown
## 月次スキーマレビュー

1. 未使用イベントの確認
   - 過去30日間で発火がゼロのイベントを特定
   - 不要なら deprecate → 次回削除

2. プロパティの一貫性確認
   - 同じ概念を表すプロパティ名が統一されているか
   - 例: user_id / userId の混在がないか

3. イベント粒度の確認
   - 過度に詳細 → 集約を検討
   - 過度に粗い → 分割を検討

4. PII チェック
   - email, name, phone 等がプロパティに混入していないか
```

## プライバシー対応

### PII 除外リスト

以下のデータはイベントプロパティに含めない:

| データ | 理由 | 代替手段 |
|--------|------|---------|
| メールアドレス | PII | ハッシュ値 or 除外 |
| 氏名 | PII | 除外 |
| 電話番号 | PII | 除外 |
| IPアドレス | PII | 国/地域レベルに集約 |
| パスワード | 機密情報 | 絶対に含めない |
| クレジットカード | 機密情報 | 絶対に含めない |

### Cookie 同意レベル対応

```typescript
// 同意レベルに応じたプロパティフィルタリング
function filterProperties(
  properties: Record<string, unknown>,
  consentLevel: 'essential' | 'analytics' | 'marketing',
): Record<string, string | number | boolean> {
  if (consentLevel === 'essential') {
    return {} // 何も送らない
  }

  if (consentLevel === 'analytics') {
    // PII を除外した匿名データのみ
    const { user_id, email, name, ...anonymous } = properties
    return anonymous as Record<string, string | number | boolean>
  }

  // marketing: フルデータ
  return properties as Record<string, string | number | boolean>
}
```
