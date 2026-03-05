# Mod Docs Usage Examples

## 1. Using Slugs

Retrieve documentation using a compressed alias.

```bash
python3 .agent/skills/mod-docs/scripts/docs.py --docs economy
```

## 2. Using Workspace Paths

Retrieve documentation using a raw path. The tool will verify the path in the workspace first.

```bash
python3 .agent/skills/mod-docs/scripts/docs.py --docs Contents/mods/DynamicTradingV1
```

## 3. Verifying Syntax

Check all documentation files for proper `Title:` and `Tags:` headers.

```bash
python3 .agent/skills/mod-docs/scripts/docs.py --verify
```

## 4. Understanding Related Topics

- **Directory Mode**: Lists sub-files, deep sub-folders, and tag-matched registry items.
- **File Mode**: Lists tag-matched items and embedded references (`@slug`).
