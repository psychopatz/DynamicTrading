#!/usr/bin/env python3
"""
ItemGenerator - Automated Item Registration System
Modular architecture for generating and managing trading items with intelligent tagging

MODES:
- update: Update prices/stock for existing registered items
- add: Add new unregistered vanilla items with intelligent tagging

USAGE:
    python main.py                    # Interactive menu
    python main.py update             # Update existing items
    python main.py add 100            # Add 100 new items
    python main.py add --all          # Add all remaining items
"""
import sys
from pathlib import Path

# Handle imports for both module and direct execution
try:
    from .Utils import (
        load_vanilla_items,
        process_lua_file,
        add_new_items,
        MOD_ITEMS_DIR,
        get_registered_items,
        collect_unregistered_items
    )
except ImportError:
    # Running as direct script, not as module
    sys.path.insert(0, str(Path(__file__).parent))
    from Utils import (
        load_vanilla_items,
        process_lua_file,
        add_new_items,
        MOD_ITEMS_DIR,
        get_registered_items,
        collect_unregistered_items
    )


def display_menu():
    """Display interactive menu"""
    print("\n" + "=" * 60)
    print("ItemGenerator - Interactive Menu")
    print("=" * 60)
    print("\nSelect an operation:")
    print("  1. Update prices & stock (existing items)")
    print("  2. Add items (custom batch size)")
    print("  3. Add all remaining items")
    print("  4. Exit")
    print()
    
    while True:
        choice = input("Enter choice (1-4): ").strip()
        if choice in ['1', '2', '3', '4']:
            return choice
        print("❌ Invalid choice. Please enter 1-4.")


def get_batch_size():
    """Prompt user for batch size"""
    while True:
        try:
            size = int(input("Enter number of items to add (default 50): ").strip() or "50")
            if size > 0:
                return size
            print("❌ Must be a positive number.")
        except ValueError:
            print("❌ Please enter a valid number.")


def update_mode(vanilla_items):
    """Update prices and stock ranges for existing items"""
    print("=" * 60)
    print("ItemGenerator - UPDATE MODE")
    print("Recalculating prices and stock ranges")
    print("=" * 60)
    
    items_dir = Path(MOD_ITEMS_DIR)
    lua_files = list(items_dir.rglob("*.lua"))
    print(f"\n🔍 Found {len(lua_files)} Lua files to process")
    
    total_updates = 0
    for lua_file in lua_files:
        updates = process_lua_file(lua_file, vanilla_items, dry_run=False)
        total_updates += updates
    
    print("\n" + "=" * 60)
    print(f"✅ COMPLETE: Updated {total_updates} items across {len(lua_files)} files")
    print("=" * 60)
    
    return total_updates


def add_mode(vanilla_items, batch_size):
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


def main():
    """Main entry point with interactive and CLI modes"""
    
    # Determine mode from command line arguments
    if len(sys.argv) == 1:
        # No arguments - interactive mode
        choice = display_menu()
        
        # Load vanilla database
        print("\n📦 Loading vanilla item database...")
        vanilla_items = load_vanilla_items()
        
        if not vanilla_items:
            print("❌ Failed to load vanilla items. Exiting.")
            sys.exit(1)
        
        show_stats(vanilla_items)
        
        if choice == '1':
            update_mode(vanilla_items)
        elif choice == '2':
            batch_size = get_batch_size()
            add_mode(vanilla_items, batch_size)
        elif choice == '3':
            if input("Add ALL remaining items? (yes/no): ").lower().startswith('y'):
                add_mode(vanilla_items, 'all')
            else:
                print("Cancelled.")
        else:  # choice == '4'
            print("Exiting.")
            sys.exit(0)
    else:
        # CLI mode with arguments
        mode = sys.argv[1].lower()
        
        # Validate mode
        if mode not in ['update', 'add']:
            print(f"❌ Invalid mode: {mode}")
            print("Usage: python main.py [update|add] [batch_size|--all]")
            sys.exit(1)
        
        # Load vanilla database
        print("\n📦 Loading vanilla item database...")
        vanilla_items = load_vanilla_items()
        
        if not vanilla_items:
            print("❌ Failed to load vanilla items. Exiting.")
            sys.exit(1)
        
        show_stats(vanilla_items)
        
        # Handle add mode with batch size or --all
        if mode == 'add':
            if len(sys.argv) > 2:
                arg = sys.argv[2]
                if arg == '--all':
                    add_mode(vanilla_items, 'all')
                else:
                    try:
                        batch_size = int(arg)
                        add_mode(vanilla_items, batch_size)
                    except ValueError:
                        print(f"❌ Invalid argument: {arg}")
                        print("Usage: python main.py add [number|--all]")
                        sys.exit(1)
            else:
                # Default batch size for add if not specified
                add_mode(vanilla_items, 50)
        else:
            update_mode(vanilla_items)


if __name__ == '__main__':
    main()


if __name__ == "__main__":
    main()
