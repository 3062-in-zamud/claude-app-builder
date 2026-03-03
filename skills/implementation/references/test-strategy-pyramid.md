# テストピラミッド戦略

## テスト配分の原則

```
       /\
      /  \       E2E (10%)
     /----\      Playwright: 主要ユーザーフロー
    /      \     Integration (20%)
   /--------\    Vitest + Testing Library: API・コンポーネント連携
  /          \   Unit (70%)
 /____________\  Vitest: ビジネスロジック・ユーティリティ
```

## Unit テスト（70%）

### 対象
- ビジネスロジック関数
- ユーティリティ関数
- バリデーション
- 型変換・データ整形
- カスタムフック（ロジック部分）

### 書き方ガイド

```typescript
// src/features/posts/lib/validate-post.test.ts
import { describe, it, expect } from 'vitest'
import { validatePost } from './validate-post'

describe('validatePost', () => {
  // Arrange-Act-Assert パターン
  it('タイトルが空の場合、バリデーションエラーを返す', () => {
    // Arrange
    const input = { title: '', body: 'Some content' }

    // Act
    const result = validatePost(input)

    // Assert
    expect(result.isErr()).toBe(true)
    expect(result._unsafeUnwrapErr().code).toBe('VALIDATION_ERROR')
  })

  it('有効な入力の場合、バリデーション済みデータを返す', () => {
    const input = { title: 'Hello', body: 'World' }
    const result = validatePost(input)
    expect(result.isOk()).toBe(true)
    expect(result._unsafeUnwrap().title).toBe('Hello')
  })

  // 境界値テスト
  it('タイトルが100文字の場合、成功する', () => {
    const input = { title: 'a'.repeat(100), body: 'content' }
    expect(validatePost(input).isOk()).toBe(true)
  })

  it('タイトルが101文字の場合、エラーを返す', () => {
    const input = { title: 'a'.repeat(101), body: 'content' }
    expect(validatePost(input).isErr()).toBe(true)
  })
})
```

### Unit テストのルール
- 外部依存はモックする（DB、API、ファイルシステム）
- 1テスト1アサーション（理想）
- テスト名は「条件 → 期待結果」で書く
- カバレッジ目標: ビジネスロジックは 90% 以上

## Integration テスト（20%）

### 対象
- API Route ハンドラ（リクエスト→レスポンス）
- DB 操作（Supabase クライアント経由）
- コンポーネント間の連携
- ミドルウェア

### 書き方ガイド

```typescript
// src/features/posts/api/__tests__/create-post.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { POST } from '../route'
import { createMockRequest } from '@/test-utils/mock-request'

// Supabase クライアントのモック
vi.mock('@/lib/supabase/server', () => ({
  createClient: () => ({
    from: vi.fn().mockReturnThis(),
    insert: vi.fn().mockResolvedValue({ data: { id: '1' }, error: null }),
    auth: {
      getUser: vi.fn().mockResolvedValue({
        data: { user: { id: 'user-1' } },
        error: null,
      }),
    },
  }),
}))

describe('POST /api/posts', () => {
  it('認証済みユーザーが有効なデータで投稿を作成できる', async () => {
    const request = createMockRequest({
      method: 'POST',
      body: { title: 'Test Post', body: 'Test Body' },
      headers: { Authorization: 'Bearer valid-token' },
    })

    const response = await POST(request)
    const data = await response.json()

    expect(response.status).toBe(201)
    expect(data.id).toBeDefined()
  })

  it('未認証リクエストは401を返す', async () => {
    const request = createMockRequest({
      method: 'POST',
      body: { title: 'Test' },
    })

    const response = await POST(request)
    expect(response.status).toBe(401)
  })

  it('バリデーションエラーはRFC7807形式で返す', async () => {
    const request = createMockRequest({
      method: 'POST',
      body: { title: '' },
      headers: { Authorization: 'Bearer valid-token' },
    })

    const response = await POST(request)
    const data = await response.json()

    expect(response.status).toBe(400)
    expect(data.type).toContain('/errors/')
    expect(data.title).toBeDefined()
    expect(data.status).toBe(400)
  })
})
```

### コンポーネントIntegrationテスト

```typescript
// src/features/posts/components/__tests__/PostForm.test.tsx
import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { PostForm } from '../PostForm'

describe('PostForm', () => {
  it('フォーム送信時にonSubmitが呼ばれる', async () => {
    const onSubmit = vi.fn()
    render(<PostForm onSubmit={onSubmit} />)

    fireEvent.change(screen.getByLabelText('タイトル'), {
      target: { value: 'Test' },
    })
    fireEvent.change(screen.getByLabelText('本文'), {
      target: { value: 'Content' },
    })
    fireEvent.click(screen.getByRole('button', { name: '投稿' }))

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        title: 'Test',
        body: 'Content',
      })
    })
  })
})
```

## E2E テスト（10%）

### 対象
- 登録→ログイン→主要機能→ログアウト の主要フロー
- 決済フロー（ある場合）
- クリティカルなユーザージャーニー

### 書き方ガイド

```typescript
// e2e/auth-flow.spec.ts
import { test, expect } from '@playwright/test'

test.describe('認証フロー', () => {
  test('新規ユーザーが登録→ログイン→プロフィール確認できる', async ({ page }) => {
    // 登録
    await page.goto('/signup')
    await page.getByLabel('メールアドレス').fill('test@example.com')
    await page.getByLabel('パスワード').fill('SecurePass123!')
    await page.getByRole('button', { name: '登録' }).click()

    // 登録完了確認
    await expect(page.getByText('アカウントを作成しました')).toBeVisible()

    // ダッシュボードに遷移
    await expect(page).toHaveURL('/dashboard')

    // プロフィール確認
    await page.getByRole('link', { name: 'プロフィール' }).click()
    await expect(page.getByText('test@example.com')).toBeVisible()
  })
})
```

### E2E テストのルール
- 主要フローのみ（網羅的にしない）
- ページオブジェクトパターンでメンテナンス性向上
- CI で毎PR実行（ただし時間制限を設定）
- フレーキーテストは即修正または削除

## テストユーティリティ

```typescript
// src/test-utils/mock-request.ts
export function createMockRequest(options: {
  method: string
  body?: unknown
  headers?: Record<string, string>
}): Request {
  return new Request('http://localhost:3000/api/test', {
    method: options.method,
    headers: new Headers({
      'Content-Type': 'application/json',
      ...options.headers,
    }),
    body: options.body ? JSON.stringify(options.body) : undefined,
  })
}

// src/test-utils/setup.ts
import { vi } from 'vitest'

// 共通のモックセットアップ
export function setupTestEnv() {
  vi.stubEnv('NODE_ENV', 'test')
  vi.stubEnv('NEXT_PUBLIC_SUPABASE_URL', 'http://localhost:54321')
  vi.stubEnv('NEXT_PUBLIC_SUPABASE_ANON_KEY', 'test-anon-key')
}
```

## カバレッジ目標

| 対象 | 目標 | 計測コマンド |
|------|------|------------|
| 全体 | 80% 以上 | `npm run test:coverage` |
| ビジネスロジック (`lib/`) | 90% 以上 | - |
| API ルート (`api/`) | 80% 以上 | - |
| コンポーネント | 70% 以上 | - |
| E2E | 主要フロー3-5本 | `npx playwright test` |
