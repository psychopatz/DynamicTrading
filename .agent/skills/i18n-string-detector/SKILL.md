---
name: i18n-string-detector
description: >
  Detects hardcoded UI-facing strings in Project Zomboid mod Lua files that bypass
  the translation system, AND detects Kahlua2 (Lua 5.1) incompatible patterns
  (goto, continue, table.pack, bitwise operators, sandboxed libs, etc.).
  Mod-agnostic: works on DynamicTrading, DynamicColonies, ZedColonies, or any PZ mod.
  Use when asked to audit a mod for untranslated strings, hardcoded strings, Kahlua
  compatibility, invalid Lua patterns, or translation coverage.
---

# PZ Mod Checker (i18n + Kahlua)

Runs two checkers against a mod's Lua files:
1. **i18n** — finds hardcoded UI strings not routed through a translation helper.
2. **Kahlua** — finds Lua 5.2+/5.3+ patterns and sandboxed APIs invalid in Kahlua2.

## When to use this skill

- Find untranslated or hardcoded strings to make a mod translation-friendly.
- Audit Kahlua2 compatibility before a PZ update or Workshop submission.
- Detect `goto`, `continue`, `table.pack`, `//`, `&`, `|`, `>>`, `io.*`, `os.*`, etc.
- Find strings not saved to the common translation folder.

## Entry Point

```
scripts/pz_mod_checker.py
```

## Usage

```bash
# Run BOTH checkers (default)
python3 .agent/skills/i18n-string-detector/scripts/pz_mod_checker.py \
  --mod-dir <path/to/mod/root> [--output report.txt]

# i18n only
python3 pz_mod_checker.py --mod-dir <path> --i18n

# Kahlua only
python3 pz_mod_checker.py --mod-dir <path> --kahlua
```

## Examples

```bash
# Full audit of DynamicTrading (both checks)
python3 .agent/skills/i18n-string-detector/scripts/pz_mod_checker.py \
  --mod-dir /home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods/DynamicTradingV2 \
  --output /tmp/dt_full_report.txt

# DynamicColonies — Kahlua compatibility check only
python3 .agent/skills/i18n-string-detector/scripts/pz_mod_checker.py \
  --mod-dir /home/psychopatz/Zomboid/Workshop/DynamicColonies/Contents \
  --kahlua --output /tmp/dc_kahlua.txt
```

## Module Structure

```
scripts/
  pz_mod_checker.py          ← CLI entry point (argument parsing + output only)
  checker/
    config.py                ← ALL regex constants and trigger lists (edit here)
    path_filter.py           ← File exclusion logic (Manuals/, etc.)
    runner.py                ← Orchestration: collect files → run scanners → report
    reporting.py             ← Report formatting (i18n section + kahlua section)
    i18n/
      key_collector.py       ← Harvest translation keys from JSON/txt/Lua
      string_scanner.py      ← Detect hardcoded UI strings per-line
    kahlua/
      rules.py               ← All KAHL-E* / KAHL-W* rules as dataclasses
      kahlua_scanner.py      ← Apply Kahlua rules per-line (strips strings first)
```

> **To add a new UI trigger or safe-string pattern:** edit `checker/config.py` only.  
> **To add a new Kahlua rule:** append to `KAHLUA_RULES` in `checker/kahlua/rules.py`.

## What is Auto-Excluded

| Category | Reason |
|---|---|
| `*/common/*/Manuals/**` Lua files | In-game documentation — not UI code |
| `print(`, `Log(`, `error(` lines | Debug output, not user-facing |
| `require "…"`, `getTexture(…)` | Technical identifiers, not strings |
| PascalCase / camelCase identifiers | Internal state/enum keys |
| Lines using `getText(` / `T("KEY"` | Already routed through translation |

## Kahlua Rules Detected

| ID | Pattern | Severity |
|---|---|---|
| KAHL-E001 | `goto` | ERROR |
| KAHL-E002 | `::label::` | ERROR |
| KAHL-E003 | `//` floor division | ERROR |
| KAHL-E004–E007 | `&`, `\|`, `~`, `>>`, `<<` bitwise ops | ERROR |
| KAHL-E008–E010 | `table.pack`, `table.unpack`, `table.move` | ERROR |
| KAHL-E016 | `coroutine.*` | ERROR |
| KAHL-E017–E020 | `io.*`, `os.*`, `debug.*`, `package.*` | ERROR |
| KAHL-E021–E022 | `require()`, `dofile()`, `loadfile()` | ERROR |
| KAHL-E023 | `!=` (use `~=`) | ERROR |
| KAHL-E024 | `continue` | ERROR |
| KAHL-W001–W005 | `load()`, `table.getn`, `string.len`, `setfenv`, bare `pcall` | WARNING |
