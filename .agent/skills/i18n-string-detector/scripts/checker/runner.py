"""
checker/runner.py
=================
Orchestration layer: collects files, runs i18n and/or Kahlua scanners,
and assembles the final report.
Import this module in the CLI entry point or from other tools.
"""

import sys
from pathlib import Path

from .path_filter import collect_lua_files
from .i18n.key_collector import collect_all as collect_keys
from .i18n.string_scanner import scan_file as i18n_scan_file
from .kahlua.kahlua_scanner import scan_file as kahlua_scan_file
from .reporting import build_full_report


def run(
    mod_dir: Path,
    run_i18n: bool = True,
    run_kahlua: bool = True,
) -> str:
    """
    Execute all enabled checkers against mod_dir.
    Returns the complete report string.
    """
    print(f"[pz-mod-checker] Scanning: {mod_dir}", file=sys.stderr)

    # 1. Discover files.
    lua_files, excluded_count = collect_lua_files(mod_dir)
    total_scanned = len(lua_files)
    print(
        f"[pz-mod-checker] {total_scanned} Lua files found ({excluded_count} excluded).",
        file=sys.stderr,
    )

    # 2. Collect translation keys (if i18n check is enabled).
    known_keys: set[str] = set()
    if run_i18n:
        print("[pz-mod-checker] Collecting translation keys...", file=sys.stderr)
        known_keys = collect_keys(mod_dir)
        print(f"[pz-mod-checker] {len(known_keys)} keys registered.", file=sys.stderr)

    # 3. Run scanners.
    i18n_by_file: dict[Path, list[dict]] = {}
    kahlua_by_file: dict[Path, list[dict]] = {}

    for lua_path in lua_files:
        if run_i18n:
            findings = i18n_scan_file(lua_path, known_keys)
            if findings:
                i18n_by_file[lua_path] = findings

        if run_kahlua:
            findings = kahlua_scan_file(lua_path)
            if findings:
                kahlua_by_file[lua_path] = findings

    print(
        f"[pz-mod-checker] Done. "
        f"i18n files flagged: {len(i18n_by_file)}  |  "
        f"Kahlua files flagged: {len(kahlua_by_file)}",
        file=sys.stderr,
    )

    # 4. Build and return the report.
    return build_full_report(
        mod_dir=mod_dir,
        i18n_by_file=i18n_by_file,
        kahlua_by_file=kahlua_by_file,
        known_keys=known_keys,
        total_scanned=total_scanned,
        excluded_count=excluded_count,
    )
