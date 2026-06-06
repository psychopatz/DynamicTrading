"""
checker/path_filter.py
======================
File-path exclusion logic shared by all scanners.
Extend EXCLUDED_FOLDER_NAMES in config.py to add new exclusions.
"""

from pathlib import Path
from .config import EXCLUDED_FOLDER_NAMES, EXCLUDED_UNDER_FOLDER


def is_excluded(path: Path) -> bool:
    """Return True if this Lua file must be skipped by ALL scanners."""
    for part in path.parts:
        if part in EXCLUDED_FOLDER_NAMES:
            return True
    return False


def collect_lua_files(mod_dir: Path) -> tuple[list[Path], int]:
    """
    Walk the mod directory, return (included_files, excluded_count).
    Files matching is_excluded() are counted but not returned.
    """
    included: list[Path] = []
    excluded_count: int = 0

    for lua_path in sorted(mod_dir.rglob("*.lua")):
        if is_excluded(lua_path):
            excluded_count += 1
        else:
            included.append(lua_path)

    return included, excluded_count
