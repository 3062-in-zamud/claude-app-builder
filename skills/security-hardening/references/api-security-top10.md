# OWASP API Security Top 10 チェックリスト

## API1:2023 - Broken Object Level Authorization (BOLA)

**リスク**: 他ユーザーのリソースに不正アクセスされる

### チェックリスト
- [ ] 全 API エンドポイントでリソースの所有者検証を実施
- [ ] URL パラメータの ID を検証（`/api/posts/:id` → `post.userId === currentUser.id`）
- [ ] RLS が有効で、ユーザーごとのアクセス制御が機能している

### 確認方法
```bash
# 全 API ルートを列挙
find src/app/api -name "route.ts" -o -name "route.js"

# 各ルートで auth チェックと所有者検証があるか確認
grep -rn "auth\|user_id\|userId\|owner" src/app/api/
```

### 修正パターン
```typescript
// NG: 所有者チェックなし
export async function GET(req: Request, { params }: { params: { id: string } }) {
  const post = await supabase.from('posts').select().eq('id', params.id).single()
  return Response.json(post.data)
}

// OK: RLS + アプリケーション層の二重チェック
export async function GET(req: Request, { params }: { params: { id: string } }) {
  const user = await getAuthUser(req)
  if (!user) return createProblemResponse(Problems.unauthorized())

  // RLS が user_id = auth.uid() を強制するため、他人のデータは取得不可
  const { data, error } = await supabase
    .from('posts')
    .select()
    .eq('id', params.id)
    .single()

  if (error || !data) return createProblemResponse(Problems.notFound('Post'))
  return Response.json(data)
}
```

## API2:2023 - Broken Authentication

**リスク**: 認証の不備により不正アクセスされる

### チェックリスト
- [ ] 全ての保護されたエンドポイントで認証トークンを検証
- [ ] トークンの有効期限チェック
- [ ] パスワードリセットフローのセキュリティ
- [ ] ブルートフォース対策（Rate Limiting）

### 修正パターン
```typescript
// 認証ヘルパー（全 API で共通使用）
async function getAuthUser(request: Request) {
  const supabase = createServerClient()
  const { data: { user }, error } = await supabase.auth.getUser()
  if (error || !user) return null
  return user
}
```

## API3:2023 - Broken Object Property Level Authorization

**リスク**: レスポンスに不要な情報が含まれる / 入力で不正なフィールドが更新される

### チェックリスト
- [ ] レスポンスに不要なフィールド（internal_id, password_hash 等）が含まれていない
- [ ] 更新 API で許可するフィールドをホワイトリストで制限
- [ ] Zod スキーマで入出力を制御

### 修正パターン
```typescript
// 出力スキーマで制御
const PostResponseSchema = z.object({
  id: z.string(),
  title: z.string(),
  body: z.string(),
  createdAt: z.string(),
  // internal_id, user_id 等は含めない
})

// 入力スキーマで制御（mass assignment 防止）
const UpdatePostSchema = z.object({
  title: z.string().optional(),
  body: z.string().optional(),
  // user_id, created_at 等は更新不可
})
```

## API4:2023 - Unrestricted Resource Consumption

**リスク**: リソース枯渇攻撃（Rate Limiting 不足）

### チェックリスト
- [ ] 全 API エンドポイントに Rate Limiting を設定
- [ ] ファイルアップロードにサイズ制限
- [ ] ページネーションに上限設定
- [ ] リクエストボディサイズに制限

### 修正パターン
```typescript
// Rate Limiting（Vercel Edge Config or Upstash Redis）
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'), // 10リクエスト/10秒
})

export async function POST(request: Request) {
  const ip = request.headers.get('x-forwarded-for') ?? 'unknown'
  const { success } = await ratelimit.limit(ip)
  if (!success) return createProblemResponse(Problems.rateLimit())
  // ...
}

// ページネーション上限
const MAX_PAGE_SIZE = 100
const pageSize = Math.min(parseInt(params.limit) || 20, MAX_PAGE_SIZE)
```

## API5:2023 - Broken Function Level Authorization

**リスク**: 管理者 API への不正アクセス

### チェックリスト
- [ ] 管理者エンドポイントに役割ベースのアクセス制御
- [ ] HTTPメソッドごとの権限チェック（GET は許可、DELETE は管理者のみ等）
- [ ] API ルートの命名規則で管理者パスを明確化（`/api/admin/*`）

### 修正パターン
```typescript
// ロールベースアクセス制御
async function requireRole(request: Request, role: 'admin' | 'user') {
  const user = await getAuthUser(request)
  if (!user) return err(Problems.unauthorized())

  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single()

  if (profile?.role !== role) return err(Problems.forbidden())
  return ok(user)
}
```

## API6:2023 - Unrestricted Access to Sensitive Business Flows

**リスク**: 重要なビジネスフローの自動化悪用

### チェックリスト
- [ ] アカウント作成に CAPTCHA またはメール認証
- [ ] 重要操作に二段階確認（例: 削除前の確認メール）
- [ ] スクレイピング対策

## API7:2023 - Server Side Request Forgery (SSRF)

**リスク**: サーバーが内部ネットワークに不正リクエスト

### チェックリスト
- [ ] ユーザー入力の URL を外部リクエストに使用していないか
- [ ] URL のホワイトリスト検証
- [ ] プライベート IP への接続ブロック

### 修正パターン
```typescript
// URL バリデーション
function isAllowedUrl(url: string): boolean {
  try {
    const parsed = new URL(url)
    // プライベート IP をブロック
    const hostname = parsed.hostname
    if (hostname === 'localhost' || hostname.startsWith('127.') ||
        hostname.startsWith('10.') || hostname.startsWith('192.168.')) {
      return false
    }
    // プロトコル制限
    if (!['http:', 'https:'].includes(parsed.protocol)) return false
    return true
  } catch {
    return false
  }
}
```

## API8:2023 - Security Misconfiguration

**リスク**: セキュリティ設定の不備

### チェックリスト
- [ ] CORS が適切に設定されている（`*` は使わない）
- [ ] セキュリティヘッダーが設定されている（CSP, HSTS 等）
- [ ] エラーメッセージにスタックトレースが含まれていない
- [ ] 不要な HTTP メソッドが無効化されている
- [ ] デバッグモードが本番で無効化されている

## API9:2023 - Improper Inventory Management

**リスク**: 未使用・古い API エンドポイントの放置

### チェックリスト
- [ ] 全 API エンドポイントが文書化されている
- [ ] 未使用のエンドポイントが削除されている
- [ ] API バージョニングが適切に管理されている
- [ ] テスト用エンドポイントが本番に含まれていない

## API10:2023 - Unsafe Consumption of APIs

**リスク**: サードパーティ API の安全でない使用

### チェックリスト
- [ ] サードパーティ API のレスポンスを検証している
- [ ] API キーが安全に管理されている（環境変数）
- [ ] サードパーティ API のエラーを適切にハンドリング
- [ ] タイムアウトが設定されている

### 修正パターン
```typescript
// サードパーティ API 呼び出しの安全なパターン
async function callExternalAPI(url: string) {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 5000) // 5秒タイムアウト

  try {
    const response = await fetch(url, {
      signal: controller.signal,
      headers: { 'Authorization': `Bearer ${process.env.EXTERNAL_API_KEY}` },
    })

    if (!response.ok) {
      throw new Error(`External API error: ${response.status}`)
    }

    // レスポンスを Zod で検証
    const data = await response.json()
    return ExternalResponseSchema.parse(data)
  } catch (error) {
    // 外部 API のエラーをアプリ内エラーに変換
    throw new AppError('EXTERNAL_API_ERROR', 'External service unavailable', 502)
  } finally {
    clearTimeout(timeout)
  }
}
```

## 総合チェックコマンド

```bash
# API ルート一覧と認証チェック
echo "=== API Routes ==="
find src/app/api -name "route.ts" | while read f; do
  echo "\n--- $f ---"
  grep -n "auth\|getUser\|getSession" "$f" || echo "WARNING: No auth check found!"
done

# CORS 設定確認
grep -rn "Access-Control\|cors" src/ next.config.*

# 環境変数の直接使用確認
grep -rn "process.env" src/ --include="*.tsx" --include="*.ts" | grep -v "NEXT_PUBLIC"
```
