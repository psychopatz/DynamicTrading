# Portable Social State — DynamicTrading / DTAbstract Adoption

**Status:** PLANNED participant work.
**Parent job:** PsychopatzCore Docs/portable_social_state/.
**Parent completion boundary:** Core P0-P9. This document does not redefine parent completion.

## Goal

Adopt the Core Portable Social State in DynamicTrading so traders remember meaningful commercial/social history and use it for immersive conversation, relationship-aware pricing context, willingness/negotiation/credit inputs and future non-LLM autonomy without creating a trader-only relationship database.

DTAbstract must receive the same benefits with Project Hoomans absent.

## Existing evidence

Current DynamicTrading already:

- assigns stable canonical actor IDs to trader definitions;
- supports DTAbstract provider state without a physical NPC body;
- reads Core social approval/respect/familiarity in DTCommon_CoreActorPolicy for relationship-aware pricing;
- keeps merchant stock/budget/quotes/trade settlement in DTCommon rather than Core actor personal inventory.

This adoption should extend that existing path.

## Ownership

DTCommon owns:

- merchant stock;
- budgets/funds;
- quotes;
- trade sessions/commit;
- commercial eligibility;
- pricing/credit/negotiation policy;
- authoritative trade-domain events.

PsychopatzCore owns:

- actor identity;
- generic directional social relationship;
- bounded social memory;
- retention/consolidation mechanism;
- portable social query projection;
- Social Policy IR/compiler mechanism.

DTAbstract owns:

- abstract/remote trader provider/access;
- radio/contact authorization and representation-specific behavior.

MarketSense owns market/economic valuation/classification.

Project Hoomans is optional for this adopter path.

## Immersion target

A trader should be able to remember and react to grounded history such as repeated fair trade, gifts/help, reliable fulfillment, grievance-causing treatment or domain-authoritative default/betrayal events where those mechanics exist.

That history may influence:

- trader dialogue;
- relationship pricing modifier;
- willingness to negotiate;
- patience;
- credit eligibility inputs;
- requests/offers;
- future advertisement/autonomy candidate features.

It must not fabricate prices, stock, debt, scams or promises that the economic/gameplay system did not authorize.

## No LLM requirement

All trader social decisions and dialogue selection must work from compiled semantic policy, Core social state and ConvoEngine semantics. An LLM is optional realization only and is never required for trader behavior.
