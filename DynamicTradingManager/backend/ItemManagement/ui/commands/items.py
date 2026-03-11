"""
Item registration and management commands
"""
from pathlib import Path
from ...commons.lua_handler import (
    process_lua_file,
    add_new_items,
    get_registered_items,
    collect_unregistered_items,
    add_items_to_file,
    build_lua_file_content,
)
from ...commons.vanilla_loader import load_vanilla_items
from ...config import MOD_ITEMS_DIR


def update(vanilla_items, regenerate_tags=False):
    """Update prices and stock ranges for existing items
    
    Args:
        vanilla_items: Dictionary of vanilla items
        regenerate_tags: If True, regenerate tags using new tagging system
    """
    print("=" * 60)
    print("ItemGenerator - UPDATE MODE")
    print("Recalculating prices and stock ranges")
    if regenerate_tags:
        print("(Tags will be regenerated using new tagging system)")
    print("=" * 60)
    
    items_dir = Path(MOD_ITEMS_DIR)
    lua_files = list(items_dir.rglob("*.lua"))
    print(f"\n🔍 Found {len(lua_files)} Lua files to process")
    
    total_updates = 0
    for lua_file in lua_files:
        updates = process_lua_file(lua_file, vanilla_items, dry_run=False, regenerate_tags=regenerate_tags)
        total_updates += updates
    
    print("\n" + "=" * 60)
    print(f"✅ COMPLETE: Updated {total_updates} items across {len(lua_files)} files")
    print("=" * 60)
    
    return total_updates


def add(vanilla_items, batch_size):
    """Add new unregistered items with intelligent tagging"""
    print("=" * 60)
    print("ItemGenerator - ADD MODE")
    print(f"Adding {'all remaining' if batch_size == 'all' else batch_size} vanilla items with intelligent tagging")
    print("=" * 60)
    
    total_added = add_new_items(vanilla_items, batch_size if batch_size != 'all' else None)
    
    print("\n" + "=" * 60)
    print(f"✅ COMPLETE: Added {total_added} new items")
    print("=" * 60)
    
    return total_added


def show_stats(vanilla_items):
    """Show registration stats"""
    print("\n📊 Registration Statistics:")
    registered = get_registered_items()
    unregistered = collect_unregistered_items(vanilla_items, registered)
    
    print(f"   Total vanilla items:     {len(vanilla_items)}")
    print(f"   Registered items:        {len(registered)}")
    print(f"   Unregistered items:      {len(unregistered)}")
    print(f"   Coverage:                {len(registered)/len(vanilla_items)*100:.1f}%")
    print()


def delete_all_items(force=False):
    """Delete all registered items from Lua files (reset item registries)"""
    print("\n" + "=" * 60)
    print("🗑️  DELETE ALL ITEMS - Reset Item Registries")
    print("=" * 60)
    
    items_dir = Path(MOD_ITEMS_DIR)
    if not items_dir.exists():
        print("\n⚠️  No items directory found. Nothing to delete.")
        return 0
    
    lua_files = list(items_dir.rglob("*.lua"))
    if not lua_files:
        print("\n⚠️  No Lua files found. Nothing to delete.")
        return 0
    
    print(f"\n🔍 Found {len(lua_files)} Lua files")
    
    # Count items before deletion
    registered = get_registered_items()
    total_items = len(registered)
    
    print(f"📋 Total items to delete: {total_items}")
    print("\n⚠️  WARNING: This will permanently delete all registered items!")
    print("   All Lua files will be reset to empty state.")
    
    if force:
        print("\n⚡ Force mode enabled. Skipping confirmation.")
        confirm = "DELETE"
    else:
        confirm = input("\n❓ Type 'DELETE' to confirm: ").strip()
    
    if confirm != "DELETE":
        print("\n❌ Deletion cancelled.")
        return 0
    
    print("\n🗑️  Deleting items...")
    
    # Reset each Lua file to empty state
    deleted_count = 0
    for lua_file in lua_files:
        try:
            # Read the file to preserve header
            content = lua_file.read_text(encoding='utf-8')
            
            # Extract file name and category from path
            filename = lua_file.stem
            category = lua_file.parent.name if lua_file.parent.name != MOD_ITEMS_DIR.split('/')[-1] else 'Misc'
            
            # Create empty Lua file in DynamicTrading.RegisterBatch format
            new_content = build_lua_file_content(filename, category)
            
            lua_file.write_text(new_content, encoding='utf-8')
            
            # Count items deleted from this file
            import re
            pattern = re.compile(r'\s*\{\s*item\s*=')
            matches = pattern.findall(content)
            deleted_count += len(matches)
            
            print(f"  ✅ Reset: {lua_file.relative_to(items_dir)}")
        
        except Exception as e:
            print(f"  ❌ Error resetting {lua_file.name}: {e}")
    
    print(f"\n✅ Deleted {deleted_count} items from {len(lua_files)} files")
    print("=" * 60)
    
    return deleted_count
