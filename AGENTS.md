# DynamicTrading — Agent Repository Instructions

## Mandatory no-new-branches policy (user direction 2026-10-20)

**NEVER CREATE A NEW GIT BRANCH**, including implementation, PR, temporary merge, docs, Codex workspace or testing branches. This user rule applies across DynamicTrading, ProjectHoomans and PsychopatzCore. Do not use `git checkout -b`, `git switch -c`, automatic PR branch creation, branch-building worktrees or another branch as a "safe" workaround.

Use the existing `main` branch for authorized new DT changes after inspecting local/remote HEAD, upstream, worktree and other agents' modifications. Preserve changes; never blind pull, force-push, reset/discard/stash or rebase uncertain work. Hoomans has an already-existing divergent PR #4/goal branch; review and integrate to existing Hoomans main only after safe source/merge-tree, dependency and regression checks, without creating any new branch or losing history.

Core NPC Foundation P1–P9 is recorded developer-accepted using source-backed Lua harness tests, not live Project Zomboid SP/MP. The separate ProjectHoomans grounded personal-dialogue/backstory/Knowledge/Dossier B0–B6 goal remains open. Preserve Core actor/personal inventory versus DT merchant stock/budget ownership and do not claim PZ or Workshop acceptance.
