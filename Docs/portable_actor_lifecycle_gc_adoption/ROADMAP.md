# Roadmap — DynamicTrading Portable Actor Lifecycle & GC Adoption

Participant work under Core L0-L9.

## D0 — Removal/reference audit

Classify all trader/actor removal calls, provider releases, migration actor replacements, debts/contracts and persistent actor refs.

## D1 — Lifecycle adapter

Use Core Retire only for true actor death/permanent departure. Keep rollback/commercial-role deletion distinct.

## D2 — Domain GC roots

Expose outstanding debt/contract or other genuine historical pins if those mechanics exist. Do not pin every old trader.

## D3 — DTAbstract/DTHoomans continuity

Prove abstract/materialized transitions keep one lifecycle identity and death does not fork actor history.

## D4 — Semantic/trader history

Use bounded lifecycle-aware Core social projections for conversations/pricing context without retaining the full retired trader.

## D5 — Scale/final regression

Stress many traders/retirements, PNC-disabled Core+DTAbstract, combined DTHoomans, save/reload, GC and commercial regressions.

D5 alone does not complete the parent.
