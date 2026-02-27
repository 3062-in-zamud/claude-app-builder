---
name: security-hardening
description: |
  What: AI生成コード特有の脆弱性を検査・修正する（セキュリティ強化フェーズ）
  When: Phase 5（実装完了）直後。**必須・スキップ不可**
  How: CRITICAL → HIGH の順にチェック → 問題があれば修正してから次フェーズへ
model: claude-opus-4-6
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# security-hardening: AI生成コード セキュリティ強化

## ⚠️ 重要

このフェーズは **CRITICAL 問題がある場合、Phase 6 に進めません**。すべての CRITICAL 問題を解消してから次へ進んでください。

## ワークフロー

### Step 1: 自動スキャン実行

```bash
bash skills/security-hardening/scripts/security-check.sh
```

### Step 2: CRITICAL チェック（手動確認）

以下を `references/` ドキュメントを参照しながら確認:

#### 2.1 IDOR（Insecure Direct Object Reference）

```typescript
// ❌ NG: パラメータの owner 確認なし
app.get('/api/posts/:id', async (req) => {
  return db.posts.find(req.params.id) // 誰でも取得できる！
})

// ✅ OK: 認証ユーザーとの照合
app.get('/api/posts/:id', authenticate, async (req) => {
  const post = await db.posts.find(req.params.id)
  if (post.userId !== req.user.id) {
    throw new ForbiddenError()
  }
  return post
})
```

全 API エンドポイントで `current_user.id === resource.owner_id` が確認されているかチェック。

#### 2.2 Supabase RLS

```sql
-- 全テーブルの RLS 有効化を確認
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = false;
-- 結果が空であること（すべてのテーブルで RLS が有効）
```

`references/supabase-rls-checklist.md` を参照。

#### 2.3 Service Role Key の漏洩

```bash
# フロントエンド（クライアントサイド）に service_role_key が存在しないか確認
grep -r "SUPABASE_SERVICE_ROLE_KEY" src/ --include="*.tsx" --include="*.ts" \
  | grep -v "^src/app/api/"  # API routes は OK
```

#### 2.4 シークレット漏洩（Git 全履歴）

```bash
trufflehog git file://. --json --fail
```

#### 2.5 認証バイパス

未認証でアクセスできる API エンドポイントがないか確認。

### Step 3: HIGH チェック

#### 3.1 CSRF 保護

- POST/PUT/DELETE に CSRF token があるか
- または SameSite=Strict Cookie を使用しているか

#### 3.2 JWT 格納場所

```javascript
// ❌ NG: localStorage（XSS で盗まれる）
localStorage.setItem('token', jwt)

// ✅ OK: httpOnly Cookie（XSS で盗まれない）
// サーバー側で Set-Cookie: token=...; HttpOnly; Secure; SameSite=Strict
```

#### 3.3 Rate Limiting

ログイン・API エンドポイントに制限があるか確認。

#### 3.4 エラーメッセージ

本番環境でスタックトレースが露出しないか確認。

#### 3.5 入力バリデーション

Zod スキーマでフロント+バックエンド両方で検証しているか確認。

#### 3.6 Prompt Injection（AI 機能がある場合）

ユーザー入力がプロンプトに直接結合されていないか確認。

### Step 4: npm audit

```bash
npm audit --audit-level=high
```

HIGH 以上の脆弱性がある場合は `npm audit fix` または手動対応。

### Step 5: チェック結果レポート出力

```
🔐 セキュリティチェック結果
━━━━━━━━━━━━━━━━━━━━━━━━━━

CRITICAL:
  ✅ IDOR 確認完了
  ✅ Supabase RLS 全テーブル有効
  ✅ Service Role Key 漏洩なし
  ✅ シークレット漏洩なし
  ✅ 認証バイパスなし

HIGH:
  ✅ CSRF 保護あり
  ✅ JWT は httpOnly Cookie
  ✅ Rate Limiting 設定済み
  ✅ エラーメッセージ安全
  ✅ 入力バリデーション実装済み

npm audit:
  ✅ HIGH 以上の脆弱性なし

━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ セキュリティチェック完了。Phase 6 に進みます。
```

### 品質チェック（全 CRITICAL が ✅ であること必須）

- [ ] IDOR: 全 API で所有者確認あり
- [ ] Supabase RLS: 全テーブルで有効
- [ ] Service Role Key がクライアント側に露出していない
- [ ] シークレット漏洩スキャン完了（TruffleHog）
- [ ] 認証バイパスのある API がない
- [ ] CSRF 保護あり
- [ ] JWT が httpOnly cookie に格納
- [ ] Rate Limiting 設定済み
- [ ] エラーメッセージにスタックトレースなし
- [ ] 入力バリデーション実装済み（Zod）
- [ ] npm audit で HIGH 以上なし
