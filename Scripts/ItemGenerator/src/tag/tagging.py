"""
Tagging system for intelligent item categorization
Generates nested tags based on item properties and ID patterns
"""
import re

from ..commons.vanilla_loader import get_stat, has_property, count_learned_recipes
from ..config import EXCLUDED_PATTERNS
from .signatures.electronics import get_electronics_tags
from .signatures.food import get_food_tags
from .signatures.medical import get_medical_tags
from .signatures.tools import matches_tool_signature, get_tool_tags
from .signatures.weapons import get_weapon_tags


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

    if 'SkillBook' in item_id or 'Book' in item_id:
        level_match = re.search(r'(\d+)$', item_id)
        if level_match:
            level = int(level_match.group(1))
            if level >= 5:
                return "Legendary"
            if level >= 3:
                return "Rare"
            if level >= 2:
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
    if any(x in item_id for x in ['Military', 'Army', 'Tactical']):
        return "Origin.Militia"
    if any(x in item_id for x in ['Doctor', 'Medic', 'Surgical', 'Hospital']):
        return "Origin.Clinical"
    if any(x in item_id for x in ['Industrial', 'Factory', 'Warehouse']):
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


def _get_medical_tool_tags(item_id, props):
    """Return tool tags only for medical instruments."""
    matches, _confidence, details = matches_tool_signature(item_id, props)
    if matches and details.get('tool_type', '').startswith('Medical'):
        return get_tool_tags(item_id, props)
    return []


def categorize_item(item_id, props):
    """
    Intelligently categorize item and generate nested tags
    Returns: (primary_tag, additional_tags[])
    """
    if 'Type = Literature' in props or 'SkillBook' in item_id or 'Book' in item_id or 'Magazine' in item_id:
        recipes = count_learned_recipes(props)
        if recipes > 0:
            return "Literature.Recipe", []
        if 'SkillBook' in item_id:
            return "Literature.SkillBook", []
        if 'Magazine' in item_id or 'Comic' in item_id:
            return "Literature.Media", []
        return "Literature.Book", []

    if 'Type = Clothing' in props or has_property(props, "BodyLocation"):
        bite = get_stat(props, "BiteDefense", 0)
        bullet = get_stat(props, "BluntDefense", 0)

        if bullet > 70 or bite > 70:
            return "Clothing.Armor.Heavy", []
        if bullet > 30 or bite > 30:
            return "Clothing.Armor.Medium", []
        if any(x in item_id.lower() for x in ['hat', 'helm', 'mask', 'bandana']):
            return "Clothing.Head", []
        if any(x in item_id.lower() for x in ['glove', 'mitt']):
            return "Clothing.Hands", []
        if any(x in item_id.lower() for x in ['shoe', 'boot', 'sneaker']):
            return "Clothing.Feet", []
        return "Clothing.General", []

    medical_tool_tags = _get_medical_tool_tags(item_id, props)
    if medical_tool_tags:
        return medical_tool_tags[0], medical_tool_tags[1:]

    medical_tags = get_medical_tags(item_id, props)
    if medical_tags:
        return medical_tags[0], medical_tags[1:]

    capacity = get_stat(props, "Capacity", 0)
    if capacity > 0:
        if any(x in item_id.lower() for x in ['backpack', 'bag', 'pack', 'rucksack']):
            return "Container.Backpack", []
        if any(x in item_id.lower() for x in ['pouch', 'holster', 'belt']):
            return "Container.Accessory", []
        return "Container.General", []

    food_tags = get_food_tags(item_id, props)
    if food_tags:
        return food_tags[0], food_tags[1:]

    weapon_tags = get_weapon_tags(item_id, props)
    if weapon_tags:
        return weapon_tags[0], weapon_tags[1:]

    tool_tags = get_tool_tags(item_id, props)
    if tool_tags:
        return tool_tags[0], tool_tags[1:]

    electronics_tags = get_electronics_tags(item_id, props)
    if electronics_tags:
        return electronics_tags[0], electronics_tags[1:]

    if has_property(props, "UseDelta"):
        if any(x in item_id.lower() for x in ['petrol', 'gas', 'fuel', 'propane']):
            return "Resource.Fuel.Liquid", []
        return "Resource.Material", []

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
