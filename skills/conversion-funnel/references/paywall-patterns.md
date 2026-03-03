# ペイウォール UI パターン集

## 1. Hard Paywall（完全ブロック）

コンテンツ/機能を完全にブロック。有料のみアクセス可。

```tsx
function HardPaywall() {
  return (
    <div className="flex flex-col items-center p-8 bg-muted rounded-lg">
      <Lock className="w-12 h-12 mb-4 text-muted-foreground" />
      <h3 className="text-lg font-semibold mb-2">Pro限定機能</h3>
      <p className="text-muted-foreground mb-4">この機能はProプラン以上で利用できます</p>
      <Button asChild><a href="/pricing">アップグレード</a></Button>
    </div>
  );
}
```

**適切な場面**: 高付加価値機能、差別化が明確な場合

## 2. Soft Paywall（制限付き）

一部を無料で見せ、続きは有料。

```tsx
function SoftPaywall({ previewContent }: { previewContent: string }) {
  return (
    <div className="relative">
      <div className="prose">{previewContent}</div>
      <div className="absolute bottom-0 w-full h-32 bg-gradient-to-t from-white" />
      <div className="text-center py-4">
        <p>続きを読むにはProプランが必要です</p>
        <Button>アップグレード</Button>
      </div>
    </div>
  );
}
```

**適切な場面**: コンテンツ系サービス

## 3. Metered Paywall（使用量ベース）

月N回まで無料、超過で有料。

```tsx
function MeteredPaywall({ used, limit }: { used: number; limit: number }) {
  const remaining = limit - used;
  if (remaining > 0) return null;
  return (
    <div className="border rounded-lg p-4 bg-amber-50">
      <p>今月の無料枠（{limit}回）を使い切りました</p>
      <p className="text-sm text-muted-foreground">Proプランで無制限に</p>
      <Button className="mt-2">アップグレード</Button>
    </div>
  );
}
```

**適切な場面**: API/ツール系

## 4. Feature-gated（機能制限）

基本機能は無料、高度な機能は有料。

| 機能 | Free | Pro | Team |
|------|------|-----|------|
| 基本CRUD | ✅ | ✅ | ✅ |
| エクスポート | CSV | CSV+PDF | 全形式 |
| API | 100回/日 | 10,000回/日 | 無制限 |
| サポート | コミュニティ | メール | 優先 |

**適切な場面**: 段階的な価値提供が可能な場合

## 使用量カウント実装

```sql
-- Supabase: 月次使用量テーブル
CREATE TABLE usage_counts (
  user_id UUID REFERENCES auth.users(id),
  feature TEXT NOT NULL,
  month TEXT NOT NULL, -- '2025-03'
  count INT DEFAULT 0,
  PRIMARY KEY (user_id, feature, month)
);

-- カウント増加
UPDATE usage_counts
SET count = count + 1
WHERE user_id = $1 AND feature = $2 AND month = to_char(now(), 'YYYY-MM');
```
