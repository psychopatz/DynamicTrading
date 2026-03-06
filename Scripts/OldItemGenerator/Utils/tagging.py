"""
Tagging system for intelligent item categorization
Generates nested tags based on item properties and ID patterns
"""
import re
from .vanilla_loader import get_stat, has_property, count_learned_recipes
from .config import EXCLUDED_PATTERNS


def is_excluded(item_id):
    """Check if item should be excluded from registration"""
    for pattern in EXCLUDED_PATTERNS:
        if re.search(pattern, item_id, re.IGNORECASE):
            return True
    return False


def determine_rarity(item_id, props):
    """Determine rarity based on item properties"""
    if has_property(props, "WorldStaticModel"):
        return "Rare"
    
    if any(x in item_id for x in ['Police', 'Military', 'Army', 'Swat']):
        return "Uncommon"
    
    if has_property(props, "Sterile"):
        return "Uncommon"
    
    # Skill books by level
    if 'SkillBook' in item_id or 'Book' in item_id:
        level_match = re.search(r'(\d+)$', item_id)
        if level_match:
            level = int(level_match.group(1))
            if level >= 5:
                return "Legendary"
            elif level >= 3:
                return "Rare"
            elif level >= 2:
                return "Uncommon"
    
    return "Common"


def determine_quality(item_id, props):
    """Determine quality descriptor"""
    if has_property(props, "Sterile"):
        return "Quality.Sterile"
    
    if any(x in item_id.lower() for x in ['gold', 'diamond', 'designer', 'expensive']):
        return "Quality.Luxury"
    
    if any(x in item_id.lower() for x in ['empty', 'dirty', 'broken', 'scrap']):
        return "Quality.Waste"
    
    return None


def determine_origin(item_id, props):
    """Determine origin descriptor"""
    if any(x in item_id for x in ['Police', 'Sheriff', 'Cop']):
        return "Origin.Police"
    elif any(x in item_id for x in ['Military', 'Army', 'Tactical']):
        return "Origin.Militia"
    elif any(x in item_id for x in ['Doctor', 'Medic', 'Surgical', 'Hospital']):
        return "Origin.Clinical"
    elif any(x in item_id for x in ['Industrial', 'Factory', 'Warehouse']):
        return "Origin.Industrial"
    
    return None


def determine_theme(item_id, props):
    """Determine theme descriptors"""
    themes = []
    
    if any(x in item_id.lower() for x in ['camp', 'outdoor', 'wilderness', 'survival']):
        themes.append("Theme.Survival")
    
    if any(x in item_id.lower() for x in ['weapon', 'combat', 'tactical', 'armor']):
        themes.append("Theme.Combat")
    
    if any(x in item_id.lower() for x in ['winter', 'warm', 'insulated', 'thermal']):
        insulation = get_stat(props, "Insulation", 0)
        if insulation > 0.5:
            themes.append("Theme.Winter")
    
    return themes


def categorize_item(item_id, props):
    """
    Intelligently categorize item and generate nested tags
    Returns: (primary_tag, additional_tags[])
    """
    props_lower = props.lower()
    
    # === FOOD ===
    if has_property(props, "HungerChange"):
        if has_property(props, "AlcoholPower"):
            subcat = "Drink.Alcohol"
        elif has_property(props, "ThirstChange") and not has_property(props, "HungerChange"):
            subcat = "Drink.Beverage"
        elif any(x in item_id.lower() for x in ['meat', 'steak', 'chicken', 'pork', 'beef', 'fish']):
            days_fresh = get_stat(props, "DaysFresh", 0)
            subcat = "Meat.Perishable" if (days_fresh > 0 and days_fresh < 30) else "Meat.Preserved"
        elif any(x in item_id.lower() for x in ['fruit', 'apple', 'banana', 'orange', 'berry']):
            subcat = "Fruit.Fresh"
        elif any(x in item_id.lower() for x in ['vegetable', 'carrot', 'potato', 'lettuce', 'tomato']):
            subcat = "Vegetable.Fresh"
        elif has_property(props, "Spice"):
            subcat = "Cooking.Spice"
        elif has_property(props, "IsCookable"):
            subcat = "Cooking.Ingredient"
        else:
            days_fresh = get_stat(props, "DaysFresh", 0)
            subcat = "Perishable" if (days_fresh > 0 and days_fresh < 30) else "NonPerishable"
        
        return f"Food.{subcat}", []
    
    # === LITERATURE ===
    if 'Type = Literature' in props or 'SkillBook' in item_id or 'Book' in item_id or 'Magazine' in item_id:
        recipes = count_learned_recipes(props)
        if recipes > 0:
            return "Literature.Recipe", []
        elif 'SkillBook' in item_id:
            return "Literature.SkillBook", []
        elif 'Magazine' in item_id or 'Comic' in item_id:
            return "Literature.Media", []
        else:
            return "Literature.Book", []
    
    # === WEAPON ===
    if 'Type = Weapon' in props or has_property(props, "MinDamage"):
        if any(x in item_id for x in ['Aerosol', 'Grenade', 'Explosive', 'Bomb', 'Molotov']):
            return "Weapon.Explosive", []
        elif has_property(props, "AmmoType"):
            return "Weapon.Firearm.Ranged", []
        elif 'Axe' in item_id:
            return "Weapon.Melee.Axe", []
        elif any(x in item_id for x in ['Knife', 'Blade', 'Machete']):
            return "Weapon.Melee.Blade", []
        elif any(x in item_id for x in ['Bat', 'Club', 'Hammer', 'Pipe']):
            return "Weapon.Melee.Blunt", []
        else:
            return "Weapon.Melee.General", []
    
    # === CLOTHING ===
    if 'Type = Clothing' in props or has_property(props, "BodyLocation"):
        bite = get_stat(props, "BiteDefense", 0)
        bullet = get_stat(props, "BluntDefense", 0)
        
        if bullet > 70 or bite > 70:
            return "Clothing.Armor.Heavy", []
        elif bullet > 30 or bite > 30:
            return "Clothing.Armor.Medium", []
        elif any(x in item_id.lower() for x in ['hat', 'helm', 'mask', 'bandana']):
            return "Clothing.Head", []
        elif any(x in item_id.lower() for x in ['glove', 'mitt']):
            return "Clothing.Hands", []
        elif any(x in item_id.lower() for x in ['shoe', 'boot', 'sneaker']):
            return "Clothing.Feet", []
        else:
            return "Clothing.General", []
    
    # === MEDICAL ===
    if 'Type = Medical' in props or any(x in item_id for x in ['Bandage', 'Pills', 'Medicine', 'Syringe']):
        return "Medical.Surgical" if has_property(props, "Sterile") else "Medical.General", []
    
    # === CONTAINER ===
    capacity = get_stat(props, "Capacity", 0)
    if capacity > 0:
        if any(x in item_id.lower() for x in ['backpack', 'bag', 'pack', 'rucksack']):
            return "Container.Backpack", []
        elif any(x in item_id.lower() for x in ['pouch', 'holster', 'belt']):
            return "Container.Accessory", []
        else:
            return "Container.General", []
    
    # === TOOL ===
    if 'Type = Normal' in props:
        if any(x in item_id.lower() for x in ['hammer', 'saw', 'drill', 'wrench', 'screwdriver']):
            return "Tool.Crafting", []
        elif any(x in item_id.lower() for x in ['shovel', 'rake', 'hoe', 'trowel']):
            return "Tool.Farming", []
        else:
            return "Tool.General", []
    
    # === RESOURCE ===
    if has_property(props, "UseDelta"):
        if any(x in item_id.lower() for x in ['petrol', 'gas', 'fuel', 'propane']):
            return "Resource.Fuel.Liquid", []
        else:
            return "Resource.Material", []
    
    # === ELECTRONICS ===
    if any(x in item_id for x in ['Radio', 'Walkie', 'Generator', 'Battery', 'Electronic']):
        return "Electronics.Battery" if 'Battery' in item_id else "Electronics.Gadget", []
    
    # === MISC (fallback) ===
    return "Misc.General", []


def generate_tags(item_id, props):
    """Generate complete tag set for an item"""
    primary, themes = categorize_item(item_id, props)
    
    tags = [primary]
    tags.append(f"Rarity.{determine_rarity(item_id, props)}")
    
    quality = determine_quality(item_id, props)
    if quality:
        tags.append(quality)
    
    origin = determine_origin(item_id, props)
    if origin:
        tags.append(origin)
    
    tags.extend(determine_theme(item_id, props))
    tags.extend(themes)
    
    return tags


def parse_tags(tags_str):
    """Parse nested tags from Lua tags array string"""
    tag_dict = {
        'primary': None,
        'rarity': 'Common',
        'quality': None,
        'origin': None,
        'theme': []
    }
    
    tags = re.findall(r'"([^"]+)"', tags_str)
    
    for tag in tags:
        parts = tag.split('.')
        root = parts[0]
        
        if root in ['Food', 'Weapon', 'Tool', 'Medical', 'Container', 'Resource', 'Literature', 'Electronics', 'Appliance', 'Clothing']:
            tag_dict['primary'] = tag
        elif root == 'Rarity' and len(parts) > 1:
            tag_dict['rarity'] = parts[1]
        elif root == 'Quality' and len(parts) > 1:
            tag_dict['quality'] = parts[1]
        elif root == 'Origin' and len(parts) > 1:
            tag_dict['origin'] = parts[1]
        elif root == 'Theme':
            tag_dict['theme'].append('.'.join(parts[1:]) if len(parts) > 1 else 'General')
    
    return tag_dict


def get_category_from_tags(tags_dict):
    """Extract category hierarchy from primary tag"""
    if not tags_dict['primary']:
        return ['Misc'], []
    
    parts = tags_dict['primary'].split('.')
    return parts[0:1], parts[1:] if len(parts) > 1 else []
