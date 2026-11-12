# Semantic Dialogue Language Standard — DynamicTrading Adopter Pointer

The canonical PSDL goal and implementation authority is owned by PsychopatzCore:

`/home/psychopatz/Zomboid/Workshop/psychopatzCore/Docs/semantic_dialogue_language_standard/`

DynamicTrading/DTCommon is a **mandatory adopter**, not optional future scope.

DynamicTrading may own trader/market-specific PSDL records, trading adapters, tests, translations/content and gameplay-specific constraints. It must not duplicate the PSDL schema, Canonical Semantic Dialogue IR, compiler/normalizer, generic validator, predicate/reference/slot/binding engine or shared authoring service.

The existing `tools/providers/dt/codebuilder/sources/conversation/` tree is mandatory S0 inventory/migration input. Its trader conversation packs and static suggestions must be reconciled with the Core-owned PSDL standard; do not preserve a parallel first-party DynamicTrading dialogue language or create new legacy/compatibility source trees.

Read the Core-owned ROADMAP, PROGRESS, HANDOFF, ARCHITECTURE, LANGUAGE_SPEC, NAMING_AND_LAYOUT and AGENT_RUNBOOK before active work.
