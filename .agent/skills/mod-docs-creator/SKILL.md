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

### 1. Analyze and Summarize Target

Read the target script, Lua file, or module directory. Summarize its core purpose, public functions/exports, dependencies, and important design patterns. **Keep it concise**. The goal is to provide enough context for another agent to understand the file without reading the whole source, avoiding overly verbose data.

### 2. Formulate the Content

Draft the document ensuring it adheres to the strict `mod-docs` formatting rules. You MUST include a `Title:` and `Tags:` header at the very top of the text file.

```text
Title: <A brief 3-7 word case-sensitive title or short summary>
Tags: [tag1, tag2, tag3]

<Your concise summary and generated documentation goes here.
 You may use markdown and '@' references to link to other documented concepts if needed.>
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
