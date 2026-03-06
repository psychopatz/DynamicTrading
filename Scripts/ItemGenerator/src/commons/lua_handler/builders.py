"""Builders for Lua registry file content."""
# pyright: reportMissingImports=false

from pathlib import Path

from ...config import MOD_ITEMS_DIR, CATEGORY_FILE_MAP


def build_lua_file_content(filename, category, items_body_text=''):
    """Build full Lua file content in DynamicTrading.RegisterBatch format."""
    registry_name = filename.replace('DT_', '').replace('_', ' ').strip() or 'Items'
    batch_body = items_body_text.rstrip()
    if batch_body:
        batch_body = '\n' + batch_body + '\n'
    else:
        batch_body = '\n'

    return f'''-- ============================================================================
-- {category} Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({{{batch_body}}})

print("[DynamicTrading] {registry_name} Registry Complete")
'''


def ensure_lua_files_exist():
    """Create initial Lua files if they don't exist."""
    base_dir = Path(MOD_ITEMS_DIR)
    base_dir.mkdir(parents=True, exist_ok=True)

    files_needed = set()
    for _, subcat_map in CATEGORY_FILE_MAP.items():
        for file_path in subcat_map.values():
            files_needed.add(file_path)

    created_count = 0
    for file_path in sorted(files_needed):
        full_path = base_dir / file_path

        if full_path.exists():
            continue

        full_path.parent.mkdir(parents=True, exist_ok=True)
        category = file_path.split('/')[0] if '/' in file_path else 'Misc'
        filename = file_path.split('/')[-1].replace('.lua', '')

        lua_content = build_lua_file_content(filename, category)
        with open(full_path, 'w', encoding='utf-8') as handle:
            handle.write(lua_content)
        created_count += 1
        print(f"   ✅ Created {file_path}")

    return created_count
