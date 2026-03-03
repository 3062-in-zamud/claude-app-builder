# エラーハンドリングパターン

## 1. Result 型（neverthrow）

### インストール

```bash
npm install neverthrow
```

### 基本パターン

```typescript
import { ok, err, Result } from 'neverthrow'

// エラー型の定義
type AppError = {
  code: string
  message: string
  statusCode: number
  details?: unknown
}

// Result 型を返す関数
function parseEmail(input: string): Result<string, AppError> {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(input)) {
    return err({
      code: 'INVALID_EMAIL',
      message: `Invalid email format: ${input}`,
      statusCode: 400,
    })
  }
  return ok(input.toLowerCase())
}

// 使用例: チェーン処理
function createUser(input: { email: string; name: string }) {
  return parseEmail(input.email)
    .andThen(email => validateName(input.name).map(name => ({ email, name })))
    .andThen(validated => saveToDatabase(validated))
}

// 使用例: match で分岐
const result = createUser({ email: 'test@example.com', name: 'Taro' })
result.match(
  user => console.log('Created:', user),
  error => console.error('Failed:', error.code),
)
```

### よくあるパターン

```typescript
// 複数の Result を組み合わせる
import { Result, ok, err } from 'neverthrow'

function validatePostInput(input: unknown): Result<PostInput, AppError> {
  const title = validateTitle(input.title)    // Result<string, AppError>
  const body = validateBody(input.body)        // Result<string, AppError>

  return Result.combine([title, body]).map(([t, b]) => ({
    title: t,
    body: b,
  }))
}

// async の Result
import { ResultAsync } from 'neverthrow'

function fetchUser(id: string): ResultAsync<User, AppError> {
  return ResultAsync.fromPromise(
    supabase.from('users').select().eq('id', id).single(),
    (e) => ({
      code: 'DB_ERROR',
      message: 'Failed to fetch user',
      statusCode: 500,
      details: e,
    }),
  ).andThen(({ data, error }) => {
    if (error) return err({ code: 'NOT_FOUND', message: 'User not found', statusCode: 404 })
    return ok(data as User)
  })
}
```

## 2. RFC 7807 Problem Details

### API エラーレスポンス形式

```typescript
// src/lib/errors/problem-details.ts
interface ProblemDetails {
  type: string        // エラー種別のURI
  title: string       // 人間可読な短い説明
  status: number      // HTTP ステータスコード
  detail?: string     // 詳細な説明
  instance?: string   // 発生した具体的なURI
  // 拡張フィールド（任意）
  errors?: Array<{ field: string; message: string }>
}

// エラーレスポンスを生成するヘルパー
export function createProblemResponse(problem: ProblemDetails): Response {
  return new Response(JSON.stringify(problem), {
    status: problem.status,
    headers: {
      'Content-Type': 'application/problem+json',
    },
  })
}

// 事前定義エラー
export const Problems = {
  validation: (detail: string, errors?: Array<{ field: string; message: string }>): ProblemDetails => ({
    type: 'https://api.example.com/errors/validation',
    title: 'Validation Error',
    status: 400,
    detail,
    errors,
  }),

  unauthorized: (): ProblemDetails => ({
    type: 'https://api.example.com/errors/unauthorized',
    title: 'Unauthorized',
    status: 401,
    detail: 'Authentication is required to access this resource',
  }),

  forbidden: (): ProblemDetails => ({
    type: 'https://api.example.com/errors/forbidden',
    title: 'Forbidden',
    status: 403,
    detail: 'You do not have permission to access this resource',
  }),

  notFound: (resource: string): ProblemDetails => ({
    type: 'https://api.example.com/errors/not-found',
    title: 'Not Found',
    status: 404,
    detail: `${resource} not found`,
  }),

  conflict: (detail: string): ProblemDetails => ({
    type: 'https://api.example.com/errors/conflict',
    title: 'Conflict',
    status: 409,
    detail,
  }),

  rateLimit: (): ProblemDetails => ({
    type: 'https://api.example.com/errors/rate-limit',
    title: 'Too Many Requests',
    status: 429,
    detail: 'Rate limit exceeded. Please try again later.',
  }),

  internal: (): ProblemDetails => ({
    type: 'https://api.example.com/errors/internal',
    title: 'Internal Server Error',
    status: 500,
    detail: 'An unexpected error occurred',
    // 本番ではスタックトレースを含めない
  }),
}
```

### API Route での使用例

```typescript
// src/features/posts/api/route.ts
import { createProblemResponse, Problems } from '@/lib/errors/problem-details'

export async function POST(request: Request) {
  // 認証チェック
  const user = await getAuthUser(request)
  if (!user) {
    return createProblemResponse(Problems.unauthorized())
  }

  // バリデーション
  const body = await request.json()
  const validation = validatePostInput(body)
  if (validation.isErr()) {
    const error = validation._unsafeUnwrapErr()
    return createProblemResponse(Problems.validation(error.message, error.details))
  }

  // 作成
  const result = await createPost(validation._unsafeUnwrap(), user.id)
  return result.match(
    post => Response.json(post, { status: 201 }),
    error => createProblemResponse({
      type: `https://api.example.com/errors/${error.code.toLowerCase()}`,
      title: error.code,
      status: error.statusCode,
      detail: error.message,
    }),
  )
}
```

## 3. React エラー境界

```typescript
// src/shared/components/ErrorBoundary.tsx
'use client'

import { Component, ReactNode } from 'react'
import * as Sentry from '@sentry/nextjs'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    Sentry.captureException(error, { extra: { componentStack: errorInfo.componentStack } })
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-8 text-center">
          <h2 className="text-xl font-bold mb-2">問題が発生しました</h2>
          <p className="text-gray-600 mb-4">画面を再読み込みしてください</p>
          <button
            onClick={() => this.setState({ hasError: false })}
            className="px-4 py-2 bg-primary text-white rounded"
          >
            再試行
          </button>
        </div>
      )
    }

    return this.props.children
  }
}
```

### Next.js error.tsx パターン

```typescript
// src/app/error.tsx
'use client'

import * as Sentry from '@sentry/nextjs'
import { useEffect } from 'react'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    Sentry.captureException(error)
  }, [error])

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h2 className="text-2xl font-bold mb-4">問題が発生しました</h2>
        <p className="text-gray-600 mb-6">
          申し訳ございません。予期しないエラーが発生しました。
        </p>
        <button
          onClick={reset}
          className="px-6 py-3 bg-primary text-white rounded-lg"
        >
          もう一度試す
        </button>
      </div>
    </div>
  )
}
```

## 4. エラーハンドリング設計原則

| 原則 | 説明 |
|------|------|
| **Fail Fast** | 入力バリデーションは処理の最初に行う |
| **型で表現** | try-catch よりも Result 型で明示的にエラーを扱う |
| **境界で変換** | 外部エラー（DB、API）はアプリ内エラー型に変換する |
| **ログは境界で** | エラーログは API Route やミドルウェアで出力する |
| **ユーザーに安全** | エラーメッセージにスタックトレース・内部情報を含めない |
| **リカバリー可能** | ユーザーが「再試行」できるUIを常に提供する |
