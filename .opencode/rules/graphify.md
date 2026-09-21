# graphify Rules

> From `AGENTS.md` → "graphify" section. Governs use of the project knowledge graph at `graphify-out/`.

## When the user types `/graphify`

- Use the installed graphify skill/instructions **before doing anything else** (skills live under `.opencode/skills/graphify/`).

## Query rules (codebase questions)

- When `graphify-out/graph.json` exists, **first** run `graphify query "<question>"` instead of raw grep/source browsing.
- Use `graphify path "<A>" "<B>"` for relationships between files/concepts.
- Use `graphify explain "<concept>"` for a focused concept.
- Prefer `graphify-out/wiki/index.md` (if present) for broad navigation, and `graphify-out/GRAPH_REPORT.md` only for broad architecture review or when the tools above don't surface enough.

## When NOT to skip the graph

- **Dirty `graphify-out/` files are expected** after hooks or incremental updates — dirty graph files are not a reason to skip graphify.
- Only skip graphify if: the task concerns stale/incorrect graph output itself, or the user explicitly says not to use it.

## After modifying code

- Run `graphify update .` to keep the graph current — it's AST-only and has **no API cost**.
- Markdown/`.opencode/` docs and rules changes are not code and don't require an update.

## References

- graphify skill docs: `.opencode/skills/graphify/SKILL.md` and `references/` (query, update, hooks, exports).