"""
Tagging system for intelligent item categorization
Generates nested tags based on item properties and ID patterns
"""
import re

from ..commons.vanilla_loader import get_stat, has_property, count_learned_recipes
from ..config import EXCLUDED_PATTERNS
from .signatures.electronics import get_electronics_tags
from .signatures.clothing import get_clothing_tags
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

    has_empty_hint = bool(re.search(r"Tooltip_item_empty_", props, re.IGNORECASE))
    if any(x in item_id.lower() for x in ['empty', 'dirty', 'broken', 'scrap']):
        return "Quality.Waste"
    if has_empty_hint:
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


def _get_cookware_tool_tags(item_id, props):
    """Return tool tags only for cookware-adjacent items."""
    matches, _confidence, details = matches_tool_signature(item_id, props)
    if matches and details.get('tool_type') == 'Cookware':
        return get_tool_tags(item_id, props)
    return []


def _get_display_category(props):
    m = re.search(r"DisplayCategory\s*=\s*([^,\n\s;]+)", props, re.IGNORECASE)
    return m.group(1).lower() if m else ''


def _is_literature_item(item_id, props):
    item_lower = item_id.lower()
    disp_cat = _get_display_category(props)
    has_media_category = bool(re.search(r"\bMediaCategory\s*=\s*", props, re.IGNORECASE))
    looks_like_media_id = bool(re.search(r"(vhs|cassette|disc_|dvd)", item_lower, re.IGNORECASE))

    if 'Type = Literature' in props or 'SkillBook' in item_id or 'Book' in item_id or 'Magazine' in item_id:
        return True
    if has_media_category:
        return True
    if disp_cat == 'entertainment' and looks_like_media_id:
        return True
    return False


def categorize_item(item_id, props):
    """
    Intelligently categorize item and generate nested tags
    Returns: (primary_tag, additional_tags[])
    """
    if _is_literature_item(item_id, props):
        recipes = count_learned_recipes(props)
        if recipes > 0:
            return "Literature.Recipe", []
        if re.search(r"\bMediaCategory\s*=\s*", props, re.IGNORECASE) or any(x in item_id.lower() for x in ['vhs', 'cassette', 'disc_', 'dvd']):
            return "Literature.Media", []
        if 'SkillBook' in item_id:
            return "Literature.SkillBook", []
        if 'Magazine' in item_id or 'Comic' in item_id:
            return "Literature.Media", []
        return "Literature.Book", []

    clothing_tags = get_clothing_tags(item_id, props)
    if clothing_tags:
        return clothing_tags[0], clothing_tags[1:]

    medical_tool_tags = _get_medical_tool_tags(item_id, props)
    if medical_tool_tags:
        return medical_tool_tags[0], medical_tool_tags[1:]

    medical_tags = get_medical_tags(item_id, props)
    if medical_tags:
        return medical_tags[0], medical_tags[1:]

    food_tags = get_food_tags(item_id, props)
    if food_tags:
        return food_tags[0], food_tags[1:]

    cookware_tool_tags = _get_cookware_tool_tags(item_id, props)
    if cookware_tool_tags:
        return cookware_tool_tags[0], cookware_tool_tags[1:]

    capacity = get_stat(props, "Capacity", 0)
    if capacity > 0:
        if any(x in item_id.lower() for x in ['backpack', 'bag', 'pack', 'rucksack']):
            return "Container.Backpack", []
        if any(x in item_id.lower() for x in ['pouch', 'holster', 'belt']):
            return "Container.Accessory", []
        return "Container.General", []

    weapon_tags = get_weapon_tags(item_id, props)
    if weapon_tags:
        return weapon_tags[0], weapon_tags[1:]

    electronics_tags = get_electronics_tags(item_id, props)
    if electronics_tags:
        return electronics_tags[0], electronics_tags[1:]

    tool_tags = get_tool_tags(item_id, props)
    if tool_tags:
        return tool_tags[0], tool_tags[1:]

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
