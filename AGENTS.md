# DynamicTrading — Agent Repository Instructions

## Repository instruction-file hygiene

`AGENTS.md` contains durable repository-wide policy only.

- Never store the active goal, current phase, Next Chunk, implementation progress, accepted/completed phase history, migration status, or superseded goal instructions here.
- Goal-specific state belongs in the relevant `Docs/` roadmap/progress/runbook/architecture documents.
- Remove obsolete policy instead of retaining large `HISTORICAL` or `SUPERSEDED` sections; Git history is the archive.
- Keep executable `/goal` prompts conversational unless the user explicitly requests a checked-in prompt.

## Git and concurrent-work policy

- Never create a new Git branch for DynamicTrading work. This standing user rule also applies when coordinating ProjectHoomans and PsychopatzCore.
- Use existing `main` for authorized work only after checking the actual local branch/HEAD, upstream/remote state, dirty worktree, worktrees, and concurrent edits.
- Preserve unrelated work. Never use blind `git pull`, force-push, destructive reset/rebase, automatic stash/discard, or conflict resolution that overwrites uncertain changes.
- Remote GitHub state does not prove the user's local checkout is clean.
- If safe integration cannot be proven, report the concrete conflict instead of creating another branch or discarding work.

## Cross-system ownership

- DynamicTrading owns merchant/trader stock, budgets, quotes, and trade authority.
- PsychopatzCore actor personal inventory is a separate ownership boundary. Do not merge merchant stock/budget state into actor personal inventory merely because both concern items.
- Reuse public Core/Hoomans contracts where they exist rather than duplicating their state or gameplay authority.

## Native runtime and publication authority

- A Git commit or push is not Steam Workshop publication.
- Do not publish Workshop content or drive native Project Zomboid unless the user explicitly authorizes that action.
- If native SP/MP validation is user-owned, finish all developer-side implementation, harness, and regression work before handing off the live test.
