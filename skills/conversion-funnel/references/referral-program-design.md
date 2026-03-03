# 紹介プログラム設計ガイド

## インセンティブ設計

**双方向報酬が最も効果的**（紹介者と被紹介者の両方にメリット）

| パターン | 紹介者 | 被紹介者 | 効果 |
|---------|--------|---------|------|
| 双方向クレジット | 1ヶ月無料 | 1ヶ月無料 | ✅ 最も効果的 |
| 片方向クレジット | 1ヶ月無料 | なし | △ 中程度 |
| 機能アンロック | Pro機能30日 | Pro機能14日 | ✅ 高い |
| 現金報酬 | $10クレジット | $5クレジット | ✅ 高い（コスト注意） |

## 紹介コード DB 設計

```sql
CREATE TABLE referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID NOT NULL REFERENCES auth.users(id),
  referral_code TEXT UNIQUE NOT NULL,
  referred_id UUID REFERENCES auth.users(id),
  status TEXT DEFAULT 'pending', -- pending, completed, rewarded
  created_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_referrals_code ON referrals(referral_code);
CREATE INDEX idx_referrals_referrer ON referrals(referrer_id);

ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own referrals" ON referrals
  FOR SELECT USING (auth.uid() = referrer_id);
```

## 紹介リンク生成

```typescript
// 紹介コード生成（ユーザーIDベース）
function generateReferralCode(userId: string): string {
  return `ref_${userId.slice(0, 8)}`;
}

// 紹介リンク
const referralUrl = `${baseUrl}/signup?ref=${referralCode}`;
```

## 不正防止

- [ ] 同一IPアドレスからの複数登録を検出
- [ ] 使い捨てメールアドレス（temp-mail等）をブロック
- [ ] 自己紹介（referrer_id === referred_id）を防止
- [ ] 報酬付与前に被紹介者のアクティブ利用を確認（7日間利用等）

## 追跡と計測

```typescript
// 紹介経由サインアップ時
async function handleReferralSignup(referralCode: string, newUserId: string) {
  await supabase.from('referrals').update({
    referred_id: newUserId,
    status: 'completed',
    completed_at: new Date().toISOString(),
  }).eq('referral_code', referralCode);

  track('referral_completed', { referral_code: referralCode });
}
```
