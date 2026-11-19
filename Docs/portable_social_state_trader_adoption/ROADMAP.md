# Roadmap — DynamicTrading Portable Social State Adoption

This is participant work under Core Portable Social State phases.

## DT0 — Audit

Map actorID/traderID, Core social reads/writes, pricing relationship modifier, provider transitions, conversation and DTAbstract remote access.

Identify any trader-only social/reputation state that duplicates Core.

## DT1 — Policy source

Add/normalize DynamicTrading-owned canonical social event policy through the parent CodeBuilder Social Policy IR once Core P3 contracts are accepted.

## DT2 — Authoritative event bridge (Accepted)

Emit Core social events only from authoritative DT outcomes. Preserve idempotency and do not let conversation/UI fabricate outcomes.

## DT3 — DTAbstract continuity (Accepted)

Prove Core + DTCommon + DTAbstract without Hoomans. Remote/abstract interactions update the same social state later seen by a materialized trader.

## DT4 — Immersive consumers (Accepted)

Use bounded Core social projections in existing relationship pricing context and trader conversation. Add willingness/credit/negotiation consumers only where the current product owns those policies.

## DT5 — MP, scale and regression (Accepted)

Prove reconnect/replay, many abstract traders, bounded storage, no broad private-state replication, deterministic CodeBuilder output and no commerce regression.

Participant completion requires all relevant Core parent gates, not DT5 alone.

## DT6 — Post-cleanup adopter regression (Parent P12 — Accepted)

DynamicTrading production changes are not expected merely because P10 and P11 clean Core and Hoomans ownership boundaries.

After those phases:

- rerun Core plus DTCommon plus DTAbstract with PNC disabled;
- rerun trader social event, replay and idempotency tests;
- rerun relationship-aware pricing and social-aware conversation tests;
- rerun DTAbstract to DTHoomans to DTAbstract continuity with the new Hoomans single-persistence shape;
- prove no trader social state is duplicated into a DT-owned generic relationship store;
- rerun CodeBuilder reconcile and determinism and the full DynamicTrading suite.

**Gate:** DT remains a thin adopter of Core portable social state and all relevant tests remain green after P10-P12.
