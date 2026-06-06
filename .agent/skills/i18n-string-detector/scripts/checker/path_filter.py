"""
checker/path_filter.py
======================
File-path exclusion logic shared by all scanners.
Extend EXCLUDED_FOLDER_NAMES in config.py to add new exclusions.
"""

from pathlib import Path
from .config import EXCLUDED_FOLDER_NAMES, EXCLUDED_UNDER_FOLDER


def is_excluded(path: Path) -> bool:
    """
    Return True if this Lua file must be skipped by ALL scanners.

    Current rules:
    - Any file inside a 'Manuals' folder that lives under 'common' in its path.
      e.g. common/media/lua/shared/DT/V2/Manuals/…
    """
    parts = path.parts
    for i, part in enumerate(parts):
        if part in EXCLUDED_FOLDER_NAMES:
            if EXCLUDED_UNDER_FOLDER in parts[:i]:
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
