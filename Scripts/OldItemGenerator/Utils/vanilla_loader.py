"""
Vanilla item database loader
Extracts item definitions from Project Zomboid scripts
"""
import os
import re
from .config import VANILLA_DIR


def load_vanilla_items():
    """Load all vanilla item definitions with full properties"""
    items = {}
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
                items[item_id] = props
        except Exception as e:
            print(f"⚠️  Failed to parse {filename}: {e}")
    
    print(f"✅ Loaded {len(items)} vanilla items")
    return items


def get_stat(props, key, default=0.0):
    """Extract numeric stat from properties"""
    m = re.search(rf"{key}\s*=\s*(-?\d+\.?\d*)", props, re.IGNORECASE)
    return float(m.group(1)) if m else default


def has_property(props, key):
    """Check if property exists (boolean, string, or number)"""
    # Match any value type: numbers (including decimals and negatives), words, true/false, etc.
    return re.search(rf"{key}\s*=\s*[^\s,;]+", props, re.IGNORECASE) is not None


def get_property_value(props, key, default=""):
    """Extract string property value"""
    m = re.search(rf"{key}\s*=\s*(\w+)", props, re.IGNORECASE)
    return m.group(1) if m else default


def count_learned_recipes(props):
    """Count number of learned recipes in item"""
    return len(re.findall(r"LearnedRecipes\s*=", props))
