#!/usr/bin/env python3
"""ItemGenerator - Automated Item Registration System with modular architecture"""
import sys
from pathlib import Path
from contextlib import contextmanager
from datetime import datetime

try:
    from .src import load_vanilla_items, VANILLA_SCRIPTS_DIR, DISTRIBUTIONS_DIR
    from .src.ui.commands import (
        find_property, list_properties, dump_property, analyze_properties,
        find_rarity, rarity_stats, analyze_spawns,
        update, add, show_stats,
        show_blacklist_stats, show_blacklist, add_to_blacklist, remove_from_blacklist,
        cleanup_blacklist,
    )
    from .src.ui import display_mod_stats, display_interactive_menu, handle_menu_choice
except ImportError:
    sys.path.insert(0, str(Path(__file__).parent))
    from src import load_vanilla_items, VANILLA_SCRIPTS_DIR, DISTRIBUTIONS_DIR
    from src.ui.commands import (
        find_property, list_properties, dump_property, analyze_properties,
        find_rarity, rarity_stats, analyze_spawns,
        update, add, show_stats,
        show_blacklist_stats, show_blacklist, add_to_blacklist, remove_from_blacklist,
        cleanup_blacklist,
    )
    from src.ui import display_mod_stats, display_interactive_menu, handle_menu_choice


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


def parse_chunk_limit():
    """Parse optional --chunk [size] flag. Returns None when not set."""
    if '--chunk' not in sys.argv:
        return None

    idx = sys.argv.index('--chunk')
    sys.argv.pop(idx)

    # Default chunk size when flag is present without a value.
    chunk_limit = 20
    if idx < len(sys.argv):
        try:
            parsed = int(sys.argv[idx])
            if parsed > 0:
                chunk_limit = parsed
                sys.argv.pop(idx)
        except ValueError:
            pass

    return chunk_limit





def main():
    save_to_file = should_save_to_file()
    chunk_limit = parse_chunk_limit()
    
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        
        # Show help
        if cmd in ['--help', '-h', 'help']:
            try:
                from .src.ui.menu import show_help
            except ImportError:
                from src.ui.menu import show_help
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
                    find_property(VANILLA_SCRIPTS_DIR, property_name, value_filter, chunk_limit=chunk_limit)
                print(f"Output saved to: {output_file}")
            else:
                find_property(VANILLA_SCRIPTS_DIR, property_name, value_filter, chunk_limit=chunk_limit)
            return
        
        elif cmd == '--list-properties':
            min_usage = int(sys.argv[2]) if len(sys.argv) > 2 else 1
            if save_to_file:
                output_file = generate_output_filename("list_properties")
                with capture_and_save_output(output_file):
                    list_properties(VANILLA_SCRIPTS_DIR, min_usage, chunk_limit=chunk_limit)
                print(f"Output saved to: {output_file}")
            else:
                list_properties(VANILLA_SCRIPTS_DIR, min_usage, chunk_limit=chunk_limit)
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
                    analyze_properties(VANILLA_SCRIPTS_DIR, chunk_limit=chunk_limit)
                print(f"Output saved to: {output_file}")
            else:
                analyze_properties(VANILLA_SCRIPTS_DIR, chunk_limit=chunk_limit)
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
        
        # Blacklist management commands
        elif cmd == '--blacklist-show':
            show_blacklist()
            return
        
        elif cmd == '--blacklist-stats':
            show_blacklist_stats()
            return
        
        elif cmd == '--blacklist-add-id':
            if len(sys.argv) < 3:
                print("Error: Usage: python main.py --blacklist-add-id <item_id>")
                sys.exit(1)
            item_id = sys.argv[2]
            add_to_blacklist(item_id=item_id)
            return
        
        elif cmd == '--blacklist-add-prop':
            if len(sys.argv) < 3:
                print("Error: Usage: python main.py --blacklist-add-prop <property_name>")
                sys.exit(1)
            prop_name = sys.argv[2]
            add_to_blacklist(property_name=prop_name)
            return
        
        elif cmd == '--blacklist-add-value':
            if len(sys.argv) < 4:
                print("Error: Usage: python main.py --blacklist-add-value <property_name> <value>")
                sys.exit(1)
            prop_name = sys.argv[2]
            value = sys.argv[3]
            # Try to convert to number
            try:
                if '.' in value:
                    value = float(value)
                else:
                    value = int(value)
            except ValueError:
                pass  # Keep as string
            add_to_blacklist(property_value=(prop_name, value))
            return
        
        # Blacklist cleanup
        elif cmd == '--blacklist-cleanup':
            dry_run = '--dry-run' in sys.argv
            if dry_run:
                sys.argv.remove('--dry-run')
            
            print("\n📦 Loading vanilla item database...")
            vanilla_items = load_vanilla_items(apply_blacklist=False)
            
            if not vanilla_items:
                print("❌ Failed to load vanilla items. Exiting.")
                sys.exit(1)
            
            cleanup_blacklist(vanilla_items, dry_run=dry_run)
            return
    
    print("\n📦 Loading vanilla item database...")
    vanilla_items = load_vanilla_items()
    
    if not vanilla_items:
        print("❌ Failed to load vanilla items. Exiting.")
        sys.exit(1)
    
    # Interactive mode - no command-line arguments
    if len(sys.argv) == 1:        
        while True:
            # Display mod statistics before the menu
            display_mod_stats(vanilla_items)
            
            # Display menu and get choice
            choice = display_interactive_menu()
            
            # Handle the menu choice
            should_exit = handle_menu_choice(
                choice, 
                vanilla_items, 
                chunk_limit, 
                VANILLA_SCRIPTS_DIR, 
                DISTRIBUTIONS_DIR
            )
            
            if should_exit:
                break
    
    # CLI command mode - update or add
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
