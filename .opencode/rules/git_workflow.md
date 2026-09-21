# Git Workflow Rules

> From `AGENTS.md` → "Git workflow". Normative rules — follow every time.

## Branching

- **NEVER commit directly on `main`.** Every change (feature or bug fix) starts from a new branch off `main`.
- Branch naming:
  - `feature/[desc]` for new features — e.g. `feature/topic-search`, `feature/noto-sans-jp-font`.
  - `bug/[desc]` for bug fixes — e.g. `bug/progress-reset-overflow`.
- Keep branches scoped to one change; open a PR and merge to `main` (repo is PR-based — see previous PRs #3, #5).

## Before committing

- Run `flutter analyze` — must stay clean (default flutter_lints).
- Run `flutter test` — full suite must pass.
- **If `assets/topics.json` changed:** run `flutter test test/data/content_repository_test.dart` first (enforces curriculum integrity: every `char` exists in `kanji.json`, every curated `reading` matches the dataset).
- After Dart/code changes, run `graphify update .` (AST-only, no API cost) so `graphify-out/` stays current.

## Hygiene

- Never `git add -A` blindly — the repo has large bundled font files under `assets/fonts/Noto_Sans_JP/` (incl. unused weights); stage only the files your change touches.
- Don't casually modify `assets/kanji.json` (read-only reference dataset).
- Push the branch and open a PR via the repo workflow (`gh` CLI is **not installed**; if GitHub MCP is unavailable, use curl with a PAT from `git credential fill`).

## References

- Deeper reasoning in `.opencode/docs/architecture.md`, `.opencode/docs/data_logic.md`, `.opencode/docs/testing.md`.