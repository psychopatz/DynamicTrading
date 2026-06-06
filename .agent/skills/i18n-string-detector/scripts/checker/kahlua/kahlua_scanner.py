"""
checker/kahlua/kahlua_scanner.py
=================================
Per-line Kahlua2 compatibility checker.
Each finding is a dict: {line, rule_id, severity, message, snippet, fix}.
"""

import re
from pathlib import Path
from .rules import KAHLUA_RULES, _COMMENT_RE


# ---------------------------------------------------------------------------
# Inline content stripper.
# Strips Lua string literals and trailing comments before pattern matching
# to avoid false positives from string content or comments.
# ---------------------------------------------------------------------------
_STRING_RE = re.compile(
    r'"[^"\\]*(?:\\.[^"\\]*)*"|\'[^\'\\]*(?:\\.[^\'\\]*)*\''
)
_TRAILING_COMMENT_RE = re.compile(r"--.*$")


def _strip_content(line: str) -> str:
    """Replace string literals and trailing comments with spaces."""
    line = _TRAILING_COMMENT_RE.sub("", line)
    return _STRING_RE.sub(lambda m: " " * len(m.group()), line)


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def scan_line(line: str, line_no: int) -> list[dict]:
    """
    Check one source line against all Kahlua rules.
    Returns a list of finding dicts (may be empty).
    """
    # Skip pure comment lines.
    if _COMMENT_RE.match(line):
        return []

    # Strip string literals and trailing comments to avoid false-positives.
    check_line = _strip_content(line)

    findings: list[dict] = []
    for rule in KAHLUA_RULES:
        if rule.pattern.search(check_line):
            findings.append({
                "line": line_no,
                "rule_id": rule.id,
                "severity": rule.severity,
                "message": rule.message,
                "snippet": line.rstrip(),
                "fix": rule.fix,
            })
    return findings


def scan_file(lua_path: Path) -> list[dict]:
    """Return all Kahlua findings for one Lua file."""
    findings: list[dict] = []
    try:
        with open(lua_path, encoding="utf-8", errors="ignore") as f:
            for line_no, line in enumerate(f, start=1):
                findings.extend(scan_line(line, line_no))
    except Exception as exc:
        findings.append({
            "line": 0,
            "rule_id": "READ_ERROR",
            "severity": "ERROR",
            "message": str(exc),
            "snippet": "",
            "fix": "",
        })
    return findings
