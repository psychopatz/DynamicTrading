"""
Lua file handler for reading and writing item registrations
"""
# pyright: reportMissingImports=false

import re
from pathlib import Path
from collections import defaultdict
import importlib.util
from ..config import MOD_ITEMS_DIR, CATEGORY_FILE_MAP
from ..tagging import parse_tags, generate_tags, is_excluded, get_category_from_tags
from ..stock import calculate_base_max_stock, apply_category_multiplier, calculate_min_stock
from .vanilla_loader import get_stat

# Load legacy pricing.py directly to avoid conflict with Utils/pricing package.
_utils_dir = Path(__file__).parent.parent
_pricing_spec = importlib.util.spec_from_file_location("_dt_pricing", _utils_dir / "pricing.py")
_pricing_module = importlib.util.module_from_spec(_pricing_spec)
_pricing_spec.loader.exec_module(_pricing_module)
calculate_price = _pricing_module.calculate_price


def ensure_lua_files_exist():
    """Create initial Lua files if they don't exist"""
    base_dir = Path(MOD_ITEMS_DIR)
    base_dir.mkdir(parents=True, exist_ok=True)
    
    # Collect all unique files from CATEGORY_FILE_MAP
    files_needed = set()
    for category, subcat_map in CATEGORY_FILE_MAP.items():
        for file_path in subcat_map.values():
            files_needed.add(file_path)
    
    created_count = 0
    for file_path in sorted(files_needed):
        full_path = base_dir / file_path
        
        if not full_path.exists():
            # Create parent directories
            full_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Create empty Lua file with header
            category = file_path.split('/')[0] if '/' in file_path else 'Misc'
            filename = file_path.split('/')[-1].replace('.lua', '')
            
            lua_content = f"""-- ============================================================================
-- {filename}.lua
-- {category} Items Registry for Dynamic Trading
-- Auto-generated item list with pricing and stock ranges
-- ============================================================================

{filename} = {filename} or {{}}
{filename}.items = {{

}}

return {filename}.items
"""
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(lua_content)
            created_count += 1
            print(f"   ✅ Created {file_path}")
    
    return created_count


def process_lua_file(filepath, vanilla_items, dry_run=False):
    """Process a single Lua file and update prices/stock"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    pattern = r'\{\s*item="Base\.(\w+)",\s*basePrice=(\d+),\s*tags=(\{[^}]+\}),\s*stockRange=(\{[^}]+\})\s*\}'
    
    updates = []
    matches = list(re.finditer(pattern, content))
    
    print(f"\n📄 Processing: {filepath.name}")
    print(f"   Found {len(matches)} items")
    
    for match in matches:
        item_id = match.group(1)
        old_price = int(match.group(2))
        tags_str = match.group(3)
        stock_str = match.group(4)
        
        props = vanilla_items.get(item_id, "")
        tags_dict = parse_tags(tags_str)
        new_price = calculate_price(item_id, props, tags_dict)
        
        weight = get_stat(props, "Weight", 0.5) if props else 0.5
        category, subcategories = get_category_from_tags(tags_dict)
        base_max = calculate_base_max_stock(weight)
        final_max = apply_category_multiplier(base_max, tags_dict, subcategories)
        final_min = calculate_min_stock(final_max, tags_dict, subcategories)
        
        new_stock_str = f"{{min={final_min}, max={final_max}}}"
        new_entry = f'{{ item="Base.{item_id}", basePrice={new_price}, tags={tags_str}, stockRange={new_stock_str} }}'
        
        if new_price != old_price or new_stock_str != stock_str:
            updates.append({
                'old': match.group(0),
                'new': new_entry,
                'item_id': item_id,
                'old_price': old_price,
                'new_price': new_price,
                'old_stock': stock_str,
                'new_stock': new_stock_str
            })
    
    if updates and not dry_run:
        new_content = content
        for update in updates:
            new_content = new_content.replace(update['old'], update['new'], 1)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"   ✅ Updated {len(updates)} items")
    elif updates:
        print(f"   🔍 [DRY RUN] Would update {len(updates)} items:")
        for u in updates[:3]:
            print(f"      {u['item_id']}: ${u['old_price']} → ${u['new_price']}, {u['old_stock']} → {u['new_stock']}")
        if len(updates) > 3:
            print(f"      ... and {len(updates) - 3} more")
    else:
        print(f"   ✓ No changes needed")
    
    return len(updates)


def get_registered_items():
    """Get set of all currently registered item IDs"""
    registered = set()
    items_dir = Path(MOD_ITEMS_DIR)
    lua_files = list(items_dir.rglob("*.lua"))
    
    pattern = r'item="Base\.(\w+)"'
    for lua_file in lua_files:
        try:
            with open(lua_file, 'r', encoding='utf-8') as f:
                content = f.read()
                matches = re.findall(pattern, content)
                registered.update(matches)
        except Exception as e:
            print(f"⚠️  Error reading {lua_file.name}: {e}")
    
    return registered


def collect_unregistered_items(vanilla_items, registered_items):
    """Collect all vanilla items not yet registered"""
    unregistered = {}
    
    for item_id, props in vanilla_items.items():
        if item_id in registered_items:
            continue
        
        if is_excluded(item_id):
            continue
        
        if not props or len(props.strip()) < 10:
            continue
        
        unregistered[item_id] = props
    
    return unregistered


def group_items_by_category(items_dict):
    """Group items by their primary category"""
    grouped = defaultdict(list)
    
    for item_id, props in items_dict.items():
        tags = generate_tags(item_id, props)
        primary_tag = tags[0]
        category = primary_tag.split('.')[0]
        
        grouped[category].append({
            'item_id': item_id,
            'props': props,
            'tags': tags,
            'primary_tag': primary_tag
        })
    
    return grouped


def create_item_entry(item_data, vanilla_items):
    """Create a Lua entry for an item"""
    item_id = item_data['item_id']
    props = item_data['props']
    tags = item_data['tags']
    
    tags_dict = {
        'primary': tags[0],
        'rarity': 'Common',
        'quality': None,
        'origin': None,
        'theme': []
    }
    
    for tag in tags:
        if tag.startswith('Rarity.'):
            tags_dict['rarity'] = tag.split('.')[1]
        elif tag.startswith('Quality.'):
            tags_dict['quality'] = tag.split('.')[1]
        elif tag.startswith('Origin.'):
            tags_dict['origin'] = tag.split('.')[1]
        elif tag.startswith('Theme.'):
            tags_dict['theme'].append(tag)
    
    price = calculate_price(item_id, props, tags_dict)
    
    weight = get_stat(props, "Weight", 0.5) if props else 0.5
    category, subcategories = get_category_from_tags(tags_dict)
    base_max = calculate_base_max_stock(weight)
    final_max = apply_category_multiplier(base_max, tags_dict, subcategories)
    final_min = calculate_min_stock(final_max, tags_dict, subcategories)
    
    tags_str = ', '.join([f'"{tag}"' for tag in tags])
    entry = f'    {{ item="Base.{item_id}", basePrice={price}, tags={{{tags_str}}}, stockRange={{min={final_min}, max={final_max}}} }},'
    
    return entry


def add_items_to_file(filepath, new_items):
    """Add new items to existing Lua file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    insertion_point = None
    items_start = content.find('.items = {')
    if items_start != -1:
        newline_pos = content.find('\n', items_start)
        if newline_pos != -1:
            insertion_point = newline_pos + 1
    
    if insertion_point is None:
        print(f"  ⚠️  Cannot find insertion point in {filepath.name}")
        return 0
    
    new_items_text = '    -- Added by ItemGenerator\n'
    for item_data in new_items:
        entry = create_item_entry(item_data, {})
        new_items_text += entry + '\n'
    
    new_items_text += '\n'
    
    new_content = content[:insertion_point] + new_items_text + content[insertion_point:]
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    return len(new_items)


def determine_target_file(category, subcategory):
    """Determine which Lua file to add items to"""
    if category in CATEGORY_FILE_MAP:
        subcat_map = CATEGORY_FILE_MAP[category]
        for key in subcat_map:
            if key in subcategory:
                return Path(MOD_ITEMS_DIR) / subcat_map[key]
        
        return Path(MOD_ITEMS_DIR) / list(subcat_map.values())[0]
    
    return Path(MOD_ITEMS_DIR) / 'Misc/DT_General.lua'


def add_new_items(vanilla_items, batch_size=50):
    """Add new unregistered items to the trading system"""
    print("\n" + "=" * 60)
    print("Adding New Unregistered Items")
    print("=" * 60)
    
    print("\n✓ Initializing Lua file structure...")
    ensure_lua_files_exist()
    
    print("\n📋 Collecting registered items...")
    registered = get_registered_items()
    print(f"   Found {len(registered)} registered items")
    
    print("\n🔍 Finding unregistered items...")
    unregistered = collect_unregistered_items(vanilla_items, registered)
    print(f"   Found {len(unregistered)} unregistered items")
    
    if not unregistered:
        print("\n✅ All vanilla items are already registered!")
        return 0
    
    if batch_size is not None and len(unregistered) > batch_size:
        print(f"\n⚠️  Limiting to {batch_size} items per run")
        unregistered = dict(list(unregistered.items())[:batch_size])
    
    print("\n🗂️  Categorizing items...")
    grouped = group_items_by_category(unregistered)
    
    total_added = 0
    for category, items in grouped.items():
        print(f"\n📁 {category}: {len(items)} items")
        
        by_subcat = defaultdict(list)
        for item_data in items:
            primary = item_data['primary_tag']
            parts = primary.split('.')
            subcat = parts[1] if len(parts) > 1 else 'General'
            by_subcat[subcat].append(item_data)
        
        for subcat, subcat_items in by_subcat.items():
            target_file = determine_target_file(category, subcat)
            
            if not target_file.exists():
                print(f"  ⚠️  File not found: {target_file.name}, skipping {len(subcat_items)} items")
                continue
            
            try:
                added = add_items_to_file(target_file, subcat_items)
                total_added += added
                print(f"  ✅ Added {added} items to {target_file.name}")
            except Exception as e:
                print(f"  ❌ Error adding to {target_file.name}: {e}")
    
    return total_added
