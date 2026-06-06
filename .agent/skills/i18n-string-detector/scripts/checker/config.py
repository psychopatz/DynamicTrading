"""
checker/config.py
=================
All shared regex constants, UI-API trigger lists, and safe-string patterns.
Adding a new trigger or exclusion pattern should happen ONLY here.
"""

import re

# ---------------------------------------------------------------------------
# I18n — UI API triggers
# Substrings that, when present on a line, indicate the immediately-adjacent
# string argument is user-visible and must go through a translation helper.
# ---------------------------------------------------------------------------
UI_API_TRIGGERS: list[str] = [
    "addOption(",
    "ISButton:new(",
    "ISLabel:new(",
    "ISPanel:new(",
    "setTitle(",
    "addText(",
    "drawText(",
    "setText(",
    "ISModalDialog(",
    "ISModalDialog.ShowDialog(",
    "playerObj:Say(",
    "self:Say(",
    "player:Say(",
    "addTextBox(",
    "tooltip =",
    "text =",
    "title =",
    "label =",
    "buttonText =",
]

# ---------------------------------------------------------------------------
# I18n — translation wrapper patterns
# A line containing any of these already routes its string through i18n.
# ---------------------------------------------------------------------------
TRANSLATION_WRAPPER_PATTERNS: list[str] = [
    r"\bgetText\s*\(",
    r"\bgetTextOrNull\s*\(",
    r"\bT\s*\(",
    r"DynamicTrading\.Text\.Get\s*\(",
    r"DT_Text\s*\[",
    r"Translations\s*\[",
]
WRAPPER_RE = re.compile("|".join(TRANSLATION_WRAPPER_PATTERNS))

# ---------------------------------------------------------------------------
# I18n — lines to skip entirely for string scanning
# ---------------------------------------------------------------------------
SKIP_LINE_PATTERNS: list[str] = [
    r"^\s*--",                         # Lua comment
    r"\bprint\s*\(",                   # print(
    r"\berror\s*\(",                   # error(
    r"\bwarn\s*\(",                    # warn(
    r"\bLog\s*\(",                     # Log(
    r"DynamicTrading\.Log\s*\(",       # DynamicTrading.Log(
    r"ZombieLuaError\s*\(",
    r"\brequire\s*[\"']",              # require "..."
    r"\bpcall\s*\(\s*require",         # pcall(require...)
    r"getTexture\s*\(",                # texture paths
    r"getSoundManager",
    r"ZomboidForge",
    r"ZombieLua",
    r"SandboxVars\.",
    r"ISUIElement",
]
SKIP_LINE_RE = re.compile("|".join(SKIP_LINE_PATTERNS))

# ---------------------------------------------------------------------------
# I18n — safe string values (never user-visible)
# ---------------------------------------------------------------------------
SAFE_STRING_PATTERNS: list[str] = [
    r"^$",                             # empty
    r"^\s+$",                          # whitespace only
    r"^[\d\.\-\+]+$",                 # pure number
    r"^[A-Z_0-9]{1,10}$",            # all-caps constant: NONE, ERROR, OK
    r"^[a-z]$",                        # single lowercase char
    r"^media/",                        # asset path
    r"^DT/",                           # DT module path
    r"^ISUI/",                         # ISUI path
    r"\.(png|jpg|ogg|wav|txt|lua|json)$",
    r"^#[0-9a-fA-F]{3,8}$",          # hex colour
    r"^\d+\.\d+\.\d+",               # version string
    r"^https?://",                     # URL
    r"^\w+\.\w+\(\)",                 # method call stub
    r"^\w+\s*=\s*\w+",               # assignment-looking value
    r"^(table|string|number|boolean|nil|function|thread|userdata)$",  # Lua types
    r"^[A-Z][A-Za-z0-9]+$",          # PascalCase identifier (internal state/enum key)
    r"^[a-z][A-Za-z0-9]+$",          # camelCase identifier
    r"^[\s\[\]\(\)\.,:/@\-]",        # starts with punctuation (concat fragment)
    r"[\s\[\]\(\)\.,:/@\-]$",        # ends with punctuation (concat fragment)
    r"^[a-z][a-z0-9_]+$",            # snake_case internal key
]
SAFE_STRING_RE = re.compile("|".join(f"(?:{p})" for p in SAFE_STRING_PATTERNS))

# ---------------------------------------------------------------------------
# Shared — Lua literal string extractor
# Matches single- and double-quoted Lua strings (non-multiline).
# ---------------------------------------------------------------------------
LUA_STRING_RE = re.compile(
    r'(?:"([^"\\]*(?:\\.[^"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\')'
)

# ---------------------------------------------------------------------------
# Shared — paths to exclude from ALL scanning
# A file is excluded if the 'Manuals' folder appears under 'common' in its path.
# ---------------------------------------------------------------------------
EXCLUDED_FOLDER_NAMES: list[str] = ["Manuals"]
EXCLUDED_UNDER_FOLDER: str = "common"
