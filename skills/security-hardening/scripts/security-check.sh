#!/bin/bash
# AI生成コードセキュリティスキャン
# 使用方法: bash skills/security-hardening/scripts/security-check.sh

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "🔐 AI生成コードセキュリティスキャン開始"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ===== CRITICAL チェック =====
echo "🚨 CRITICAL チェック:"

# 1. Service Role Key がフロントエンドに混入していないか
echo -n "  Service Role Key 漏洩チェック... "
if find src -name "*.tsx" -o -name "*.ts" 2>/dev/null | xargs grep -l "SUPABASE_SERVICE_ROLE_KEY" 2>/dev/null | grep -v "app/api/" | grep -v "lib/supabase-admin" | grep -q .; then
  echo -e "${RED}❌ FAIL${NC}"
  echo "     フロントエンドに SUPABASE_SERVICE_ROLE_KEY が見つかりました"
  echo "     API routes (/app/api/) 以外では anon key を使用してください"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ PASS${NC}"
fi

# 2. .env ファイルが Git に含まれていないか
echo -n "  .env ファイルのコミットチェック... "
if git log --all --oneline --diff-filter=A -- '.env' '*.env' 2>/dev/null | grep -q .; then
  echo -e "${RED}❌ FAIL${NC}"
  echo "     .env ファイルが Git 履歴に含まれています"
  echo "     git secrets --scan-history で詳細確認"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ PASS${NC}"
fi

# 3. .gitignore に .env が含まれているか
echo -n "  .gitignore 設定チェック... "
if [ -f ".gitignore" ] && grep -q "\.env" .gitignore; then
  echo -e "${GREEN}✅ PASS${NC}"
else
  echo -e "${RED}❌ FAIL${NC}"
  echo "     .gitignore に .env* が含まれていません"
  ERRORS=$((ERRORS + 1))
fi

# 4. TruffleHog スキャン（インストールされている場合）
echo -n "  TruffleHog シークレットスキャン... "
if command -v trufflehog >/dev/null 2>&1; then
  if trufflehog git file://. --only-verified --json 2>/dev/null | grep -q '"Verified":true'; then
    echo -e "${RED}❌ FAIL${NC}"
    echo "     検証済みシークレットが見つかりました！即座にローテーションしてください"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}✅ PASS${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  SKIP${NC} (trufflehog 未インストール: brew install trufflehog)"
  WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ===== HIGH チェック =====
echo "⚠️  HIGH チェック:"

# 5. localStorage で JWT を保存していないか
echo -n "  JWT 格納場所チェック... "
if find src -name "*.tsx" -o -name "*.ts" 2>/dev/null | xargs grep -l "localStorage.setItem.*token\|localStorage.setItem.*jwt\|localStorage.setItem.*auth" 2>/dev/null | grep -q .; then
  echo -e "${YELLOW}⚠️  WARNING${NC}"
  echo "     localStorage に JWT を格納している可能性があります"
  echo "     httpOnly Cookie の使用を推奨します"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}✅ PASS${NC}"
fi

# 6. TypeScript エラーチェック
echo -n "  TypeScript 型チェック... "
if command -v npx >/dev/null 2>&1 && [ -f "tsconfig.json" ]; then
  if npx tsc --noEmit 2>&1 | grep -q "error TS"; then
    echo -e "${YELLOW}⚠️  WARNING${NC}"
    echo "     TypeScript エラーがあります: npx tsc --noEmit で確認"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "${GREEN}✅ PASS${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  SKIP${NC} (TypeScript プロジェクトでない、または未初期化)"
fi

# 7. npm audit
echo -n "  npm audit (HIGH 以上)... "
if [ -f "package.json" ]; then
  AUDIT_RESULT=$(npm audit --audit-level=high 2>&1 || true)
  if echo "$AUDIT_RESULT" | grep -q "found [1-9]"; then
    echo -e "${YELLOW}⚠️  WARNING${NC}"
    echo "     HIGH 以上の脆弱性があります: npm audit --audit-level=high で確認"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "${GREEN}✅ PASS${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  SKIP${NC} (package.json なし)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ===== 結果サマリー =====
if [ $ERRORS -gt 0 ]; then
  echo -e "${RED}❌ スキャン失敗: $ERRORS 件の CRITICAL 問題があります${NC}"
  echo "   Phase 6 に進む前にすべての CRITICAL 問題を修正してください"
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo -e "${YELLOW}⚠️  スキャン完了: $WARNINGS 件の WARNING があります（Phase 6 進行可）${NC}"
  echo "   WARNING は可能な限り修正することを推奨します"
  exit 0
else
  echo -e "${GREEN}✅ セキュリティチェック完了！問題なし${NC}"
  echo "   Phase 6（デプロイ準備）に進みます"
  exit 0
fi
