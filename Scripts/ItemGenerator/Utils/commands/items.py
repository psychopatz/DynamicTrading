"""
Item registration and management commands
"""
from pathlib import Path
from ..commons.lua_handler import process_lua_file, add_new_items, get_registered_items, collect_unregistered_items, add_items_to_file
from ..commons.vanilla_loader import load_vanilla_items
from ..config import MOD_ITEMS_DIR


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
