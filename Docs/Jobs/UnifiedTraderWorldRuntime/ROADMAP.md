# Roadmap — Unified Trader World Runtime

## Parent completion boundary

DynamicTrading has one provider-agnostic DTCommon trader-world runtime. DTAbstract and DTHoomans are representation/interaction adapters, not parallel trader simulations.

The previous DTAbstract production recovery is accepted foundation, not the current completion boundary.

## Accepted foundation — 2026-11-03

Preserve:

- Core single map host and synchronized actor projection;
- production actor persistence;
- real DTAbstract Debug Manager;
- map/nearby presentation;
- abstract↔physical provider transition;
- settlement provider seam;
- recovery DynamicTrading suite: 57/57.

Foundation commits:

- PsychopatzCore `d7a892155e8e890b6af87d4b7a322f0ac3e62ec4`
- ProjectHoomans `564f3656f09b443dc0c2bcda8b9886905baf7152`
- DynamicTrading `f9f228452ce2493bc91044569354d131905a40bb`

## U0 — Characterization and ownership contracts

**Status: ACTIVE**

Goals:

- inventory every trader-world responsibility currently owned by DTCommon, DTAbstract, and DTHoomans;
- add fail-first/parity tests around spawn, route intent, arrival, visits, provider transition, contact/action projection, and absence of Hoomans;
- establish one canonical lifecycle contract before moving implementations;
- identify direct optional-adopter dependencies inside DTCommon.

Gate:

- tests expose double/parallel commercial authority;
- provider-specific behavior is explicitly separated from common domain behavior;
- migration targets are source-backed.

## U1 — DTCommon Trader World domain

Create/extend common domain authority for:

- trader population intent;
- canonical creation/registration;
- route/destination intent;
- cooldown/schedule;
- common journey metadata/state;
- arrival dispatch;
- exactly-once visit/exchange;
- provider-independent query state.

Gate:

- common lifecycle runs with a fake provider and no adopter loaded;
- one trader completes spawn→travel→arrival→cooldown through DTCommon authority.

## U2 — Provider/representation registry

Define provider capability seams and migrate:

- DTAbstract abstract representation/movement;
- DTHoomans physical body/caravan/travel.

Gate:

- provider transitions preserve traderID, actorID, stock, budget, journey identity, and visit history;
- no closed hard-coded provider set is required;
- standalone DTAbstract works without Hoomans.

## U3 — Remove lifecycle authority from DTAbstract

Move common ownership out of `DTAbstract_Lifecycle`.

Gate:

- DTAbstract no longer independently owns destination selection, commercial arrival, cooldown, or settlement exchange;
- map/nearby/debug remain green;
- abstract provider consumes the common lifecycle contract.

## U4 — Remove lifecycle authority from DTHoomans

Move common commercial ownership out of caravan/settlement modules while preserving Hoomans mechanics.

Gate:

- DTHoomans travel/arrival feeds DTCommon;
- Hoomans mobility is not a second commercial route authority;
- exactly one visit/exchange occurs per canonical arrival.

## U5 — Unify interaction/contact/access seams

Remove duplicated remote/physical contact/action construction.

Targets:

- RadioOS enumeration/paging/action duplication;
- `TraderService` direct DTHoomans/PNC calls;
- MarketEvents/SettlementMarket direct PNC community lookups;
- DTCommon client direct optional PNC UI dependency where an adapter can own presentation.

Gate:

- DTCommon runs without Hoomans globals;
- remote/physical adapters share canonical action/contact models;
- mode-specific eligibility remains provider-owned.

## U6 — Remove parallel/legacy code

After callers migrate:

- delete redundant lifecycle/arrival/routing implementations;
- remove temporary compatibility shims;
- remove stale provider-specific branches/default ownership;
- rename/move modules where necessary so ownership is obvious.

Gate:

- source audit finds one commercial trader-world lifecycle authority;
- every remaining adopter module owns a unique provider/presentation responsibility;
- no active legacy copy remains.

## U7 — Regression, performance, and native handoff

Developer gates:

- full DynamicTrading suite;
- focused Core/Hoomans regressions;
- `git diff --check`;
- `luac -p`;
- installed-PZ Kahlua verification;
- performance bounds;
- split authority/client tests;
- save/reload/handoff recovery;
- provider absence/load-order matrix.

Then native acceptance:

- standalone DTAbstract;
- DTHoomans physical traders;
- representation transitions;
- save/reload abstract/materialized;
- SP;
- MP/reconnect;
- no duplicate trader/body/exchange;
- map/notification/NPC interaction parity.

## Stop condition

Do not stop after migrating one adopter.

The parent goal is complete only when both adopters consume common trader-world authority, redundant lifecycle code is removed, and U7 developer gates pass.
