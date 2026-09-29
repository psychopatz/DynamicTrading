#!/usr/bin/env python3
"""Run isolated Dynamic Trading Lua smoke tests."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TESTS = ROOT / "tests"


def discover(filters: list[str]) -> list[Path]:
    tests = sorted(TESTS.glob("*_smoke.lua"))
    if not filters:
        return tests
    lowered = [value.casefold() for value in filters]
    return [path for path in tests if any(
        value in path.stem.casefold() for value in lowered)]


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("filters", nargs="*")
    parser.add_argument("--lua", default="lua")
    parser.add_argument("--timeout", type=float, default=30.0)
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("--list", action="store_true")
    options = parser.parse_args(argv)
    tests = discover(options.filters)
    if options.list:
        for path in tests:
            print(path.relative_to(ROOT))
        return 0
    if not tests:
        print("No matching Lua tests.", file=sys.stderr)
        return 2

    environment = os.environ.copy()
    environment["PZ_TEST_REPOSITORY"] = str(ROOT)
    if options.verbose:
        environment["PZ_TEST_VERBOSE"] = "1"
    results = []
    for path in tests:
        try:
            completed = subprocess.run(
                [options.lua, str(path)],
                cwd=ROOT,
                env=environment,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                timeout=options.timeout,
                check=False,
            )
            results.append((path, completed.returncode, completed.stdout))
        except subprocess.TimeoutExpired as error:
            output = (error.stdout or "") + "\nTIMEOUT\n"
            results.append((path, 124, output))

    failures = [result for result in results if result[1] != 0]
    for path, returncode, output in results:
        if options.verbose and output.strip():
            print(output.rstrip())
        if returncode != 0:
            print(f"FAIL {path.name}")
            print(output.rstrip())
    if failures:
        print(f"FAIL {len(failures)}/{len(results)}")
        return 1
    print(f"PASS {len(results)}/{len(tests)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
