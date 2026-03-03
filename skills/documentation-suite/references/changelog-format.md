# Changelog 標準化（Keep a Changelog 形式）

## 概要

[Keep a Changelog](https://keepachangelog.com/) 形式に従い、
人間が読みやすい変更履歴を維持する。

## フォーマット

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 新機能の説明

### Changed
- 既存機能の変更

### Deprecated
- 非推奨になった機能

### Removed
- 削除された機能

### Fixed
- バグ修正

### Security
- セキュリティに関する修正

## [1.0.0] - 2024-01-15

### Added
- 初期リリース
- ユーザー認証機能
- ダッシュボード

## [0.1.0] - 2024-01-01

### Added
- プロジェクト初期化
- 基本的なプロジェクト構造
```

## カテゴリの定義

| カテゴリ | 用途 | Semantic Version |
|----------|------|-----------------|
| Added | 新機能 | MINOR |
| Changed | 既存機能の変更 | MINOR or PATCH |
| Deprecated | 非推奨化 | MINOR |
| Removed | 機能削除 | MAJOR |
| Fixed | バグ修正 | PATCH |
| Security | セキュリティ修正 | PATCH |

## ルール

1. **Unreleased セクションを常に先頭に置く**: 次のリリースに含まれる変更を蓄積
2. **日付はISO形式**: `YYYY-MM-DD`
3. **新しいバージョンが上**: 降順で記載
4. **各変更に1行**: 簡潔に記載し、詳細は PR/Issue にリンク
5. **ユーザー視点で記述**: 内部実装の詳細ではなく、ユーザーへの影響を記載

## Conventional Commits との連携

Conventional Commits を使用している場合、自動生成が可能:

| Commit Prefix | Changelog カテゴリ |
|--------------|-------------------|
| `feat:` | Added |
| `fix:` | Fixed |
| `docs:` | （通常は記載しない） |
| `refactor:` | Changed |
| `perf:` | Changed |
| `BREAKING CHANGE:` | Changed / Removed |

## 自動生成ツール

- **release-please**: Google 提供。Conventional Commits から自動生成
- **standard-version**: npm パッケージ。ローカルで CHANGELOG を更新
- **auto-changelog**: git ログから自動生成

## 記載例

```markdown
### Added
- ダークモード対応 (#42)
- CSV エクスポート機能 (#38)

### Fixed
- ログイン後のリダイレクトが正しく動作しない問題を修正 (#45)
- モバイルでのメニュー表示崩れを修正 (#43)

### Security
- 依存パッケージの脆弱性を修正（npm audit fix）
```
