# DynamicTrading Adoption — Grounded World Knowledge & Gossip

Status: PLANNED / implementation not yet accepted.
Canonical cross-repository goal: PsychopatzCore Docs/world_knowledge_gossip/.
DynamicTrading role: adopter/provider of trader, caravan, route and market observations while preserving DTCommon commerce authority.

Planning baseline: DynamicTrading 938721fa538a13845684acb22a5468fe0a9dc9e5; Core 159df9e2f12cb4a3911f50d6c27dcc1d48a861fc; ProjectHoomans 2bcefd74d3c46df0f707467a7e9b8a6ba42cb185.

## Accepted foundation to preserve

- One trader maps to one Core actor.
- DTAbstract and DTHoomans share Core actor/provider continuity and Talk.
- DTCommon owns merchant stock, budget, quote/session validation and transaction fulfillment.
- Core actor personal inventory/relationships/Knowledge remain distinct from merchant commerce state.
- Radio Talk does not authorize remote inventory transfer.

Do not rebuild those systems.

## DT fact producers

Later W7 may publish bounded typed facts such as:
- trader/caravan arrival or departure;
- route disruption or recovery;
- market shortage/surplus observation;
- settlement/trader availability changes;
- other real committed DT state transitions that are useful for conversation.

Exact vocabulary must be audited against current DT authority. Do not publish a fact merely because a client UI displays text. Facts come from committed server state or an explicitly authorized observation.

## Consumption

A DTAbstract trader may discuss facts already known by its Core actor. If DTHoomans materializes the same trader, it must use the same actor knowledge references. Provider transition cannot reroll, copy or fork gossip memory.

Core+DT with no Hoomans must remain supported. Hoomans-specific faction/zombie facts are optional providers, not DT dependencies.

## Commerce invariant

WorldKnowledge is informational. It cannot:
- modify stock;
- change budget;
- issue/accept a quote;
- fulfill a buy/sell;
- bypass range/access/session checks;
- copy merchant stock into actor personal inventory.

If dialogue proposes commerce, the existing DTCommon authorization path remains the only owner of effects.

## Radio/privacy

Radio dissemination must preserve authenticated contact/channel/player identity and any existing Core player-scoped privacy. A trader knowing a public market fact does not grant access to another player's private Knowledge. PBrainZ receives only the same authorized actor projection.

## Acceptance

W7 acceptance requires:
1. Core+DTAbstract, no Hoomans: trader can learn/discuss a DT-owned fact through shared Core Talk.
2. DTAbstract -> DTHoomans -> DTAbstract: same actorID/traderID retains fact knowledge and provenance without duplication.
3. save/reload retains only facts/references covered by retention contract.
4. market/trader dialogue does not mutate stock/budget/transactions without normal DTCommon authorization.
5. two-player privacy remains isolated.
6. Hoomans installed: optional Hoomans facts can be consumed through the same Core actor path without a DT-specific parser or gossip store.
7. existing DynamicTrading tests plus cross-repo Semantic Lab worker matrix pass.

No new branch, no checked-in /goal prompt, no native PZ or Workshop action.
