"""
Vanilla item database loader
Extracts item definitions from Project Zomboid scripts
"""
import os
import re
from ..config import VANILLA_DIR
from ..parse.blacklist import is_item_blacklisted


def load_vanilla_items(apply_blacklist=True, verbose_blacklist=False):
    """
    Load all vanilla item definitions with full properties
    
    Args:
        apply_blacklist: If True, exclude blacklisted items
        verbose_blacklist: If True, print info about blacklisted items
    
    Returns:
        dict: {item_id: properties_string}
    """
    items = {}
    blacklisted_items = {}
    items_dir = os.path.join(VANILLA_DIR, "generated/items/")
    
    if not os.path.exists(items_dir):
        print(f"❌ Vanilla directory not found: {items_dir}")
        return items
    
    for filename in os.listdir(items_dir):
        if not filename.endswith('.txt'):
            continue
        
        filepath = os.path.join(items_dir, filename)
        try:
            with open(filepath, 'r', errors='ignore') as f:
                content = f.read()
            
            # Extract item blocks
            pattern = r'item\s+(\w+)\s*\{([^}]*?(?:\{[^}]*\}[^}]*?)*)\}'
            for match in re.finditer(pattern, content, re.DOTALL):
                item_id = match.group(1)
                props = match.group(2)
                
                # Check blacklist if enabled
                if apply_blacklist:
                    properties_dict = _parse_properties_for_blacklist(props)
                    is_blacklisted, reason = is_item_blacklisted(item_id, properties_dict)
                    
                    if is_blacklisted:
                        blacklisted_items[item_id] = reason
                        if verbose_blacklist:
                            print(f"[BLACKLIST] Excluding {item_id}: {reason}")
                        continue
                
                items[item_id] = props
        except Exception as e:
            print(f"⚠️  Failed to parse {filename}: {e}")
    
    if apply_blacklist and blacklisted_items:
        print(f"✅ Loaded {len(items)} vanilla items ({len(blacklisted_items)} blacklisted)")
    else:
        print(f"✅ Loaded {len(items)} vanilla items")
    
    return items


def _parse_properties_for_blacklist(props):
    """
    Parse properties string into a dict for blacklist checking
    Extracts all key=value pairs from the properties string
    
    Args:
        props: Properties string from item definition
    
    Returns:
        dict: {property_name: value}
    """
    properties = {}
    
    # Match property=value patterns
    # Handles: Property = Value, Property = "Value", Property = 1.5
    pattern = r'(\w+)\s*=\s*([^,\n]+)'
    
    for match in re.finditer(pattern, props):
        key = match.group(1).strip()
        value = match.group(2).strip()
        
        # Clean up value (remove quotes, trailing commas)
        value = value.rstrip(',').strip()
        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1]
        
        # Try to convert to number if possible
        try:
            if '.' in value:
                value = float(value)
            else:
                value = int(value)
        except ValueError:
            # Keep as string if not a number
            pass
        
        properties[key] = value
    
    return properties


def get_stat(props, key, default=0.0):
    """Extract numeric stat from properties"""
    m = re.search(rf"{key}\s*=\s*(-?\d+\.?\d*)", props, re.IGNORECASE)
    return float(m.group(1)) if m else default


def has_property(props, key):
    """Check if property exists (boolean or string)"""
    return re.search(rf"{key}\s*=\s*\w+", props, re.IGNORECASE) is not None


def get_property_value(props, key, default=""):
    """Extract string property value"""
    m = re.search(rf"{key}\s*=\s*(\w+)", props, re.IGNORECASE)
    return m.group(1) if m else default


def count_learned_recipes(props):
    """Count number of learned recipes in item"""
    return len(re.findall(r"LearnedRecipes\s*=", props))
