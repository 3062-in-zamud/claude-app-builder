# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Version unified to 0.1.0 across all files (`ec7b036`)
- Added MIT LICENSE
- Corrected skill count and step numbering in documentation

## [0.2.0] - 2026-03-05

### Added
- Provider consistency audit script (`scripts/audit-plugin-consistency.py`)
- GitHub Actions workflow for plugin consistency checks (`.github/workflows/plugin-consistency.yml`)

### Changed
- Core pipeline now enforces a provider contract centered on `deployment_provider`
- Cloudflare Pages deployment path is first-class in core orchestration, deployment, monitoring, and release gates
- Discovery/growth/operations/compliance templates aligned to provider-aware wording

### Breaking
- `docs/tech-stack.md` must define `deployment_provider`
- When `deployment_provider=cloudflare-pages`, `cloudflare_pages_project`, `cloudflare_build_command`, and `cloudflare_build_dir` are mandatory

## [0.1.0] - 2026-03-05

### Added
- Provider contract enforcement in app-builder pipeline (`419fa27`)
- Baseline release establishing semver starting point

### Changed
- Growth and compliance playbooks aligned to provider model

## [0.0.6] - 2026-03-03 (dev: v3.0)

### Added
- 14 new business-critical skills for Stage D-F (Alpha Monetization, Beta Growth, GA Scale)
  - Stage D: `pricing-strategy`, `payment-integration`, `onboarding-optimizer`, `email-strategy`
  - Stage E: `ab-testing`, `conversion-funnel`, `gdpr-compliance`, `data-deletion`, `retention-strategy`
  - Stage F: `incident-response`, `scaling-strategy`, `cost-optimization`
  - Orchestrator: `growth-engine`
- 14 corresponding command wrappers in `commands/`
- 67 reference documents covering AARRR metrics, Mom Test, JTBD, Porter's Five Forces, OWASP API Top 10, and more
- `cookie-consent` skill for consent management

### Changed
- All 21 existing skills redesigned with 6-stage pipeline (Discovery -> Design & Build -> MVP Launch -> Alpha Monetization -> Beta Growth -> GA Scale)
- 5 quantitative quality gates introduced between stages
- Stage-specific workflows, quality standards, and gate criteria added to each skill

## [0.0.5] - 2026-03-02 (dev: v2.2)

### Added
- Persona-driven design system in `visual-designer`
- 5-axis evaluation framework for quality assessment
- WebSearch trend scanning integration in `market-research`

### Changed
- Enhanced design workflows with user persona alignment

## [0.0.4] - 2026-03-02

### Added
- Self-hosted marketplace support via GitHub repository direct install
- `install.sh` for one-command installation (`curl | bash`)
- `update.sh` for seamless updates
- `uninstall.sh` for clean removal
- Manifest-based skill/command tracking (`~/.claude/.claude-app-builder/`)

## [0.0.3] - 2026-02-28 (dev: v2.1)

### Added
- `security-hardening` skill for AI-generated code vulnerability auditing
- `release-checklist` skill with 36-item pre-deployment quality gate
- 16 quality enhancement files across existing skills

### Changed
- Phase A-D workflow improvements

## [0.0.2] - 2026-02-27 (dev: v2.0)

### Added
- 29-item quality enhancement and skill expansion plan
- Improved skill documentation structure

### Changed
- Refinement of existing skill workflows based on initial feedback

## [0.0.1] - 2026-02-27 (dev: v1.0)

### Added
- Initial release of Claude App Builder plugin
- Core skills: `idea-to-spec`, `brand-foundation`, `stack-selector`, `visual-designer`, `landing-page-builder`, `project-scaffold`, `implementation`, `deploy-setup`
- Supporting skills: `market-research`, `user-research`, `analytics-events`, `ci-setup`, `documentation-suite`, `feedback-loop`, `github-repo-setup`, `legal-docs-generator`, `monitoring-setup`, `seo-setup`
- Command wrappers for all skills
- `app-builder` orchestrator for end-to-end MVP automation

[Unreleased]: https://github.com/3062-in-zamud/claude-app-builder/compare/ec7b036...HEAD
[0.2.0]: https://github.com/3062-in-zamud/claude-app-builder/compare/419fa27...0f9ee62
[0.1.0]: https://github.com/3062-in-zamud/claude-app-builder/compare/e0a5c3a...419fa27
[0.0.6]: https://github.com/3062-in-zamud/claude-app-builder/compare/fa8b00c...e0a5c3a
[0.0.5]: https://github.com/3062-in-zamud/claude-app-builder/compare/4180b9b...fa8b00c
[0.0.4]: https://github.com/3062-in-zamud/claude-app-builder/compare/46abab0...4180b9b
[0.0.3]: https://github.com/3062-in-zamud/claude-app-builder/compare/6cd2eef...46abab0
[0.0.2]: https://github.com/3062-in-zamud/claude-app-builder/compare/578d6e8...6cd2eef
[0.0.1]: https://github.com/3062-in-zamud/claude-app-builder/commits/578d6e8
