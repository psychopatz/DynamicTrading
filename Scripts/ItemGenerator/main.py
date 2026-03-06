#!/usr/bin/env python3
"""ItemGenerator - Automated Item Registration System with modular architecture"""
import sys
from pathlib import Path
from contextlib import contextmanager
from datetime import datetime

try:
    from .Utils import load_vanilla_items, VANILLA_SCRIPTS_DIR, DISTRIBUTIONS_DIR
    from .Utils.commands import (
        find_property, list_properties, dump_property, analyze_properties,
        find_rarity, rarity_stats, analyze_spawns,
        update, add, show_stats,
    )
except ImportError:
    sys.path.insert(0, str(Path(__file__).parent))
    from Utils import load_vanilla_items, VANILLA_SCRIPTS_DIR, DISTRIBUTIONS_DIR
    from Utils.commands import (
        find_property, list_properties, dump_property, analyze_properties,
        find_rarity, rarity_stats, analyze_spawns,
        update, add, show_stats,
    )


def generate_output_filename(cmd_name):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = Path(__file__).parent / "Output"
    output_dir.mkdir(exist_ok=True)
    return str(output_dir / f"{cmd_name}_{timestamp}.md")


def save_to_markdown_file(text_content, filename):
    lines = text_content.strip().split('\n')
    md_parts = ['# Analysis Results\n']
    current_section = None
    section_lines = []
    
    for line in lines:
        if line.strip() and any(line.strip().startswith(e) for e in ['🔍', '📊', '📁', '📝', '✅', '❌']):
            if section_lines and current_section:
                md_parts.append('<details>')
                md_parts.append(f'<summary><strong>{current_section}</strong></summary>\n')
                md_parts.append('```')
                md_parts.extend(section_lines)
                md_parts.append('```')
                md_parts.append('</details>\n')
            current_section = line.strip()
            section_lines = []
        else:
            section_lines.append(line)
    
    if section_lines and current_section:
        md_parts.append('<details>')
        md_parts.append(f'<summary><strong>{current_section}</strong></summary>\n')
        md_parts.append('```')
        md_parts.extend(section_lines)
        md_parts.append('```')
        md_parts.append('</details>\n')
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write('\n'.join(md_parts))


@contextmanager
def capture_and_save_output(output_file):
    original_stdout = sys.stdout
    captured = []
    
    class Capture:
        def write(self, text):
            original_stdout.write(text)
            captured.append(text)
        def flush(self):
            original_stdout.flush()
    
    try:
        sys.stdout = Capture()
        yield
    finally:
        sys.stdout = original_stdout
        if captured:
            save_to_markdown_file(''.join(captured), output_file)


def should_save_to_file():
    if '--txt' in sys.argv:
        sys.argv.remove('--txt')
        return True
    return False


def show_help():
    """Display help information"""
    print("""
╔═══════════════════════════════════════════════════════════╗
║          ItemGenerator - Command Reference                ║
╚═══════════════════════════════════════════════════════════╝

INTERACTIVE MODE:
  python main.py                    # Launch interactive menu

ITEM MANAGEMENT:
  python main.py update             # Update prices/stock for existing items
  python main.py add [count]        # Add new items (default: 50)
  python main.py add --all          # Add all remaining items

PROPERTY ANALYSIS:
  python main.py --find-property <name> [value] [--txt]
      Search items by property name (e.g., StressChange, Alcoholic)
      Optional: filter by value
      
  python main.py --list-properties [min_usage] [--txt]
      List all properties with usage counts (default: 1)
      
  python main.py --dump-property <name> [format] [--txt]
      Dump all values for a property (formats: table, csv, dict)
      
  python main.py --analyze-properties [--txt]
      Generate comprehensive property documentation

SPAWN ANALYSIS:
  python main.py --find-rarity <tier> [--txt]
      Find items by rarity (UltraRare, Legendary, Rare, Uncommon, Common)
      
  python main.py --rarity-stats [--txt]
      Show spawn rarity distribution statistics
      
  python main.py --analyze-spawns [--txt]
      Generate comprehensive spawn rate documentation

FLAGS:
  --txt                Save output to markdown file in Output/ folder
                       (Shows full results, not truncated)
  --help               Display this help message

EXAMPLES:
  python main.py --find-property StressChange
  python main.py --find-rarity Rare --txt
  python main.py --list-properties 100 --txt
  python main.py add 200
""")


def display_menu():
    print("\n" + "=" * 60)
    print("ItemGenerator - Interactive Menu")
    print("=" * 60)
    print("\nSelect an operation:")
    print("\n📦 ITEM MANAGEMENT:")
    print("  1. Update prices & stock (existing items)")
    print("  2. Add items (custom batch size)")
    print("  3. Add all remaining items")
    print("\n🔍 PROPERTY ANALYSIS:")
    print("  4. Find items by property")
    print("  5. List all properties")
    print("  6. Analyze properties (generate docs)")
    print("\n📊 SPAWN ANALYSIS:")
    print("  7. Find items by rarity")
    print("  8. Show rarity statistics")
    print("  9. Analyze spawns (generate docs)")
    print("\n❓ OTHER:")
    print("  h. Show help")
    print("  0. Exit")
    print()
    
    while True:
        choice = input("Enter choice: ").strip().lower()
        if choice in ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'h', '0']:
            return choice
        print("❌ Invalid choice. Please enter 1-9, h, or 0.")


def get_batch_size():
    while True:
        try:
            size = int(input("Enter number of items to add (default 50): ").strip() or "50")
            if size > 0:
                return size
            print("❌ Must be a positive number.")
        except ValueError:
            print("❌ Please enter a valid number.")


def main():
    save_to_file = should_save_to_file()
    
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        
        # Show help
        if cmd in ['--help', '-h', 'help']:
            show_help()
            return
        
        if cmd == '--find-property':
            if len(sys.argv) < 3:
                print("Error: Usage: python main.py --find-property <property_name> [value_filter] [--txt]")
                sys.exit(1)
            property_name = sys.argv[2]
            value_filter = sys.argv[3] if len(sys.argv) > 3 else None
            if save_to_file:
                output_file = generate_output_filename(f"find_property_{property_name}")
                with capture_and_save_output(output_file):
                    find_property(VANILLA_SCRIPTS_DIR, property_name, value_filter)
                print(f"Output saved to: {output_file}")
            else:
                find_property(VANILLA_SCRIPTS_DIR, property_name, value_filter)
            return
        
        elif cmd == '--list-properties':
            min_usage = int(sys.argv[2]) if len(sys.argv) > 2 else 1
            if save_to_file:
                output_file = generate_output_filename("list_properties")
                with capture_and_save_output(output_file):
                    list_properties(VANILLA_SCRIPTS_DIR, min_usage)
                print(f"Output saved to: {output_file}")
            else:
                list_properties(VANILLA_SCRIPTS_DIR, min_usage)
            return
        
        elif cmd == '--dump-property':
            if len(sys.argv) < 3:
                print("Error: Usage: python main.py --dump-property <property_name> [format] [--txt]")
                sys.exit(1)
            property_name = sys.argv[2]
            output_format = sys.argv[3] if len(sys.argv) > 3 else 'table'
            if save_to_file:
                output_file = generate_output_filename(f"dump_property_{property_name}")
                with capture_and_save_output(output_file):
                    dump_property(VANILLA_SCRIPTS_DIR, property_name, output_format)
                print(f"Output saved to: {output_file}")
            else:
                dump_property(VANILLA_SCRIPTS_DIR, property_name, output_format)
            return
        
        elif cmd == '--analyze-properties':
            if save_to_file:
                output_file = generate_output_filename("analyze_properties")
                with capture_and_save_output(output_file):
                    analyze_properties(VANILLA_SCRIPTS_DIR)
                print(f"Output saved to: {output_file}")
            else:
                analyze_properties(VANILLA_SCRIPTS_DIR)
            return
        
        elif cmd == '--find-rarity':
            if len(sys.argv) < 3:
                print("Error: Usage: python main.py --find-rarity <tier> [--txt]")
                sys.exit(1)
            tier = sys.argv[2]
            if save_to_file:
                output_file = generate_output_filename(f"find_rarity_{tier}")
                with capture_and_save_output(output_file):
                    find_rarity(DISTRIBUTIONS_DIR, tier, full_output=True)
                print(f"Output saved to: {output_file}")
            else:
                find_rarity(DISTRIBUTIONS_DIR, tier, full_output=False)
            return
        
        elif cmd == '--rarity-stats':
            if save_to_file:
                output_file = generate_output_filename("rarity_stats")
                with capture_and_save_output(output_file):
                    rarity_stats(DISTRIBUTIONS_DIR)
                print(f"Output saved to: {output_file}")
            else:
                rarity_stats(DISTRIBUTIONS_DIR)
            return
        
        elif cmd == '--analyze-spawns':
            if save_to_file:
                output_file = generate_output_filename("analyze_spawns")
                with capture_and_save_output(output_file):
                    analyze_spawns(DISTRIBUTIONS_DIR, full_output=True)
                print(f"Output saved to: {output_file}")
            else:
                analyze_spawns(DISTRIBUTIONS_DIR, full_output=False)
            return
    
    print("\n📦 Loading vanilla item database...")
    vanilla_items = load_vanilla_items()
    
    if not vanilla_items:
        print("❌ Failed to load vanilla items. Exiting.")
        sys.exit(1)
    
    if len(sys.argv) == 1:
        while True:
            choice = display_menu()
            
            if choice == 'h':
                show_help()
                input("\nPress Enter to continue...")
                continue
            elif choice == '0':
                print("Exiting.")
                sys.exit(0)
            
            # Item management options need vanilla items loaded
            if choice in ['1', '2', '3']:
                show_stats(vanilla_items)
                
                if choice == '1':
                    regen = input("Regenerate tags using new tagging system? (y/n): ").lower().startswith('y')
                    update(vanilla_items, regenerate_tags=regen)
                    break
                elif choice == '2':
                    batch_size = get_batch_size()
                    add(vanilla_items, batch_size)
                    break
                elif choice == '3':
                    if input("Add ALL remaining items? (yes/no): ").lower().startswith('y'):
                        add(vanilla_items, 'all')
                    else:
                        print("Cancelled.")
                    break
            
            # Property analysis options
            elif choice == '4':
                prop_name = input("Enter property name (e.g., StressChange): ").strip()
                if prop_name:
                    value_filter = input("Enter value filter (optional, press Enter to skip): ").strip() or None
                    save_opt = input("Save to file? (y/n): ").lower().startswith('y')
                    
                    if save_opt:
                        output_file = generate_output_filename(f"find_property_{prop_name}")
                        with capture_and_save_output(output_file):
                            find_property(VANILLA_SCRIPTS_DIR, prop_name, value_filter)
                        print(f"\n✅ Output saved to: {output_file}")
                    else:
                        find_property(VANILLA_SCRIPTS_DIR, prop_name, value_filter)
                    
                    input("\nPress Enter to continue...")
            
            elif choice == '5':
                min_usage = input("Minimum usage count (default 1): ").strip()
                min_usage = int(min_usage) if min_usage.isdigit() else 1
                save_opt = input("Save to file? (y/n): ").lower().startswith('y')
                
                if save_opt:
                    output_file = generate_output_filename("list_properties")
                    with capture_and_save_output(output_file):
                        list_properties(VANILLA_SCRIPTS_DIR, min_usage)
                    print(f"\n✅ Output saved to: {output_file}")
                else:
                    list_properties(VANILLA_SCRIPTS_DIR, min_usage)
                
                input("\nPress Enter to continue...")
            
            elif choice == '6':
                save_opt = input("Save to file? (y/n): ").lower().startswith('y')
                
                if save_opt:
                    output_file = generate_output_filename("analyze_properties")
                    with capture_and_save_output(output_file):
                        analyze_properties(VANILLA_SCRIPTS_DIR)
                    print(f"\n✅ Output saved to: {output_file}")
                else:
                    analyze_properties(VANILLA_SCRIPTS_DIR)
                
                input("\nPress Enter to continue...")
            
            # Spawn analysis options
            elif choice == '7':
                print("\nRarity tiers: UltraRare, Legendary, Rare, Uncommon, Common")
                tier = input("Enter rarity tier: ").strip()
                
                if tier in ['UltraRare', 'Legendary', 'Rare', 'Uncommon', 'Common']:
                    save_opt = input("Save to file? (y/n): ").lower().startswith('y')
                    
                    if save_opt:
                        output_file = generate_output_filename(f"find_rarity_{tier}")
                        with capture_and_save_output(output_file):
                            find_rarity(DISTRIBUTIONS_DIR, tier, full_output=True)
                        print(f"\n✅ Output saved to: {output_file}")
                    else:
                        find_rarity(DISTRIBUTIONS_DIR, tier, full_output=False)
                else:
                    print("❌ Invalid tier name")
                
                input("\nPress Enter to continue...")
            
            elif choice == '8':
                save_opt = input("Save to file? (y/n): ").lower().startswith('y')
                
                if save_opt:
                    output_file = generate_output_filename("rarity_stats")
                    with capture_and_save_output(output_file):
                        rarity_stats(DISTRIBUTIONS_DIR)
                    print(f"\n✅ Output saved to: {output_file}")
                else:
                    rarity_stats(DISTRIBUTIONS_DIR)
                
                input("\nPress Enter to continue...")
            
            elif choice == '9':
                save_opt = input("Save to file? (y/n): ").lower().startswith('y')
                
                if save_opt:
                    output_file = generate_output_filename("analyze_spawns")
                    with capture_and_save_output(output_file):
                        analyze_spawns(DISTRIBUTIONS_DIR, full_output=True)
                    print(f"\n✅ Output saved to: {output_file}")
                else:
                    analyze_spawns(DISTRIBUTIONS_DIR, full_output=False)
                
                input("\nPress Enter to continue...")
    
    else:
        # Check for --regenerate-tags flag
        regenerate_tags = '--regenerate-tags' in sys.argv
        if regenerate_tags:
            sys.argv.remove('--regenerate-tags')
        
        mode = sys.argv[1].lower()
        
        if mode not in ['update', 'add']:
            print(f"❌ Invalid mode: {mode}")
            print("Usage: python main.py [update|add] [batch_size|--all] [--regenerate-tags]")
            sys.exit(1)
        
        show_stats(vanilla_items)
        
        if mode == 'add':
            if len(sys.argv) > 2:
                arg = sys.argv[2]
                if arg == '--all':
                    add(vanilla_items, 'all')
                else:
                    try:
                        batch_size = int(arg)
                        add(vanilla_items, batch_size)
                    except ValueError:
                        print(f"❌ Invalid argument: {arg}")
                        sys.exit(1)
            else:
                add(vanilla_items, 50)
        else:
            update(vanilla_items, regenerate_tags=regenerate_tags)


if __name__ == '__main__':
    main()
