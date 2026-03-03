# ドリップキャンペーン テンプレート集

## 概要

ユーザーのサインアップからDay 14までの自動メールシーケンス。
各メールはトリガーベースで配信し、エンゲージメントに応じて分岐する。

---

## キャンペーン全体構成

```
Day 0:  Welcome メール（即時）
Day 1:  Quick Win ガイド
Day 2:  [条件分岐] アクティブ → 機能紹介 / 非アクティブ → 再エンゲージ
Day 3:  ユースケース紹介
Day 5:  [条件分岐] Aha到達 → Social Proof / 未到達 → ヘルプ提案
Day 7:  週間サマリー + Tips
Day 10: アップグレード案内（無料ユーザー向け）
Day 14: フィードバック依頼
```

---

## Day 0: Welcome メール

```markdown
Subject: Welcome to ${APP_NAME} - Let's get you started
Preview: Your account is ready. Here's what to do first.

---

Hi ${FIRST_NAME},

Welcome to ${APP_NAME}! We're excited to have you on board.

Here's how to get the most out of your first 5 minutes:

**1. ${FIRST_ACTION_TITLE}**
${FIRST_ACTION_DESCRIPTION}
[${FIRST_ACTION_CTA}](${FIRST_ACTION_URL})

**2. ${SECOND_ACTION_TITLE}**
${SECOND_ACTION_DESCRIPTION}

**3. ${THIRD_ACTION_TITLE}**
${THIRD_ACTION_DESCRIPTION}

Need help? Reply to this email or visit our [Help Center](${HELP_URL}).

Best,
${SENDER_NAME}
${APP_NAME} Team
```

### 設計ポイント

| 要素 | 推奨 |
|------|------|
| 配信タイミング | サインアップ直後（5分以内） |
| Subject 長さ | 40文字以内 |
| CTA 数 | 1つ（メイン）+ 補助リンク |
| トーン | 温かく、簡潔に |
| 目標 | 初回ログイン・最初のアクション |

---

## Day 1: Quick Win ガイド

```markdown
Subject: Your first quick win with ${APP_NAME}
Preview: Complete this in under 2 minutes and see the magic.

---

Hi ${FIRST_NAME},

Most ${APP_NAME} users who ${AHA_ACTION} in their first 24 hours
end up loving the product.

Here's how to do it in under 2 minutes:

**Step 1:** ${STEP_1}
**Step 2:** ${STEP_2}
**Step 3:** ${STEP_3}

[${CTA_TEXT}](${CTA_URL})

That's it! Once you've done this, you'll see why teams like
${SOCIAL_PROOF_COMPANY} rely on ${APP_NAME} every day.

Cheers,
${SENDER_NAME}
```

---

## Day 2: 条件分岐メール

### パターン A: アクティブユーザー向け（機能紹介）

```markdown
Subject: You're off to a great start! Try this next
Preview: Unlock the feature that power users love most.

---

Hi ${FIRST_NAME},

Great job on ${COMPLETED_ACTION}!

Now that you've got the basics down, here's a power feature
that'll save you hours every week:

**${FEATURE_NAME}**
${FEATURE_DESCRIPTION}

[Try ${FEATURE_NAME} now](${FEATURE_URL})

Pro tip: ${PRO_TIP}

${SENDER_NAME}
```

### パターン B: 非アクティブユーザー向け（再エンゲージ）

```markdown
Subject: Need a hand getting started?
Preview: Here's a 60-second walkthrough to help you hit the ground running.

---

Hi ${FIRST_NAME},

We noticed you haven't had a chance to explore ${APP_NAME} yet.
No worries - we've got you covered.

**Watch our 60-second quickstart:**
[Watch Video](${VIDEO_URL})

Or if you prefer, pick a template to get started instantly:

- [${TEMPLATE_1}](${TEMPLATE_1_URL})
- [${TEMPLATE_2}](${TEMPLATE_2_URL})
- [${TEMPLATE_3}](${TEMPLATE_3_URL})

Questions? Just hit reply - a real human will get back to you.

${SENDER_NAME}
```

---

## Day 3: ユースケース紹介

```markdown
Subject: How ${CUSTOMER_NAME} uses ${APP_NAME} to ${OUTCOME}
Preview: A real story from a team just like yours.

---

Hi ${FIRST_NAME},

Here's how ${CUSTOMER_NAME} (${CUSTOMER_ROLE} at ${CUSTOMER_COMPANY})
transformed their workflow with ${APP_NAME}:

**The Challenge:**
${CHALLENGE_DESCRIPTION}

**The Solution:**
${SOLUTION_DESCRIPTION}

**The Result:**
${RESULT_METRIC}

[Read the full story](${CASE_STUDY_URL})

Want to achieve similar results?
[${CTA_TEXT}](${CTA_URL})

${SENDER_NAME}
```

---

## Day 5: 条件分岐メール

### パターン A: Aha! Moment 到達済み（Social Proof）

```markdown
Subject: You're in great company
Preview: Join ${USER_COUNT}+ teams who made the switch.

---

Hi ${FIRST_NAME},

You've been making great progress with ${APP_NAME}!

Here's what our community looks like:

- ${USER_COUNT}+ teams trust ${APP_NAME}
- ${METRIC_1} (e.g., "2M+ tasks completed last month")
- ${METRIC_2} (e.g., "4.8/5 average rating on G2")

"${TESTIMONIAL_QUOTE}"
-- ${TESTIMONIAL_AUTHOR}, ${TESTIMONIAL_COMPANY}

[See what's new this month](${CHANGELOG_URL})

${SENDER_NAME}
```

### パターン B: Aha! Moment 未到達（ヘルプ提案）

```markdown
Subject: Can we help?
Preview: Our team is here for you - no question too small.

---

Hi ${FIRST_NAME},

Getting started with a new tool can feel overwhelming.
We're here to help.

**Choose what works best for you:**

- [Book a 15-min demo](${DEMO_URL}) - We'll walk you through everything
- [Browse templates](${TEMPLATES_URL}) - Start with a pre-built setup
- [Read the guide](${GUIDE_URL}) - Self-paced walkthrough
- Reply to this email - We'll answer any questions

We want to make sure ${APP_NAME} works for you.

${SENDER_NAME}
```

---

## Day 7: 週間サマリー + Tips

```markdown
Subject: Your week 1 recap + a tip from the pros
Preview: Here's what you accomplished and what to try next.

---

Hi ${FIRST_NAME},

Here's your first week with ${APP_NAME}:

**Your Stats:**
- ${STAT_1} (e.g., "5 projects created")
- ${STAT_2} (e.g., "12 tasks completed")
- ${STAT_3} (e.g., "2 team members invited")

**This Week's Pro Tip:**
${PRO_TIP_TITLE}

${PRO_TIP_DESCRIPTION}

[Try it now](${PRO_TIP_URL})

Keep up the great work!

${SENDER_NAME}
```

---

## Day 10: アップグレード案内

```markdown
Subject: Unlock more with ${APP_NAME} Pro
Preview: You're hitting the limits of the free plan. Here's what Pro offers.

---

Hi ${FIRST_NAME},

You've been getting great value from ${APP_NAME}!
Here's what you could do with Pro:

| Feature | Free | Pro |
|---------|------|-----|
| ${FEATURE_1} | ${FREE_LIMIT_1} | ${PRO_LIMIT_1} |
| ${FEATURE_2} | ${FREE_LIMIT_2} | ${PRO_LIMIT_2} |
| ${FEATURE_3} | ${FREE_LIMIT_3} | ${PRO_LIMIT_3} |
| ${FEATURE_4} | ${FREE_VALUE_4} | ${PRO_VALUE_4} |

**Special offer:** Get ${DISCOUNT}% off your first ${PERIOD}
with code **${PROMO_CODE}**.

[Upgrade to Pro](${UPGRADE_URL}?code=${PROMO_CODE})

${SENDER_NAME}

P.S. This offer expires in ${EXPIRY_DAYS} days.
```

---

## Day 14: フィードバック依頼

```markdown
Subject: Quick question (takes 30 seconds)
Preview: We'd love to hear your honest feedback.

---

Hi ${FIRST_NAME},

You've been using ${APP_NAME} for two weeks now.
We'd love your honest feedback:

**On a scale of 0-10, how likely are you to recommend
${APP_NAME} to a friend or colleague?**

[0](${NPS_URL}?score=0) [1] [2] [3] [4] [5] [6] [7] [8] [9] [10](${NPS_URL}?score=10)

That's it! One click and you're done.

Your feedback directly shapes our product roadmap.

Thanks,
${SENDER_NAME}
```

---

## React Email 実装例

```tsx
// emails/welcome.tsx
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Hr,
  Html,
  Img,
  Link,
  Preview,
  Section,
  Text,
} from "@react-email/components";

interface WelcomeEmailProps {
  firstName: string;
  appName: string;
  ctaUrl: string;
  ctaText: string;
  helpUrl: string;
}

export default function WelcomeEmail({
  firstName,
  appName,
  ctaUrl,
  ctaText,
  helpUrl,
}: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Your {appName} account is ready.</Preview>
      <Body style={main}>
        <Container style={container}>
          <Img
            src={`${process.env.NEXT_PUBLIC_APP_URL}/logo.png`}
            width="40"
            height="40"
            alt={appName}
          />

          <Heading style={h1}>Welcome to {appName}</Heading>

          <Text style={text}>Hi {firstName},</Text>
          <Text style={text}>
            Your account is ready. Get started by creating your
            first project.
          </Text>

          <Section style={buttonContainer}>
            <Button style={button} href={ctaUrl}>
              {ctaText}
            </Button>
          </Section>

          <Hr style={hr} />

          <Text style={footer}>
            Need help?{" "}
            <Link href={helpUrl} style={link}>
              Visit our Help Center
            </Link>
          </Text>
        </Container>
      </Body>
    </Html>
  );
}

const main = {
  backgroundColor: "#f6f9fc",
  fontFamily:
    '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
};

const container = {
  backgroundColor: "#ffffff",
  margin: "0 auto",
  padding: "40px 20px",
  maxWidth: "560px",
  borderRadius: "8px",
};

const h1 = {
  color: "#1a1a1a",
  fontSize: "24px",
  fontWeight: "bold" as const,
  margin: "24px 0 16px",
};

const text = {
  color: "#4a4a4a",
  fontSize: "16px",
  lineHeight: "24px",
  margin: "8px 0",
};

const buttonContainer = {
  textAlign: "center" as const,
  margin: "24px 0",
};

const button = {
  backgroundColor: "#2563eb",
  borderRadius: "6px",
  color: "#ffffff",
  fontSize: "16px",
  fontWeight: "bold" as const,
  textDecoration: "none",
  textAlign: "center" as const,
  display: "inline-block",
  padding: "12px 24px",
};

const hr = {
  borderColor: "#e6e6e6",
  margin: "24px 0",
};

const footer = {
  color: "#8c8c8c",
  fontSize: "14px",
};

const link = {
  color: "#2563eb",
  textDecoration: "underline",
};
```

### 送信処理（Resend）

```typescript
// lib/email/send-drip.ts
import { Resend } from "resend";
import WelcomeEmail from "@/emails/welcome";

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendWelcomeEmail(
  to: string,
  firstName: string
) {
  const { error } = await resend.emails.send({
    from: `${process.env.APP_NAME} <noreply@${process.env.EMAIL_DOMAIN}>`,
    to,
    subject: `Welcome to ${process.env.APP_NAME} - Let's get you started`,
    react: WelcomeEmail({
      firstName,
      appName: process.env.APP_NAME!,
      ctaUrl: `${process.env.NEXT_PUBLIC_APP_URL}/onboarding`,
      ctaText: "Get Started",
      helpUrl: `${process.env.NEXT_PUBLIC_APP_URL}/help`,
    }),
  });

  if (error) {
    console.error("Failed to send welcome email:", error);
    throw error;
  }
}
```

---

## 配信スケジュール管理

```typescript
// lib/email/drip-scheduler.ts

interface DripStep {
  id: string;
  delayDays: number;
  emailTemplate: string;
  condition?: (user: UserProfile) => boolean;
  variants?: {
    active: string;
    inactive: string;
  };
}

export const DRIP_SEQUENCE: DripStep[] = [
  {
    id: "day0_welcome",
    delayDays: 0,
    emailTemplate: "welcome",
  },
  {
    id: "day1_quickwin",
    delayDays: 1,
    emailTemplate: "quick-win",
  },
  {
    id: "day2_branch",
    delayDays: 2,
    emailTemplate: "feature-intro",
    variants: {
      active: "feature-intro",
      inactive: "re-engage",
    },
  },
  {
    id: "day3_usecase",
    delayDays: 3,
    emailTemplate: "use-case",
  },
  {
    id: "day5_branch",
    delayDays: 5,
    emailTemplate: "social-proof",
    variants: {
      active: "social-proof",
      inactive: "help-offer",
    },
  },
  {
    id: "day7_recap",
    delayDays: 7,
    emailTemplate: "weekly-recap",
  },
  {
    id: "day10_upgrade",
    delayDays: 10,
    emailTemplate: "upgrade-offer",
    condition: (user) => user.plan === "free",
  },
  {
    id: "day14_feedback",
    delayDays: 14,
    emailTemplate: "feedback-nps",
  },
];
```

---

## メトリクス計測

| メール | 目標 Open Rate | 目標 Click Rate | 目標 Conversion |
|--------|---------------|----------------|-----------------|
| Day 0 Welcome | > 60% | > 30% | 初回ログイン |
| Day 1 Quick Win | > 45% | > 20% | Aha! Moment |
| Day 2 Feature | > 40% | > 15% | 機能利用 |
| Day 3 Use Case | > 35% | > 10% | エンゲージメント |
| Day 5 Social | > 35% | > 10% | 継続利用 |
| Day 7 Recap | > 40% | > 15% | 週間アクティブ |
| Day 10 Upgrade | > 30% | > 8% | アップグレード |
| Day 14 NPS | > 35% | > 20% | NPS 回答 |
