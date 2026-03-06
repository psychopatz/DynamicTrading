---
name: mod-docs-creator
description: Generates and formats new documentation files for the mod-docs system. Use this when asked to define, document, or summarize a script, feature, or directory for the Dynamic Trading project.
---

# Mod Docs Creator

This skill provides step-by-step guidance on how to create and properly file documentation for the project using the `mod-docs` system. The `mod-docs` system enables low-token-cost documentation retrieval for agents by using strict formatting and file placement conventions.

## When to use this skill

- Whenever you are asked to "write docs for X", "document this file", or "add this to the documentation".
- When you have analyzed a new script or system and want to persist your findings for future context retrieval.

## How to use it

### 1. Analyze and Determine Scope (File vs Directory)

Identify if you are documenting a single file or an entire directory:

### 2. Drafting the Documentation

**CRITICAL RULE - RELATIVE PATH MIRRORING:** You MUST mirror the exact relative path of the target file inside the `docs/` directory. If you are documenting `/Contents/mods/DynamicTradingCommon/.../00_DT_Core.lua`, you MUST create the documentation inside `docs/Contents/mods/DynamicTradingCommon/.../00_DT_Core/`.

**UNIVERSAL STANDARD: The "Folder-First-Index-Blueprint" Pattern**
To maintain token efficiency and ensure accurate discovery, **every code file MUST be documented as a folder** containing an `index.txt` and separate subordinate files for implementation details.

1. **Create the Folder**: Name it after the file (without extension): `docs/.../TargetFileName/`
2. **Create the Blueprint Index**: Create `docs/.../TargetFileName/index.txt`. Its body MUST strictly follow this blueprint:

   ```text
   Title: <Case-sensitive title>
   Tags: [script, <system-name>]

   LOCATION: <Relative Workspace Path of the code file>
   PURPOSE: <1-2 sentences explaining the core intent of this script>
   OVERVIEW: <High-level architecture, key data structures, and the main logical workflow>
   DEPENDENCIES: <List of upstream systems or required modules>
   REMARKS: <Critical notes, performance warnings, or MP-safety caveats>
   ```

3. **Segregate Subordinates (Sidecar Files)**: Move ALL detailed implementation logic, function descriptions, and sub-systems into separate `.txt` files in the SAME directory (e.g., `RecursionLogic.txt`).
   - Use the tags `[chunk, internal]` for these files.
   - **CRITICAL RULE**: DO NOT manually list or link these sub-files in the `index.txt`. The `docs.py` system automatically detects nearby files and presents them to the user in the "Related Topics" section.

*Note: Shortcodes are generated AFTER you save. If you need to cross-reference a DIFFERENT system, use its `[Relative/Workspace/Path]`. `docs.py` will resolve it.*

### 3. Save the Documentation

**CRITICAL RULE: EXACT PATH MIRRORING**
If you fail to mirror the exact path, the agent documentation search system will break and the shortcodes will be orphaned.
The path inside `.agent/skills/mod-docs/resources/docs/` MUST precisely match the directory structure of the original file.

**Example: Documenting a File (Universal Folder Standard):**

- Original File Path: `Contents/mods/DynamicTradingV1/media/lua/client/UI.lua`
- ✅ CORRECT Action: Create a folder named `UI/` mirroring that exact path.
  - Create Overview File: `.agent/skills/mod-docs/resources/docs/Contents/mods/DynamicTradingV1/media/lua/client/UI/index.txt`
  - Create Logic Chunk: `.agent/skills/mod-docs/resources/docs/Contents/mods/DynamicTradingV1/media/lua/client/UI/ButtonLogic.txt`
- ❌ INCORRECT Action (Dumping flat files): Creating `.agent/skills/mod-docs/resources/docs/UI.txt`
- ❌ INCORRECT Action (Old single-file format): Creating `.agent/skills/mod-docs/resources/docs/Contents/mods/DynamicTradingV1/media/lua/client/UI.txt`

**Example: Documenting a Main Directory Overview:**

- Target workspace path: `Contents/mods/DynamicTradingV1/`
- ✅ CORRECT Action: `.agent/skills/mod-docs/resources/docs/Contents/mods/DynamicTradingV1/index.txt`

### 4. Verify Syntax

Once the file is saved, you MUST run the verification tool to ensure there are no syntax errors or orphaned files. This will also ensure it's been properly auto-indexed.

```bash
python3 .agent/skills/mod-docs/scripts/docs.py --verify
```

### 5. Register an Explicit Alias/Slug (Optional but Recommended for Major Systems)

By default, the `docs.py` system auto-indexes files placed in the `docs` directory, but accessing them requires knowing their long path. For major systems or frequently accessed files, add an entry to `.agent/skills/mod-docs/resources/registry.json`.

**How to update registry.json:**
Find the main registry object and add a new key representing a simple, human-readable slug:

```json
"my-new-system": {
    "path": "Contents/mods/DynamicTradingV1/MyNewSystem",
    "desc": "<Same as Title: from the doc>",
    "tags": ["tag1", "tag2"]
}
```

*Note: Ensure the `path` key matches the relative path without the `.txt` extension.*
