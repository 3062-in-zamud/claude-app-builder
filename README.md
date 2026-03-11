# Claude App Builder

> Japanese version: [README.ja.md](README.ja.md)

> A Claude Code plugin that **fully automates the journey from 0 → MVP → $50K MRR**

> **Note**: Basic programming knowledge (code review, debugging) is assumed

## Installation

### Method 1: Script Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/3062-in-zamud/claude-app-builder/main/install.sh | bash
```

Or clone directly:

```bash
git clone https://github.com/3062-in-zamud/claude-app-builder ~/.claude-app-builder
bash ~/.claude-app-builder/install.sh
```

`/app-builder` will be available from the next Claude Code session.

## Initial Setup (Before Using the Plugin)

1. [Create a Supabase account](https://supabase.com) → `supabase login`
2. [Set up GitHub CLI](https://cli.github.com/) → `gh auth login`
3. Choose and log in to your deploy provider
   - For Vercel: [Create a Vercel account](https://vercel.com/signup) → `vercel login`
   - For Cloudflare Pages: [Create a Cloudflare account](https://dash.cloudflare.com/) → `wrangler login`

### Free Plan Limitations

| Service | Limitation | Recommended Plan for Commercial Use |
|---------|-----------|-------------------------------------|
| Vercel Hobby | **Commercial use prohibited** | Pro ($20/mo) |
| Cloudflare Pages Free | Generous free tier but feature/support limits | Consider Pro/Business |
| Supabase Free | 500MB DB, 2 projects, paused after 7 days inactive | Pro ($25/mo) |

### Method 2: Claude Code Plugin System (Recommended)

```bash
# Add the marketplace (first time only)
claude plugin marketplace add 3062-in-zamud/claude-app-builder

# Install the plugin
claude plugin install claude-app-builder@claude-app-builder
```

> **Note**: Official marketplace submission is under review (since 2025/2/27).
> The above commands use the GitHub repository as a self-hosted marketplace.

### Prerequisites

| Tool | Purpose | Installation |
|------|---------|-------------|
| [gh](https://cli.github.com/) | GitHub operations | `brew install gh` |
| [vercel](https://vercel.com/cli) | Deploy (when using Vercel) | `npm install -g vercel` |
| [wrangler](https://developers.cloudflare.com/workers/wrangler/install-and-update/) | Deploy (when using Cloudflare) | `npm install -g wrangler` |
| [supabase](https://supabase.com/docs/reference/cli) | Database management | `npm install -g supabase` |
| Node.js 18+ | Runtime | [nodejs.org](https://nodejs.org/) |

## Supported Deploy Providers (web-fullstack)

| Provider | Status | Notes |
|----------|--------|-------|
| `vercel` | ✅ Supported | Standard flow |
| `cloudflare-pages` | ✅ Supported (Phase 1) | Deploy layer only (DB/Auth uses Supabase) |

## Pipeline Overview (6 Stages, 5 Gates)

```
=== Stage A: Discovery (Phase 0–1) ===
  user-research → market-research → idea-to-spec + brand-foundation
  [G1: Requirements Approval]

=== Stage B: Design & Build (Phase 2–5.5) ===
  stack-selector + visual-designer → project-scaffold + github-repo-setup + ci-setup
  → documentation-suite + landing-page-builder + legal-docs-generator + seo-setup + cookie-consent
  → implementation + analytics-events → security-hardening
  [G2: Security Gate]

=== Stage C: MVP Launch (Phase 6–8) ===
  monitoring-setup + release-checklist → deploy-setup → feedback-loop
  [G3: MVP Quality Gate]

=== Stage D: Alpha → Monetization (Phase 9–10) ===
  pricing-strategy → payment-integration → onboarding-optimizer → email-strategy
  [G4: Alpha → Beta Decision]

=== Stage E: Beta → Growth (Phase 11–12) ===
  ab-testing + conversion-funnel → gdpr-compliance + data-deletion → retention-strategy
  [G5: Beta → GA Decision]

=== Stage F: GA & Scale (Phase 13–14) ===
  incident-response + scaling-strategy → cost-optimization
```

## Gate Criteria

| Gate | Key Criteria |
|------|-------------|
| G1 | User approves requirements.md + brand-brief.md |
| G2 | CRITICAL vulnerabilities = 0, npm audit HIGH = 0 |
| G3 | Health check OK, test coverage 80%+, Lighthouse P90+/A95+ |
| G4 | 10+ paid users, 7-day retention 20%+, Sentry error rate < 1% |
| G5 | MRR $1K+, 30-day retention 15%+, monthly churn < 10%, GDPR compliance complete |

## Usage

### 0 → MVP (Stage A–C)

```
/app-builder "A social network where users can track books they've read and write reviews"
```

```
/app-builder "An invoice management tool for freelancers"
```

`/app-builder` automatically runs from Stage A (Discovery) through Stage C (MVP Launch).
It sequentially invokes all skills from Phase 0–8, passing through gates G1–G3 to complete deployment.

### MVP → MRR Growth (Stage D–F)

```
/growth-engine
```

`/growth-engine` automatically runs the growth phases (Stage D–F) after MVP release.
It manages monetization, user acquisition, retention, and scaling with quality control through gates G4–G5.

### Invoke Individual Skills Directly

```
/idea-to-spec "A dashboard to visualize monthly household finances"
/brand-foundation
/landing-page-builder
/security-hardening
/deploy-setup
/pricing-strategy
/payment-integration
/ab-testing
/retention-strategy
/incident-response
/cost-optimization
```

## Skills List (33 + 2 Orchestrators)

| Skill | Phase | Model | Role |
|-------|-------|-------|------|
| `app-builder` | All (A–C) | **Opus** | Orchestrator (0 → MVP) |
| `growth-engine` | All (D–F) | **Opus** | Orchestrator (MVP → MRR Growth) |
| `user-research` | 0 | Sonnet | Persona, interview guide, hypothesis validation |
| `market-research` | 0.5 | Sonnet | Competitive analysis, market sizing |
| `idea-to-spec` | 1 | Sonnet | Idea → requirements.md |
| `brand-foundation` | 1 | **Opus** | Brand strategy |
| `stack-selector` | 2 | Sonnet | Technology stack selection |
| `visual-designer` | 2 | **Opus** | Design system (WCAG AA) |
| `project-scaffold` | 3 | Haiku | Next.js / CLI template generation |
| `github-repo-setup` | 3 | Sonnet | Branch Protection + Dependabot |
| `ci-setup` | 3 | Sonnet | GitHub Actions CI configuration |
| `documentation-suite` | 4 | Sonnet | README + ARCHITECTURE |
| `landing-page-builder` | 4 | Sonnet | Landing page + OGP + meta tags |
| `legal-docs-generator` | 4 | Sonnet | Privacy policy, terms of service |
| `seo-setup` | 4 | Sonnet | Sitemap, robots.txt, JSON-LD |
| `cookie-consent` | 4 | Haiku | Cookie consent banner, GDPR compliance |
| `implementation` | 5 | Sonnet | TDD implementation and testing |
| `analytics-events` | 5 | Sonnet | Event tracking design, provider-specific analytics |
| `security-hardening` | 5.5 | **Opus** | IDOR / RLS / secret scanning |
| `monitoring-setup` | 6 | Sonnet | Sentry + provider analytics + Lighthouse CI |
| `release-checklist` | 6 | Sonnet | Full checklist (CRITICAL items flagged) |
| `deploy-setup` | 7 | Sonnet | Provider-specific deploy (Vercel/Cloudflare Pages) + Supabase |
| `feedback-loop` | 8 | Sonnet | Feedback collection design |
| `pricing-strategy` | 9 | **Opus** | Pricing strategy, plan design |
| `payment-integration` | 9 | Sonnet | Stripe integration, subscriptions |
| `onboarding-optimizer` | 10 | **Opus** | Onboarding flow optimization |
| `email-strategy` | 10 | Sonnet | Email marketing (Resend / SendGrid) |
| `ab-testing` | 11 | Sonnet | A/B test design and implementation |
| `conversion-funnel` | 11 | **Opus** | Conversion funnel analysis and optimization |
| `gdpr-compliance` | 11.5 | **Opus** | Full GDPR compliance, DPA support |
| `data-deletion` | 11.5 | Sonnet | Data deletion pipeline, Right to Erasure |
| `retention-strategy` | 12 | **Opus** | Retention strategy, churn analysis |
| `incident-response` | 13 | Sonnet | Incident response, runbooks |
| `scaling-strategy` | 13 | Sonnet | Scaling strategy, performance planning |
| `cost-optimization` | 14 | Sonnet | Infrastructure cost optimization |

## MRR Growth Roadmap

| Phase | Target MRR | Timeline | Key Skills |
|-------|-----------|----------|-----------|
| Alpha (Stage D) | $0 → $1K | 0–3 months | pricing-strategy, payment-integration, onboarding-optimizer, email-strategy |
| Beta (Stage E) | $1K → $5K | 3–6 months | ab-testing, conversion-funnel, gdpr-compliance, data-deletion, retention-strategy |
| GA / Scale (Stage F) | $5K → $50K | 6–18 months | incident-response, scaling-strategy, cost-optimization |

## Security

The `security-hardening` skill inspects for vulnerabilities specific to AI-generated code (handled by Opus):

- **IDOR**: Owner verification on all APIs
- **Supabase RLS**: Verification that all tables have RLS enabled
- **Service Role Key**: Check for frontend exposure
- **Secret Leaks**: Full commit scan with TruffleHog
- **CSRF / JWT / Rate Limiting**: Security best practices verification

Deployment is blocked if CRITICAL issues are found.

Details: [SECURITY.md](SECURITY.md)

## Update

```bash
# If installed via plugin system
claude plugin update claude-app-builder

# If installed via script
bash ~/.claude-app-builder/update.sh
```

## Uninstall

```bash
# If installed via plugin system
claude plugin uninstall claude-app-builder

# If installed via script
bash ~/.claude-app-builder/uninstall.sh
```

## License

MIT
