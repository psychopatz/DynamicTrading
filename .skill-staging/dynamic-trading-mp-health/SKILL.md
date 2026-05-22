---
name: dynamic-trading-mp-health
description: Use when working on DynamicTrading DTNPC multiplayer health, incapacitation, revive, weakened-state, or death-lifecycle code. Trigger this skill for regressions where NPCs lose virtual HP or die from engine-side zombie health changes, spawn/attach races, engine_fallback damage, or corpse/final-death transitions.
---

# Dynamic Trading MP Health

## Overview

This skill preserves the critical DTNPC multiplayer rule:

- `combatHealth.current` is authoritative.
- `IsoZombie` engine HP is only a disposable transport buffer.
- Attacker-less engine HP changes are sync noise unless a trusted explicit hit path proves otherwise.

Use this skill before changing DTNPC health, revive, incapacitation, weakened recovery, or death-finalization code.

## Guardrails

- Never treat raw multiplayer zombie engine HP as the source of truth for DTNPC survival.
- Do not let spawn, body attach, AI activation, pathing resets, `NetworkZombieMind` churn, or local/remote ownership changes subtract from virtual HP.
- In MP, only trusted explicit damage paths should change virtual HP. Examples:
  - `client_weapon_hit_report`
  - `client_weapon_hit_report_dead_body`
  - `weapon_hit_event`
  - `zombie_lease`
  - `dt_npc_combat`
- If there is no credible attacker or trusted hit report, prefer restoring the engine buffer over applying fake damage.

## Stable Baseline

- Known stable commit for this subsystem: `1b9aaeba`
  - `feat: implement NPC colony alert system with flavor text and improve crawling locomotion state handling`
- If a new regression appears, diff the current health/lifecycle files against `1b9aaeba` first.

## Regression Pattern

If logs show a healthy NPC spawning with full custom HP and then dropping to `1` or `0` without a real hit:

- Suspect `engine_fallback` or another attacker-less engine delta path first.
- Suspect spawn-time race conditions before suspecting revive logic.
- Treat `customCurrent full -> 1` immediately after body attach as a virtual-health authority violation.

Typical bad sequence:

1. NPC spawns with correct `customCurrent`.
2. Live zombie attaches and AI/local control starts.
3. Engine HP changes on its own.
4. DT converts that delta into custom damage.
5. NPC enters incapacitated or dies for no valid combat reason.

## Workflow

1. Check whether the damage source is explicit or inferred.
   - Explicit damage is acceptable.
   - Inferred engine delta is not acceptable without proof.
2. Inspect `DTNPC_Lifecycle_DamageAuthority.lua` first.
   - This is the main boundary between fake engine HP and authoritative virtual HP.
3. Compare against `1b9aaeba` if engine fallback logic changed.
4. Verify final-death recovery does not treat stale `engine_fallback` as credible combat.
5. Verify logic guards do not force zero-HP transitions from bad replicated state.

## Files To Audit First

- `Contents/mods/DynamicTradingV2/42.16/media/lua/shared/DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/DTNPC_Lifecycle_DamageAuthority.lua`
- `Contents/mods/DynamicTradingV2/42.16/media/lua/shared/DT/V2/NPC/Sys/Health/DTNPC_Health_Damage.lua`
- `Contents/mods/DynamicTradingV2/42.16/media/lua/shared/DT/V2/NPC/Sys/Health/DTNPC_Health_Spawn.lua`
- `Contents/mods/DynamicTradingV2/42.16/media/lua/shared/DT/V2/NPC/Sys/Logic/DTNPC_Logic_Processing.lua`
- `Contents/mods/DynamicTradingV2/42.16/media/lua/shared/DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/LifecycleFinalDeath/DTNPC_LifecycleFinalDeath_Recovery.lua`
- `Contents/mods/DynamicTradingV2/42.16/media/lua/shared/DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/LifecycleFinalDeath/DTNPC_LifecycleFinalDeath_ZombieDead.lua`

## Specific Rule From This Regression

When working on multiplayer DTNPC health:

- Preserve the stable server-side behavior from `1b9aaeba`: ignore multiplayer engine HP deltas by default.
- Do not narrow that rule unless there is a hard, explicit, server-trusted hit event proving real damage.
- A fix that only patches revive/weakened flow is incomplete if spawn-time self-kill still exists.

## References

- Read [references/regressions.md](references/regressions.md) for the exact self-kill regression signature and the comparison notes against `1b9aaeba`.
