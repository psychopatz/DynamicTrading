"""Statistics display for mod state summary"""

from pathlib import Path
from ..config import MOD_ITEMS_DIR
from ..parse.blacklist import find_invalid_blacklist_ids, find_duplicate_blacklist_ids
from ..parse.overrides import find_invalid_overrides, find_duplicate_overrides
import re


def count_registered_items():
    """Count items currently registered in Lua files"""
    mod_dir = Path(MOD_ITEMS_DIR)
    if not mod_dir.exists():
        return 0
    
    total_items = 0
    pattern = re.compile(r'\["([^"]+)"\]\s*=\s*\{')
    
    for lua_file in mod_dir.rglob("*.lua"):
        try:
            content = lua_file.read_text(encoding='utf-8')
            matches = pattern.findall(content)
            total_items += len(matches)
        except Exception:
            continue
    
    return total_items


def display_notifications():
    """Display warnings/notifications about configuration issues"""
    notifications = []
    
    # Check blacklist for issues
    invalid_blacklist = find_invalid_blacklist_ids()
    duplicate_blacklist = find_duplicate_blacklist_ids()
    
    # Check overrides for issues
    invalid_overrides = find_invalid_overrides()
    duplicate_overrides = find_duplicate_overrides()
    
    # Build notification messages
    if invalid_blacklist:
        notifications.append(f"⚠️  {len(invalid_blacklist)} invalid item ID(s) in blacklist")
    
    if duplicate_blacklist:
        notifications.append(f"⚠️  {len(duplicate_blacklist)} duplicate item ID(s) in blacklist")
    
    if invalid_overrides:
        notifications.append(f"⚠️  {len(invalid_overrides)} invalid override(s) detected")
    
    if duplicate_overrides:
        notifications.append(f"⚠️  {len(duplicate_overrides)} duplicate item ID(s) in overrides")
    
    # Display notifications if any exist
    if notifications:
        print("\n" + "╔" + "═" * 58 + "╗")
        print("║" + " " * 18 + "⚠️  NOTIFICATIONS" + " " * 23 + "║")
        print("╚" + "═" * 58 + "╝")
        print()
        for notification in notifications:
            print(f"  {notification}")
        print()
        print("  💡 Run menu options 3, 4 (blacklist) or 6, 7 (overrides) for details")


def display_mod_stats(vanilla_items):
    """Display summary statistics before the interactive menu"""
    # Display notifications first
    display_notifications()
    
    total_vanilla = len(vanilla_items)
    registered = count_registered_items()
    unregistered = total_vanilla - registered
    coverage = (registered / total_vanilla * 100) if total_vanilla > 0 else 0
    
    print("\n" + "╔" + "═" * 58 + "╗")
    print("║" + " " * 15 + "📊 MOD STATUS SUMMARY" + " " * 22 + "║")
    print("╚" + "═" * 58 + "╝")
    
    print(f"\n  📦 Total Vanilla Items:    {total_vanilla:>6,}")
    print(f"  🏪 Total Modded Items:     {0:>6,}  (implementation later)")
    print(f"  ✅ Registered Items:       {registered:>6,}")
    print(f"  ⏳ Unregistered Items:     {unregistered:>6,}")
    print(f"  📈 Coverage:               {coverage:>6.1f}%")
    print()
