"""
Tagging system for intelligent item categorization
Generates nested tags based on item properties and ID patterns
"""
import re
from ..commons.vanilla_loader import get_stat, has_property, count_learned_recipes
from ..config import EXCLUDED_PATTERNS
from .signatures.food import get_food_tags
from .signatures.building import matches_building_signature, get_building_tags


LITERATURE_DISPLAY_CATS = {'literature', 'skillbook', 'book'}
RESOURCE_PART_PATTERNS = [
    'AxeHead', 'HatchetHead', 'HammerHead', 'MaceHead', 'SpearHead',
    'Blade', 'SwordBlade', 'KnifeBlade', 'MacheteBlade',
    'NoTang', 'Shard', 'Mold', 'Unfired',
]


def _get_display_category(props):
    """Extract lowercase DisplayCategory from raw item properties."""
    m = re.search(r"DisplayCategory\s*=\s*([^,\n\s;]+)", props, re.IGNORECASE)
    return m.group(1).lower() if m else ''


def _is_literature_item(item_id, props):
    """Heuristic detector for books/magazines/recipe-learning items."""
    item_lower = item_id.lower()
    disp_cat = _get_display_category(props)

    has_type_literature = bool(re.search(r"Type\s*=\s*Literature\b", props, re.IGNORECASE))
    has_recipe_learning = bool(re.search(r"(LearnedRecipes|TeachedRecipes)\s*=", props, re.IGNORECASE))
    has_skill_learning = bool(re.search(r"(SkillTrained|LvlSkillTrained|NumLevelsTrained)\s*=", props, re.IGNORECASE))
    has_reading_meta = bool(re.search(r"(NumberOfPages|PageToWrite|CanBeWrite|LiteratureOnRead)\s*=", props, re.IGNORECASE))

    # Covers vanilla + many modded naming conventions.
    looks_like_literature_id = bool(re.search(
        r"(skillbook|book\d*$|mag\d*$|magazine|comic|schematic|manual|guide|journal|recipeclipping)",
        item_lower,
        re.IGNORECASE,
    ))

    # Prevent plantables/seed sacks that also expose recipe-like fields.
    is_garden_seed_like = ('bagseed' in item_lower or item_lower.endswith('seed') or '_seed' in item_lower)
    if is_garden_seed_like:
        return False

    # Never treat explicit ammo/weapon payloads as reading material.
    if has_property(props, "AmmoType") or has_property(props, "ProjectileCount"):
        return False
    if re.search(r"Type\s*=\s*Weapon\b", props, re.IGNORECASE):
        return False

    if has_type_literature:
        return True
    if disp_cat in LITERATURE_DISPLAY_CATS:
        return True
    if looks_like_literature_id:
        return True
    if (has_recipe_learning or has_skill_learning or has_reading_meta) and (looks_like_literature_id or disp_cat == 'reciperesource'):
        return True

    return looks_like_literature_id and (has_recipe_learning or has_skill_learning or has_reading_meta)


def _is_resource_part_item(item_id, props):
    """Detect salvage/crafting components that should be Resource.Parts."""
    item_lower = item_id.lower()
    if any(p.lower() in item_lower for p in RESOURCE_PART_PATTERNS):
        # Avoid matching common seed names that include "seed" in IDs.
        if 'bagseed' in item_lower or item_lower.endswith('seed') or '_seed' in item_lower:
            return False
        return True

    # Script-tag evidence for component/tool-head items.
    if re.search(r"Tags\s*=\s*[^\n]*base:toolhead", props, re.IGNORECASE):
        return True

    return False


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
    food_tags = get_food_tags(item_id, props)
    if food_tags:
        return food_tags[0], food_tags[1:]

    # === LITERATURE ===
    if _is_literature_item(item_id, props):
        recipes = count_learned_recipes(props)
        has_teached = bool(re.search(r"TeachedRecipes\s*=", props, re.IGNORECASE))
        has_skill_learning = bool(re.search(r"(SkillTrained|LvlSkillTrained|NumLevelsTrained)\s*=", props, re.IGNORECASE))
        item_lower = item_id.lower()

        if recipes > 0 or has_teached or 'schematic' in item_lower or 'recipe' in item_lower:
            return "Literature.Recipe", []
        elif has_skill_learning or 'skillbook' in item_lower:
            return "Literature.SkillBook", []
        elif any(x in item_lower for x in ['mag', 'magazine', 'comic']):
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
    if _is_resource_part_item(item_id, props):
        return "Resource.Parts", []

    if has_property(props, "UseDelta"):
        if any(x in item_id.lower() for x in ['petrol', 'gas', 'fuel', 'propane']):
            return "Resource.Fuel.Liquid", []
        else:
            return "Resource.Material", []

    # === ELECTRONICS ===
    if any(x in item_id for x in ['Radio', 'Walkie', 'Generator', 'Battery', 'Electronic']):
        return "Electronics.Battery" if 'Battery' in item_id else "Electronics.Gadget", []

    # === BUILDING / CONSTRUCTION ===
    # Placed after all strictly-typed categories (Weapon, Literature, Clothing,
    # Medical, Container, Tool, Resource, Electronics) so those take priority.
    # Building.* catches everything that has a building DisplayCategory, Mov_*
    # prefix, or building-material script-tags and wasn't already routed above.
    building_matches, _building_conf, _building_details = matches_building_signature(item_id, props)
    if building_matches:
        building_tags = get_building_tags(item_id, props)
        return building_tags[0], building_tags[1:]

    # === MISC (fallback) ===
    return "Misc.General", []


def generate_tags(item_id, props):
    """Generate complete tag set for an item"""
    primary, additional_tags = categorize_item(item_id, props)
    
    tags = [primary]
    tags.append(f"Rarity.{determine_rarity(item_id, props)}")
    
    quality = determine_quality(item_id, props)
    if quality:
        tags.append(quality)
    
    origin = determine_origin(item_id, props)
    if origin:
        tags.append(origin)
    
    tags.extend(determine_theme(item_id, props))
    tags.extend(additional_tags)
    
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

        if root == 'Rarity' and len(parts) > 1:
            tag_dict['rarity'] = parts[1]
        elif root == 'Quality' and len(parts) > 1:
            tag_dict['quality'] = parts[1]
        elif root == 'Origin' and len(parts) > 1:
            tag_dict['origin'] = parts[1]
        elif root == 'Theme':
            tag_dict['theme'].append('.'.join(parts[1:]) if len(parts) > 1 else 'General')
        elif '.' in tag and tag_dict['primary'] is None:
            # Any non-descriptor dotted tag is considered primary.
            tag_dict['primary'] = tag
    
    return tag_dict


def get_category_from_tags(tags_dict):
    """Extract category hierarchy from primary tag"""
    if not tags_dict['primary']:
        return ['Misc'], []
    
    parts = tags_dict['primary'].split('.')
    return parts[0:1], parts[1:] if len(parts) > 1 else []
