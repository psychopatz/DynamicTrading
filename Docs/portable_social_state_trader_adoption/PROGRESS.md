# Progress — DynamicTrading Portable Social State Adoption

**Status:** READY FOR USER LIVE TEST (Developer DT0–DT5 / Parent P0–P9 Accepted).
**Parent:** PsychopatzCore Docs/portable_social_state.
**Current participant phase:** DT5 accepted (`P9` complete; awaiting user live SP/MP test).
**Participant completion:** 6/6 phases accepted (DT0, DT1, DT2, DT3, DT4, DT5).

## Verified progress

- **DT0 (Accepted):** Full source-verified DT0 audit recorded in `AUDIT.md`.
- **DT1 (Accepted):** Authored `tools/providers/dt/codebuilder/sources/social_policy/` (`dynamic_trading.social_policy`) covering `commercial_trade`/`trade.completed`, `trade.fair_high_value`, `trade.help_scarce_supply`, `trade.gift_or_favor`, `trade.price_grievance`, and `trade.betrayal_or_hostile`, and compiled deterministic `Contents/mods/DTCommon/common/media/lua/shared/DTCommon/SocialPolicy/*` via Core CodeBuilder `reconcile.py`.
- **DT2 (Accepted):** Wired compiled `DTCommon/SocialPolicy/Registry` into `DTCommon_CoreActorPolicy` (`ClassifyTradeEventType`, `RecordTradeEvent` retention/salience/consolidationFamily/caps + `RuntimeStore.MarkDirty`), ensured `DTCommon_TraderRegistry.BindFaction` and `DTHoomans_SettlementTrader.EnsureTraderForFaction` populate `ca.actorID`, synced roster social/lease fields in `DTAbstract_PreSurvivorWorldImport`, and synced Hoomans social state in `DTHoomans_ProviderRuntime.DematerializeTrader` before dematerializing.
- **DT3 (Accepted):** Proved Core + DTCommon + DTAbstract continuity with `PNC = nil` in `tests/dt_portable_social_trader_adoption_smoke.lua` and `tests/dt_trade_relationship_event_smoke.lua`.
- **DT4 (Accepted):** Wired `DTCommon_CoreActorPolicy.QuerySocialProjection` and `willingnessTier` / `relationshipRevision` / `commercialReliability` into `DTCommon_MarketPricing` (`PriceContext` & `ContextRevision`), `DTCommon_TraderService.Snapshot` (`snapshot.social`), and `DTCommon_TraderConversation` (`resolveRelationshipFrom`, social-aware non-LLM `responseFor`, `contextFor`, and `policyFor` context forwarding). Verified `90/90` DynamicTrading tests pass and `pz_verify --kahlua` (`0` errors on all 8 modified production Lua files).
- **DT5 (Accepted):** Verified MP server-only authority, replay deduplication, `DTAbstract -> DTHoomans -> DTAbstract` continuity (`tests/psychopatz_social_mp_continuity_matrix_smoke.lua`), `1,000`-actor / `120`-abstract-trader / `500`-event scale stress + `30KB` chunked save/load (`tests/psychopatz_social_scale_stress_smoke.lua`), CodeBuilder determinism (`reconcile.py --check` `clean=true`, `20` desired `DTCommon` targets), and full `90/90` DynamicTrading Lua regression suite passing (`0` failures).

## Next Chunk

Developer-side **DT0–DT5** and parent **P0–P9** accepted. Ready for user-driven live SP/MP smoke acceptance.
