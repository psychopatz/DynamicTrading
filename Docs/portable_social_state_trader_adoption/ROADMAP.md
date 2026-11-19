# Roadmap — DynamicTrading Portable Social State Adoption

This is participant work under Core Portable Social State phases.

## DT0 — Audit

Map actorID/traderID, Core social reads/writes, pricing relationship modifier, provider transitions, conversation and DTAbstract remote access.

Identify any trader-only social/reputation state that duplicates Core.

## DT1 — Policy source

Add/normalize DynamicTrading-owned canonical social event policy through the parent CodeBuilder Social Policy IR once Core P3 contracts are accepted.

## DT2 — Authoritative event bridge

Emit Core social events only from authoritative DT outcomes. Preserve idempotency and do not let conversation/UI fabricate outcomes.

## DT3 — DTAbstract continuity

Prove Core + DTCommon + DTAbstract without Hoomans. Remote/abstract interactions update the same social state later seen by a materialized trader.

## DT4 — Immersive consumers

Use bounded Core social projections in existing relationship pricing context and trader conversation. Add willingness/credit/negotiation consumers only where the current product owns those policies.

## DT5 — MP, scale and regression

Prove reconnect/replay, many abstract traders, bounded storage, no broad private-state replication, deterministic CodeBuilder output and no commerce regression.

Participant completion requires all relevant Core parent gates, not DT5 alone.
