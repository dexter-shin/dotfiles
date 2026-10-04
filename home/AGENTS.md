# global agent instructions

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.

<!-- hermes-jev-skills:lanes BEGIN (managed by install.py; delete this block or run install.py --uninstall to remove) -->
## Model lanes (Jev decides, checks first)

Finish with the smallest model and lowest effort that still gets it right. When delegating work to a subagent:

1. **Pick the lane** with `jev lane classify --task "<the work>"` and delegate to the agent it names: `jev-lane-small` (Haiku, low), `jev-lane-medium` (Sonnet, medium), `jev-lane-high` (Opus, medium), `jev-lane-escalate` (Opus, high). Take the lowest sufficient lane. `keep_current` means do it yourself or ask the person. Skip classifying for trivia you can do in one step yourself.
2. **Check deterministically first** after each cycle: tests, compiler, type checker, linter, `git diff`. Never ask Jev (or yourself) what the toolchain can answer. `jev lane step --task "..." --lane <lane> --attempt <n> --run "<test cmd>" --scope "<path glob>"` runs them and returns continue / retry / verify / escalate / complete.
3. **Escalate one lane at a time, only on evidence**: the same lane failed twice, checks keep failing, security-sensitive code changed, design doubt remains, or Jev is unsure. Never just because a stronger model exists.
4. **Complete only** when the behaviour is implemented, the checks pass, the diff matches the requested scope and nothing is unresolved. Report a failed check; never hide it.

Jev is a decision model only (key from `TYPESAFE_API_KEY` or `jev setup-key`; never print it). If Jev is unavailable the commands fall back to keeping the current model and verifying yourself.
<!-- hermes-jev-skills:lanes END -->
