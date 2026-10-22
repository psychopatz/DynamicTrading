# DynamicTrading World Knowledge Adoption Contract

Status: W0 contract freeze, 2026-10-22.

DynamicTrading adopts the reusable Core World Knowledge mechanism without moving commerce authority. `DTCommon` owns traderID, trader records, stock, budgets, quotes, access, sessions, fulfillment, and transactions. `DTCommon.CoreActorPolicy` is the traderID → shared Core actorID binding. `DTCommon.TalkService` owns the bounded server-authorized conversation session and checks actor/provider revision continuity. `DTAbstract` and `DTHoomans` are provider adapters for the same Core actor; neither owns a second persona or gossip store.

World facts may describe DT-owned routes, caravans, trader availability, stock observations, or markets only when a DT authority publishes the typed fact. A fact conversation never authorizes a trade, remote stock mutation, budget mutation, or inventory transfer. Hoomans facts remain optional providers; DTCommon must work with Core plus DT without ProjectHoomans.

By W7 the adapter must preserve the same actorID, traderID binding, fact reference, provenance, and bounded conversation state across `DTAbstract → DTHoomans → DTAbstract`. Persist compact fact IDs/references only; do not persist localized gossip, transcripts, or copied commerce payloads.

W0 source evidence: runtime media is deliberately excluded from the codebase-memory index and was read directly. The current source seams are `Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_CoreActorPolicy.lua`, `DTCommon_TalkService.lua`, `DTCommon_TraderService.lua`, `DTAbstract/DTAbstract_CoreProvider.lua`, and `DTHoomans/DTHoomans_CoreProvider.lua`. Local `main` is `938721fa538a13845684acb22a5468fe0a9dc9e5`, one commit behind remote `bcba858a412e6b9fa16030c4fea5b82217f6d1e8`; no pull or Workshop action was performed.

## W7 adoption evidence

`DTCommon_WorldKnowledge.lua` is the sole DT adapter. Its Core calls are `Publish`, `Acquire`, `Context`, `Explain`, `Share`, `ToPayload`, and `FromPayload`; the persisted payload is placed inside the existing DTCommon ModData envelope under `worldKnowledge`. `DTCommon_TalkService` uses that adapter only to pass grounded `worldKnowledge`/`npcGossip` context to the existing Core actor conversation service. A successful fact statement therefore remains informational and cannot authorize a commerce operation.

The acceptance fixture uses the existing trader record and CoreActorPolicy binding, then changes only provider lease metadata across abstract and materialized stages. The actor ID, trader ID, fact ID, provenance, and bounded conversation context remain continuous. Project Hoomans is not loaded by the W7 mechanism.
