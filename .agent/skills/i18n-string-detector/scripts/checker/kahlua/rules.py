"""
checker/kahlua/rules.py
=======================
Kahlua2 / Lua 5.1 incompatibility rules.

Each rule is a dict:
  id       — KAHL-E/W/I code
  severity — "ERROR" | "WARNING" | "INFO"
  pattern  — compiled regex to match on a raw source line
  message  — short human-readable description
  fix      — suggested replacement (optional)

To add a new rule: append an entry to KAHLUA_RULES.
"""

import re
from dataclasses import dataclass


@dataclass(frozen=True)
class KahluaRule:
    id: str
    severity: str        # "ERROR" | "WARNING" | "INFO"
    pattern: re.Pattern
    message: str
    fix: str = ""


def _r(pattern: str, flags: int = 0) -> re.Pattern:
    return re.compile(pattern, flags)


# Comment-only line — never flag these.
_COMMENT_RE = re.compile(r"^\s*--")


KAHLUA_RULES: list[KahluaRule] = [
    # ── Error rules (crash or silent failure) ──────────────────────────────
    KahluaRule(
        id="KAHL-E001",
        severity="ERROR",
        pattern=_r(r"\bgoto\b"),
        message="'goto' is Lua 5.2+ — not supported in Kahlua2",
        fix="Refactor with if/else, break, or repeat/until false",
    ),
    KahluaRule(
        id="KAHL-E002",
        severity="ERROR",
        pattern=_r(r"::[A-Za-z_]\w*::"),
        message="goto label '::label::' is Lua 5.2+ — not supported",
        fix="Remove goto labels; use structured control flow",
    ),
    KahluaRule(
        id="KAHL-E003",
        severity="ERROR",
        # Match // that is NOT inside a string (best-effort heuristic)
        pattern=_r(r"(?<![\"'])//(?![\"'])"),
        message="'//' floor division is Lua 5.3+ — not supported",
        fix="Use math.floor(a / b)",
    ),
    KahluaRule(
        id="KAHL-E004",
        severity="ERROR",
        pattern=_r(r"(?<![=<>~!])&(?!=)"),
        message="'&' bitwise AND is Lua 5.3+ — not supported",
        fix="Use bit.band(a, b) or integer arithmetic",
    ),
    KahluaRule(
        id="KAHL-E005",
        severity="ERROR",
        pattern=_r(r"(?<![=<>~!])\|(?!=)"),
        message="'|' bitwise OR is Lua 5.3+ — not supported",
        fix="Use bit.bor(a, b)",
    ),
    KahluaRule(
        id="KAHL-E006",
        severity="ERROR",
        # Match ~ that is NOT part of ~= (inequality is valid Lua 5.1)
        pattern=_r(r"~(?!=)"),
        message="'~' bitwise NOT/XOR is Lua 5.3+ (note: '~=' inequality is valid)",
        fix="Use bit.bnot() or bit.bxor()",
    ),
    KahluaRule(
        id="KAHL-E007",
        severity="ERROR",
        pattern=_r(r">>|<<"),
        message="'>>' / '<<' bitwise shift is Lua 5.3+ — not supported",
        fix="Use bit.rshift() / bit.lshift()",
    ),
    KahluaRule(
        id="KAHL-E008",
        severity="ERROR",
        pattern=_r(r"\btable\.pack\s*\("),
        message="'table.pack()' is Lua 5.2+ — not available in Kahlua2",
        fix="Use local t = {...}",
    ),
    KahluaRule(
        id="KAHL-E009",
        severity="ERROR",
        pattern=_r(r"\btable\.unpack\s*\("),
        message="'table.unpack()' is Lua 5.2+ — use unpack() (Lua 5.1 global)",
        fix="Use unpack(t)",
    ),
    KahluaRule(
        id="KAHL-E010",
        severity="ERROR",
        pattern=_r(r"\btable\.move\s*\("),
        message="'table.move()' is Lua 5.3+ — not supported",
        fix="Implement a manual copy loop",
    ),
    KahluaRule(
        id="KAHL-E011",
        severity="ERROR",
        pattern=_r(r"\brawlen\s*\("),
        message="'rawlen()' is Lua 5.2+ — not supported",
        fix="Use the # operator",
    ),
    KahluaRule(
        id="KAHL-E012",
        severity="ERROR",
        pattern=_r(r"\bmath\.type\s*\("),
        message="'math.type()' is Lua 5.3+ — no integer subtype in Kahlua",
        fix="Use type(x) == 'number'",
    ),
    KahluaRule(
        id="KAHL-E013",
        severity="ERROR",
        pattern=_r(r"\bmath\.tointeger\s*\("),
        message="'math.tointeger()' is Lua 5.3+ — not supported",
        fix="Use math.floor(x)",
    ),
    KahluaRule(
        id="KAHL-E014",
        severity="ERROR",
        pattern=_r(r"\bstring\.(pack|unpack|packsize)\s*\("),
        message="'string.pack/unpack/packsize' is Lua 5.3+ — not supported",
        fix="Use manual bit arithmetic",
    ),
    KahluaRule(
        id="KAHL-E015",
        severity="ERROR",
        pattern=_r(r"\butf8\."),
        message="'utf8.*' library is Lua 5.3+ — not available in Kahlua",
        fix="Use string.* byte functions",
    ),
    KahluaRule(
        id="KAHL-E016",
        severity="ERROR",
        pattern=_r(r"\bcoroutine\."),
        message="'coroutine.*' is not implemented in Kahlua2",
        fix="Use PZ Events.* or an explicit state machine",
    ),
    KahluaRule(
        id="KAHL-E017",
        severity="ERROR",
        pattern=_r(r"\bio\."),
        message="'io.*' is sandboxed in PZ — not available",
        fix="Use getModFileWriter() / getModFileReader()",
    ),
    KahluaRule(
        id="KAHL-E018",
        severity="ERROR",
        pattern=_r(r"\bos\."),
        message="'os.*' is sandboxed in PZ — not available",
        fix="Use getGameTime() for time-related operations",
    ),
    KahluaRule(
        id="KAHL-E019",
        severity="ERROR",
        pattern=_r(r"\bdebug\."),
        message="'debug.*' is sandboxed (stripped) in PZ",
        fix="Use print() or DynamicTrading.Log() for debug output",
    ),
    KahluaRule(
        id="KAHL-E020",
        severity="ERROR",
        pattern=_r(r"\bpackage\."),
        message="'package.*' is sandboxed in PZ — not available",
        fix="PZ auto-loads Lua files; no explicit package management needed",
    ),
    KahluaRule(
        id="KAHL-E021",
        severity="ERROR",
        pattern=_r(r"\brequire\s*\("),
        message="'require()' (function form) is sandboxed in PZ",
        fix="Use the statement form: require \"ModName/Path\"",
    ),
    KahluaRule(
        id="KAHL-E022",
        severity="ERROR",
        pattern=_r(r"\b(dofile|loadfile)\s*\("),
        message="'dofile()' / 'loadfile()' are sandboxed in PZ",
        fix="PZ auto-loads lua files by directory convention",
    ),
    KahluaRule(
        id="KAHL-E023",
        severity="ERROR",
        pattern=_r(r"!="),
        message="'!=' is not valid Lua — use '~=' for inequality",
        fix="Replace != with ~=",
    ),
    KahluaRule(
        id="KAHL-E024",
        severity="ERROR",
        pattern=_r(r"\bcontinue\b"),
        message="'continue' is not a Lua keyword — not supported",
        fix="Use repeat/until false with break, or restructure the loop body",
    ),

    # ── Warning rules ──────────────────────────────────────────────────────
    KahluaRule(
        id="KAHL-W001",
        severity="WARNING",
        pattern=_r(r"\bload\s*\("),
        message="'load(string)' signature changed in Lua 5.2 — prefer loadstring()",
        fix="Use loadstring() for Lua 5.1/Kahlua compatibility",
    ),
    KahluaRule(
        id="KAHL-W002",
        severity="WARNING",
        pattern=_r(r"\btable\.getn\s*\("),
        message="'table.getn()' is deprecated since Lua 5.1",
        fix="Use the # operator",
    ),
    KahluaRule(
        id="KAHL-W003",
        severity="WARNING",
        pattern=_r(r"\bstring\.len\s*\("),
        message="'string.len()' works but #s is idiomatic Lua",
        fix="Use #s instead",
    ),
    KahluaRule(
        id="KAHL-W004",
        severity="WARNING",
        pattern=_r(r"\b(set|get)fenv\s*\("),
        message="'setfenv()'/'getfenv()' are Lua 5.1 — verify Kahlua support",
    ),
    KahluaRule(
        id="KAHL-W005",
        severity="WARNING",
        pattern=_r(r"\bpcall\s*\(\s*\)"),
        message="'pcall()' called with no function — likely a bug",
    ),
]
