# SimulateGame

Utility toolkit for DynamicTrading balancing and debugging.

## Commands

- `python Scripts/SimulateGame/main.py build`
- `python Scripts/SimulateGame/main.py serve --port 8765`

`build` parses live Lua from `Contents/mods/DynamicTradingCommon/.../DT/Common` and regenerates:

- `Scripts/SimulateGame/Output/web/index.html`
- `Scripts/SimulateGame/Output/web/timeline.html`
- `Scripts/SimulateGame/Output/web/assets/data/sim_data.json`

## Scope

This uses Option B parity:

- Mirrors stock generation, tag matching, wildcard pool, and event multipliers.
- Uses deterministic approximations for runtime-only parts.
- Timeline lab emulates flash/meta/seasonal accumulation with configurable defaults.
