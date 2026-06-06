"""
checker/i18n/string_scanner.py
==============================
Per-line detection of hardcoded UI-facing strings that bypass the i18n system.
Each finding is a dict: {line, context, string, is_known_key}.
"""

from pathlib import Path
from ..config import (
    UI_API_TRIGGERS, WRAPPER_RE, SKIP_LINE_RE,
    SAFE_STRING_RE, LUA_STRING_RE,
)


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def scan_line(line: str, line_no: int, known_keys: set[str]):
    """
    Yield finding dicts for every hardcoded UI-facing string on this line.
    Skips: comment lines, log/debug calls, lines already using a wrapper.
    """
    if SKIP_LINE_RE.search(line):
        return

    # Find which (if any) UI-API trigger is present on this line.
    triggered_context: str | None = None
    for trigger in UI_API_TRIGGERS:
        if trigger in line:
            triggered_context = trigger.rstrip("(= ")
            break

    if triggered_context is None:
        return

    # If a translation wrapper is already used on the same line, trust it.
    if WRAPPER_RE.search(line):
        return

    # Extract every literal string from the line.
    for m in LUA_STRING_RE.finditer(line):
        raw = m.group(1) if m.group(1) is not None else m.group(2)
        if not raw or len(raw) <= 1:
            continue
        if SAFE_STRING_RE.match(raw):
            continue

        yield {
            "line": line_no,
            "context": triggered_context,
            "string": raw,
            "is_known_key": raw in known_keys,
        }


def scan_file(lua_path: Path, known_keys: set[str]) -> list[dict]:
    """Return all i18n findings for one Lua file."""
    findings: list[dict] = []
    try:
        with open(lua_path, encoding="utf-8", errors="ignore") as f:
            for line_no, line in enumerate(f, start=1):
                findings.extend(scan_line(line, line_no, known_keys))
    except Exception as exc:
        findings.append({
            "line": 0,
            "context": "READ_ERROR",
            "string": str(exc),
            "is_known_key": False,
        })
    return findings
