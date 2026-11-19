# Architecture — DynamicTrading Portable Social State Adoption

## Identity continuity

One trader must keep one canonical Core actorID across:

- DTAbstract abstract state;
- remote/radio contact;
- DTCommon commerce;
- DTHoomans physical materialization where present;
- dematerialization back to abstract state.

Representation changes cannot create a new relationship or erase memory.

## Trade event bridge

    DTCommon authoritative trade outcome
             |
             v
    trader social-event adapter
             |
             v
    Core authorized social event
             |
      +------+------+
      v             v
 relationship    bounded memory
      |             |
      +------+------+
             v
         revision
             |
             v
    later bounded query
      |        |       |
      v        v       v
   pricing   dialogue  future autonomy
   context

The bridge emits social meaning only after the underlying trade outcome is authoritative.

## Social effects versus economics

Social state may influence a policy input such as relationshipModifier, willingness or eligibility.

It must never replace:

- MarketSense value;
- DTCommon quote calculation;
- stock/budget;
- trade transaction authority;
- item transfer;
- settlement/currency truth.

A trusted trader may offer better terms because DT policy chooses to use social context; Core social state does not set the numeric price itself.

## Event families

Only grounded event families should exist.

Examples to audit/implement when supported by actual product mechanics:

- completed trade / repeated trade familiarity;
- fair/reliable interaction;
- gift/help;
- refused trade;
- debt fulfillment/default if debt exists authoritatively;
- explicit betrayal/scam only if the game has an authoritative event for it.

Do not create narrative facts solely to feed memory.

## CodeBuilder

Trade-domain social policy belongs in DynamicTrading-owned canonical source compiled through Core CodeBuilder.

Source describes semantic meaning, retention, relationship effects/effect refs and evidence. It does not call DT Lua implementation directly.

Generated output routes to the owning DT package and is never hand-edited.

## Conversation

Trader dialogue/ConvoEngine may query bounded Core social projections such as:

- directed relationship summary;
- relevant recent/consolidated trade memories;
- direct/hearsay provenance where relevant;
- familiarity;
- commercial extension summary;
- revision.

Conversation may mention only grounded facts.

DTAbstract remote conversation uses the same Core actor/social state without Hoomans.

## Multiplayer

The client never submits trust/memory deltas.

Server flow:

    client trade request
      -> DT validation/commit
      -> authoritative trade result
      -> social event bridge
      -> Core social mutation
      -> bounded UI/conversation projection

Replay/idempotency must prevent double social consequences.

## Future autonomy

A future advertisement system may expose TRADE, NEGOTIATE, REQUEST_ITEM, SHARE_MARKET_NEWS, COLLECT_DEBT or similar grounded opportunities.

Core social state supplies context; DT policy decides commercial eligibility; a future autonomy resolver chooses; DT executes.

This participant job does not implement the Event Director or autonomy brain.
