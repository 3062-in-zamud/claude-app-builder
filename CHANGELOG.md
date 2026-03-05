# Changelog

All notable changes to this project are documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic Versioning.

## [Unreleased]

### Changed
- No unreleased entries yet.

## [0.2.0] - 2026-03-05

### Added
- Provider consistency audit script (`scripts/audit-plugin-consistency.py`).
- GitHub Actions workflow for plugin consistency checks (`.github/workflows/plugin-consistency.yml`).

### Changed
- Core pipeline now enforces a provider contract centered on `deployment_provider`.
- Cloudflare Pages deployment path is first-class in core orchestration, deployment, monitoring, and release gates.
- Discovery/growth/operations/compliance templates are aligned to provider-aware wording.

### Breaking
- `docs/tech-stack.md` must define `deployment_provider`.
- When `deployment_provider=cloudflare-pages`, `cloudflare_pages_project`, `cloudflare_build_command`, and `cloudflare_build_dir` are mandatory.

## [0.1.0] - 2026-03-05

### Added
- Baseline release before provider-contract and Cloudflare-first-class changes.
