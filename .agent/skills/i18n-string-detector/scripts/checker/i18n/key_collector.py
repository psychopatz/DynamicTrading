"""
checker/i18n/key_collector.py
=============================
Harvests all registered i18n translation keys from a mod directory:
  1. JSON files inside any Translate/ folder
  2. PZ .txt translation files (key = value format)
  3. getText("KEY") / T("KEY") call-sites in Lua source
"""

import json
import re
from pathlib import Path


_GETTEXT_RE = re.compile(
    r'(?:getText|getTextOrNull|T)\s*\(\s*["\']([^"\']+)["\']'
)


def from_json_files(mod_dir: Path) -> set[str]:
    keys: set[str] = set()
    for json_path in mod_dir.rglob("*.json"):
        parts_lower = [p.lower() for p in json_path.parts]
        if "translate" in parts_lower:
            try:
                with open(json_path, encoding="utf-8", errors="ignore") as f:
                    data = json.load(f)
                if isinstance(data, dict):
                    keys.update(data.keys())
            except Exception:
                pass
    return keys


def from_txt_files(mod_dir: Path) -> set[str]:
    """PZ translation .txt files use 'key = value' lines."""
    keys: set[str] = set()
    for txt_path in mod_dir.rglob("*.txt"):
        parts_lower = [p.lower() for p in txt_path.parts]
        if "translate" in parts_lower:
            try:
                with open(txt_path, encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        line = line.strip()
                        if "=" in line and not line.startswith(("#", "//")):
                            key = line.split("=", 1)[0].strip()
                            if key:
                                keys.add(key)
            except Exception:
                pass
    return keys


def from_lua_callsites(mod_dir: Path) -> set[str]:
    """Extract first-argument keys from getText/T/getTextOrNull calls."""
    keys: set[str] = set()
    for lua_path in mod_dir.rglob("*.lua"):
        try:
            with open(lua_path, encoding="utf-8", errors="ignore") as f:
                for line in f:
                    for m in _GETTEXT_RE.finditer(line):
                        keys.add(m.group(1))
        except Exception:
            pass
    return keys


def collect_all(mod_dir: Path) -> set[str]:
    """Aggregate keys from all three sources."""
    return (
        from_json_files(mod_dir)
        | from_txt_files(mod_dir)
        | from_lua_callsites(mod_dir)
    )
