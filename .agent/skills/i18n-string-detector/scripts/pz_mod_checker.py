#!/usr/bin/env python3
"""
pz_mod_checker.py
=================
Unified CLI entry point for the PZ Mod Checker.

Checks:
  --i18n     Detect hardcoded UI strings not routed through translation helpers.
  --kahlua   Detect Kahlua2 / Lua-5.1 incompatibilities (goto, continue, etc.).
             Both are enabled by default when no flag is specified.

Usage:
    python3 pz_mod_checker.py --mod-dir <path> [options]

Exit codes:
  0 — no issues found
  1 — issues found
  2 — setup / argument error
"""

import argparse
import os
import sys
from pathlib import Path

# Ensure the scripts/ directory is on sys.path so 'checker' is importable
# regardless of the caller's working directory.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from checker.runner import run  # noqa: E402


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="pz_mod_checker.py",
        description="PZ Mod Checker — i18n string detector + Kahlua compatibility linter",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--mod-dir",
        required=True,
        metavar="PATH",
        help="Root directory of the mod (contains common/, 42.16/, etc.)",
    )
    parser.add_argument(
        "--output",
        metavar="FILE",
        default=None,
        help="Write report to this file instead of stdout",
    )

    check_group = parser.add_argument_group("Check selection (default: both enabled)")
    check_group.add_argument(
        "--i18n",
        action="store_true",
        default=False,
        help="Run only the i18n hardcoded-string checker",
    )
    check_group.add_argument(
        "--kahlua",
        action="store_true",
        default=False,
        help="Run only the Kahlua2/Lua-5.1 compatibility checker",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    mod_dir = Path(args.mod_dir).resolve()
    if not mod_dir.is_dir():
        print(f"ERROR: --mod-dir '{mod_dir}' is not a valid directory.", file=sys.stderr)
        return 2

    # If neither flag is given, run both.
    run_i18n = args.i18n or (not args.i18n and not args.kahlua)
    run_kahlua = args.kahlua or (not args.i18n and not args.kahlua)

    report = run(mod_dir=mod_dir, run_i18n=run_i18n, run_kahlua=run_kahlua)

    if args.output:
        out_path = Path(args.output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        with open(out_path, "w", encoding="utf-8") as f:
            f.write(report)
        print(f"[pz-mod-checker] Report written to: {out_path}", file=sys.stderr)
    else:
        print(report)

    # Exit 1 if any findings exist (detected by searching for finding markers).
    has_issues = "L" in report and ("NOT IN TRANSLATE" in report or "KAHL-" in report)
    return 1 if has_issues else 0


if __name__ == "__main__":
    sys.exit(main())
