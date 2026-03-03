# Zod 環境変数バリデーション設定

## 概要

Zod を使って環境変数を型安全に読み込み、起動時に不足を検出する。
ランタイムエラーの代わりに、明確なバリデーションエラーを出す。

## セットアップ

### 1. Zod インストール

```bash
npm install zod
```

### 2. env.ts 作成

`src/env.ts`:

```typescript
import { z } from 'zod'

// サーバーサイド環境変数
const serverSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1, 'SUPABASE_SERVICE_ROLE_KEY is required'),
  SENTRY_DSN: z.string().url().optional(),
})

// クライアントサイド環境変数（NEXT_PUBLIC_ プレフィックス）
const clientSchema = z.object({
  NEXT_PUBLIC_APP_URL: z.string().url('NEXT_PUBLIC_APP_URL must be a valid URL'),
  NEXT_PUBLIC_SUPABASE_URL: z.string().url('NEXT_PUBLIC_SUPABASE_URL must be a valid URL'),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1, 'NEXT_PUBLIC_SUPABASE_ANON_KEY is required'),
})

// サーバーサイドでのみバリデーション実行
const serverEnv = () => {
  const parsed = serverSchema.safeParse(process.env)
  if (!parsed.success) {
    console.error('❌ Invalid server environment variables:')
    console.error(parsed.error.flatten().fieldErrors)
    throw new Error('Invalid server environment variables')
  }
  return parsed.data
}

// クライアントサイド環境変数のバリデーション
const clientEnv = () => {
  const parsed = clientSchema.safeParse({
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  })
  if (!parsed.success) {
    console.error('❌ Invalid client environment variables:')
    console.error(parsed.error.flatten().fieldErrors)
    throw new Error('Invalid client environment variables')
  }
  return parsed.data
}

export const env = {
  server: serverEnv(),
  client: clientEnv(),
}
```

### 3. 使い方

```typescript
// サーバーサイドコード
import { env } from '@/env'

const supabase = createClient(
  env.client.NEXT_PUBLIC_SUPABASE_URL,
  env.server.SUPABASE_SERVICE_ROLE_KEY,
)

// クライアントサイドコード
import { env } from '@/env'

const apiUrl = env.client.NEXT_PUBLIC_APP_URL
```

## .env.example との連携

`src/env.ts` のスキーマと `.env.example` の内容を一致させる:

```bash
# .env.example
# === Server ===
NODE_ENV=development
SUPABASE_SERVICE_ROLE_KEY=  # Supabase Dashboard > Settings > API
SENTRY_DSN=                 # https://xxx@sentry.io/xxx (optional)

# === Client (NEXT_PUBLIC_) ===
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_SUPABASE_URL=   # Supabase Dashboard > Settings > API
NEXT_PUBLIC_SUPABASE_ANON_KEY= # Supabase Dashboard > Settings > API
```

## 追加パターン

### 環境ごとのデフォルト値

```typescript
const schema = z.object({
  PORT: z.coerce.number().default(3000),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  RATE_LIMIT_MAX: z.coerce.number().default(100),
})
```

### URL バリデーション

```typescript
const schema = z.object({
  DATABASE_URL: z.string().url().startsWith('postgresql://'),
  REDIS_URL: z.string().url().startsWith('redis://').optional(),
})
```

### 相互依存バリデーション

```typescript
const schema = z.object({
  STRIPE_SECRET_KEY: z.string().optional(),
  STRIPE_WEBHOOK_SECRET: z.string().optional(),
}).refine(
  (data) => {
    if (data.STRIPE_SECRET_KEY && !data.STRIPE_WEBHOOK_SECRET) return false
    return true
  },
  { message: 'STRIPE_WEBHOOK_SECRET is required when STRIPE_SECRET_KEY is set' }
)
```

## エラー出力例

```
❌ Invalid server environment variables:
{
  SUPABASE_SERVICE_ROLE_KEY: ['SUPABASE_SERVICE_ROLE_KEY is required'],
}

Error: Invalid server environment variables
    at serverEnv (src/env.ts:18:11)
```

起動時に即座にエラーが出るため、デプロイ後に環境変数の不足に気づくリスクを排除できる。
