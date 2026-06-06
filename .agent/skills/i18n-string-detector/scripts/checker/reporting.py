"""
checker/reporting.py
====================
Report generation for both i18n and Kahlua findings.
Produces a human-readable text report; can be extended for JSON output.
"""

import os
from pathlib import Path


SEP = "=" * 80
SUB = "-" * 60


# ---------------------------------------------------------------------------
# I18n Section
# ---------------------------------------------------------------------------

def format_i18n_section(
    mod_dir: Path,
    i18n_by_file: dict[Path, list[dict]],
    known_keys: set[str],
    total_scanned: int,
) -> str:
    lines: list[str] = []
    total = sum(len(v) for v in i18n_by_file.values())
    flagged = sum(1 for v in i18n_by_file.values() if v)

    lines += [SEP, "I18N — HARDCODED STRING REPORT", SEP]
    lines.append(f"Lua files scanned     : {total_scanned}")
    lines.append(f"Files with findings   : {flagged}")
    lines.append(f"Total hardcoded strs  : {total}")
    lines.append(f"Known translate keys  : {len(known_keys)}")
    lines.append("")

    if total == 0:
        lines.append("✅  No hardcoded UI strings detected.")
        return "\n".join(lines)

    sorted_files = sorted(i18n_by_file.items(), key=lambda x: len(x[1]), reverse=True)

    lines.append("TOP FILES:")
    for path, flist in sorted_files[:10]:
        if flist:
            lines.append(f"  {len(flist):>4}  {os.path.relpath(path, mod_dir)}")
    lines.append("")

    for path, flist in sorted_files:
        if not flist:
            continue
        lines.append(f"\n📄 {os.path.relpath(path, mod_dir)}")
        lines.append(SUB)
        for f in flist:
            tag = "[KNOWN KEY]      " if f["is_known_key"] else "[NOT IN TRANSLATE]"
            lines.append(f"  L{f['line']:<6} [{f['context']:<28}] {tag}  \"{f['string']}\"")

    lines.append("")
    lines.append("LEGEND:")
    lines.append("  [KNOWN KEY]       — Key is registered but string is passed RAW (not via getText/T).")
    lines.append("  [NOT IN TRANSLATE]— String has no translation key anywhere.")
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Kahlua Section
# ---------------------------------------------------------------------------

_SEV_ORDER = {"ERROR": 0, "WARNING": 1, "INFO": 2}


def format_kahlua_section(
    mod_dir: Path,
    kahlua_by_file: dict[Path, list[dict]],
    total_scanned: int,
) -> str:
    lines: list[str] = []
    total = sum(len(v) for v in kahlua_by_file.values())
    flagged = sum(1 for v in kahlua_by_file.values() if v)
    error_count = sum(
        1 for flist in kahlua_by_file.values()
        for f in flist if f["severity"] == "ERROR"
    )
    warn_count = total - error_count

    lines += [SEP, "KAHLUA — LUA 5.1 COMPATIBILITY REPORT", SEP]
    lines.append(f"Lua files scanned  : {total_scanned}")
    lines.append(f"Files with issues  : {flagged}")
    lines.append(f"Errors             : {error_count}")
    lines.append(f"Warnings           : {warn_count}")
    lines.append("")

    if total == 0:
        lines.append("✅  No Kahlua compatibility issues detected.")
        return "\n".join(lines)

    sorted_files = sorted(kahlua_by_file.items(), key=lambda x: len(x[1]), reverse=True)

    lines.append("TOP FILES:")
    for path, flist in sorted_files[:10]:
        if flist:
            e = sum(1 for f in flist if f["severity"] == "ERROR")
            w = len(flist) - e
            lines.append(f"  {len(flist):>4}  {os.path.relpath(path, mod_dir)}  (E:{e} W:{w})")
    lines.append("")

    for path, flist in sorted_files:
        if not flist:
            continue
        sorted_findings = sorted(flist, key=lambda f: (f["line"], _SEV_ORDER.get(f["severity"], 9)))
        lines.append(f"\n📄 {os.path.relpath(path, mod_dir)}")
        lines.append(SUB)
        for f in sorted_findings:
            sev_badge = f"[{f['severity']:<7}]"
            lines.append(f"  L{f['line']:<6} {sev_badge} {f['rule_id']}  {f['message']}")
            if f.get("fix"):
                lines.append(f"           ↳ Fix: {f['fix']}")
            if f.get("snippet"):
                snippet = f["snippet"].strip()[:120]
                lines.append(f"           ↳ Code: {snippet}")

    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Combined Full Report
# ---------------------------------------------------------------------------

def build_full_report(
    mod_dir: Path,
    i18n_by_file: dict,
    kahlua_by_file: dict,
    known_keys: set[str],
    total_scanned: int,
    excluded_count: int,
) -> str:
    header = [
        SEP,
        "PZ MOD CHECKER — FULL REPORT",
        SEP,
        f"Mod directory  : {mod_dir}",
        f"Files scanned  : {total_scanned}  ({excluded_count} excluded)",
        "",
    ]

    i18n_section = format_i18n_section(mod_dir, i18n_by_file, known_keys, total_scanned)
    kahlua_section = format_kahlua_section(mod_dir, kahlua_by_file, total_scanned)

    return "\n".join(header) + "\n\n" + i18n_section + "\n\n" + kahlua_section
