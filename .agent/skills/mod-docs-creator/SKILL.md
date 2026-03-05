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

- **File**: Requires detailed documentation of its core purpose, public functions/exports, dependencies, and design patterns. This should be concise but it is the most detailed part of the documentation tree.
- **Directory**: Requires an `index.txt` file acting as an overview. It should provide a high-level summary of the directory. You MUST include slightly detailed overviews per sub-system/script and heavily use `@alias` or `[path]` references so that future LLMs can easily find the specific shortcodes for the deepest details.

### 2. Formulate the Content

Draft the document ensuring it adheres to the strict `mod-docs` formatting rules. You MUST include a `Title:` and `Tags:` header at the very top of the text file.

**For a Directory Overview (`index.txt`):**
**CRITICAL RULE: An `index.txt` must NEVER exceed 40 lines of body text.** It is simply a gateway to find specific code. If you find yourself writing more than 40 lines, you are dumping too much detail. Segregate the detail into individual file documentation and link to it.

```text
Title: <Directory Module Name> Overview
Tags: [tag1, tag2, overview, index]

<High-level summary of the directory's purpose and architecture. MAXIMUM 40 LINES.>

### Sub-Systems / Scripts
- **System A**: Brief 1-sentence detail. See: [Contents/mods/.../SystemA]
- **System B**: Brief 1-sentence detail. See: [Contents/mods/.../SystemB]
```

*Note: Since shortcodes are generated AFTER you save the file, you must link to sub-systems using their `[Relative/Workspace/Path]`. The `docs.py` system will automatically resolve these paths and present the corresponding shortcodes to the user.*

**For a Specific File (`FileName.txt`):**

```text
Title: <A brief 3-7 word case-sensitive title or short summary>
Tags: [tag1, tag2, tag3]

<Your concise summary and generated documentation goes here.
 The most detailed implementation specifics go here.>
```

**For a Massive File (File-as-Directory Pattern):**
If a single file (e.g., `00_DT_Core.lua`) contains hundreds of lines and multiple major systems, DO NOT document it as a single `.txt` file, as this bloats token usage. Treat the file itself as a directory.

1. Create a directory named after the file: `docs/Contents/mods/.../00_DT_Core/`
2. Create an `index.txt` inside that directory serving as the 40-line maximum overview, just like a normal directory overview.
3. Extract specific systems into chunk files: `docs/Contents/mods/.../00_DT_Core/EconomyManager.txt`.

**CRITICAL RULE FOR MASSIVE FILE CHUNKS:** To prevent tag search contamination, chunk files MUST explicitly use the tags `[chunk, internal]` and MUST NOT use broad global tags (like `core` or `v1`). The `index.txt` will naturally list them, so they do not need global tags to be discovered.

```text
Title: Economy Manager (00_DT_Core Chunk)
Tags: [chunk, internal]

<Detailed implementation specifics of this specific system>
```

*Note: The `Tags:` header must be enclosed in square brackets `[]` and be comma-separated.*

### 3. Save the Documentation

Save the formatted content as a `.txt` file inside `.agent/skills/mod-docs/resources/docs/`.
The path of the `.txt` file inside the `docs/` folder MUST mirror the relative path of the file you are documenting within the workspace (ending in `.txt`).

**Example for a File:**

- Target workspace path: `Contents/mods/DynamicTradingV1/media/lua/client/UI.lua`
- Output doc path: `.agent/skills/mod-docs/resources/docs/Contents/mods/DynamicTradingV1/media/lua/client/UI.txt`

**Example for a Directory Overview:**

- Target workspace path: `Contents/mods/DynamicTradingV1/`
- Output doc path: `.agent/skills/mod-docs/resources/docs/Contents/mods/DynamicTradingV1/index.txt`

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
