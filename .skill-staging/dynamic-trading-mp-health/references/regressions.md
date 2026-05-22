# DTNPC MP Health Regressions

## Spawn Self-Kill Signature

Symptoms:

- NPC spawns healthy.
- As soon as DTNPC AI/live body ownership connects, virtual HP drops sharply with no real hit.
- Logs show `customCurrent` falling from full HP to `1` or `0`.
- Removal/final death follows immediately.

Known real example:

- Healthy spawn around `customCurrent=134`.
- Immediate phantom damage displays as roughly `-133`.
- NPC is then removed as dead.

## Root Cause Pattern

The regression appears when the code lets replicated or engine-side zombie HP transitions drive DT virtual HP.

Unsafe assumption:

- "Engine HP changed, therefore the NPC took real damage."

Safe assumption:

- "Engine HP changed without a trusted explicit hit source, therefore it is probably MP sync noise."

## Stable Comparison

Stable baseline:

- Commit `1b9aaeba`
- `DTNPCLifecycle.ShouldIgnoreMultiplayerEngineDelta(...)` ignored server-side multiplayer engine HP deltas broadly.

Regression direction after the stable commit:

- Later revisions narrowed the ignore rule and started allowing attacker-less `engine_fallback` paths to mutate virtual HP.
- That made spawn/attach churn capable of forcing incapacitation or death.

## Practical Rule

If you are about to add logic that converts engine HP delta into DT damage:

- Require a trusted explicit hit path.
- Prefer `client_weapon_hit_report`, `weapon_hit_event`, or a known NPC/zombie combat path.
- Do not trust spawn-time body changes, AI activation, or attacker-less engine health movement.

## Audit Checklist

- Did `combatHealth.current` change because of a real hit source?
- Did `zombie:getAttackedBy()` come from a real attacker or stale engine state?
- Did `lastDamageSource` come from an explicit event or an inferred fallback?
- Did the code compare against `1b9aaeba` before narrowing multiplayer engine-delta suppression?
