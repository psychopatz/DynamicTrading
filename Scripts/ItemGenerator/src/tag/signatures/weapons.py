"""
Weapon property-based signatures.
Detects weapons through damage, durability, and handling properties.
"""
from .helpers import extract_tags_from_props, get_display_category, id_matches_pattern, PropertyAnalyzer


WEAPON_ID_PATTERNS = [
    'Weapon', 'Blade', 'Axe', 'Hammer', 'Bat', 'Club', 'Pipe',
    'Knife', 'Machete', 'Sword', 'Gun', 'Pistol', 'Rifle',
    'Shotgun', 'Explosive', 'Grenade', 'Bomb', 'Molotov'
]
COOKWARE_WEAPON_PATTERNS = [
    'BakingPan', 'BakingTray', 'FryingPan', 'GridlePan', 'GriddlePan',
    'Saucepan', 'CookingPot', 'RoastingPan', 'Kettle',
]
COOKWARE_SCRIPT_TAGS = {'base:cookable', 'base:canopener'}

# Thresholds for weapon classification
MIN_DAMAGE_THRESHOLD = 0.5
MELEE_CONDITION_THRESHOLD = 3.0


def matches_weapon_signature(item_id, props):
    """
    Check if item matches weapon signature.
    
    Weapons have:
    - MinDamage and MaxDamage properties (damage output)
    - ConditionMax (durability)
    - Weapon-related ID patterns
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    display_category = (get_display_category(props) or '').lower()
    script_tags = {tag.lower() for tag in extract_tags_from_props(props)}

    cookware_context = (
        display_category in {'cooking', 'cookingweapon'} and (
            id_matches_pattern(item_id, COOKWARE_WEAPON_PATTERNS) or
            bool(script_tags.intersection(COOKWARE_SCRIPT_TAGS)) or
            analyzer.has_property('IsCookable') or
            analyzer.has_property('PourType') or
            analyzer.has_property('EatType')
        )
    )

    if display_category == 'firstaidweapon' or cookware_context:
        return False, 0.0, {
            'display_category': display_category,
            'excluded_medical_weapon': display_category == 'firstaidweapon',
            'excluded_cookware_weapon': cookware_context,
        }

    min_dmg = analyzer.get_stat('MinDamage')
    max_dmg = analyzer.get_stat('MaxDamage')
    
    if min_dmg < MIN_DAMAGE_THRESHOLD and max_dmg < MIN_DAMAGE_THRESHOLD:
        return False, 0.0, {}
    
    # Collect evidence
    evidence = []
    confidence = 0.0
    details = {
        'min_damage': min_dmg,
        'max_damage': max_dmg,
        'is_melee': False,
        'is_firearm': False,
        'is_explosive': False
    }
    
    # Evidence 1: Type field says Weapon
    if analyzer.has_property('Type', 'Weapon'):
        evidence.append(0.3)  # Strong evidence
        details['type_field'] = 'Weapon'
    
    # Evidence 2: ID pattern matches weapon
    if id_matches_pattern(item_id, WEAPON_ID_PATTERNS):
        evidence.append(0.2)
    
    # Evidence 3: Has condition (durability)
    condition_max = analyzer.get_stat('ConditionMax')
    if condition_max > MELEE_CONDITION_THRESHOLD:
        evidence.append(0.2)
        details['condition_max'] = condition_max
        details['is_melee'] = True
    
    # Evidence 4: Has ammo type (firearm)
    if analyzer.has_property('AmmoType'):
        evidence.append(0.3)
        details['ammo_type'] = True
        details['is_firearm'] = True
    
    # Evidence 5: Has range and hit count (ranged weapon)
    max_range = analyzer.get_stat('MaxRange')
    hit_count = analyzer.get_stat('MaxHitcount')
    if max_range > 1.5 or hit_count > 1:
        evidence.append(0.15)
        details['max_range'] = max_range
        details['hit_count'] = hit_count
    
    # Evidence 6: Is explosive
    if id_matches_pattern(item_id, ['Grenade', 'Bomb', 'Explosive', 'Molotov']):
        evidence.append(0.25)
        details['is_explosive'] = True
    
    # Classify subtype
    if details['is_explosive']:
        details['subtype'] = 'Explosive'
    elif details['is_firearm']:
        details['subtype'] = 'Firearm'
    elif details['is_melee']:
        # Further classify melee
        if id_matches_pattern(item_id, ['Axe']):
            details['subtype'] = 'Melee.Axe'
        elif id_matches_pattern(item_id, ['Blade', 'Knife', 'Machete', 'Sword']):
            details['subtype'] = 'Melee.Blade'
        elif id_matches_pattern(item_id, ['Hammer', 'Bat', 'Club', 'Pipe']):
            details['subtype'] = 'Melee.Blunt'
        else:
            details['subtype'] = 'Melee.General'
    else:
        details['subtype'] = 'Unknown'
    
    # Calculate confidence
    if evidence:
        confidence = min(1.0, sum(evidence))
    else:
        confidence = 0.0
    
    # Match if confidence > 0.4
    matches = confidence > 0.4
    
    return matches, confidence, details


def get_weapon_tags(item_id, props):
    """
    Generate weapon tags based on signature match.
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        list: Tag list for this weapon
    """
    matches, confidence, details = matches_weapon_signature(item_id, props)
    
    if not matches:
        return []
    
    tags = []
    
    # Primary tag
    subtype = details.get('subtype', 'General')
    tags.append(f"Weapon.{subtype}")
    
    # Damage rating
    avg_damage = (details.get('min_damage', 0) + details.get('max_damage', 0)) / 2
    if avg_damage > 30:
        tags.append("Weapon.HighDamage")
    elif avg_damage > 15:
        tags.append("Weapon.MediumDamage")
    else:
        tags.append("Weapon.LowDamage")
    
    # Reliability (condition)
    condition = details.get('condition_max', 0)
    if condition > 50:
        tags.append("Weapon.Durable")
    elif condition < 10:
        tags.append("Weapon.Fragile")
    
    # Specialized tags
    if details.get('is_firearm'):
        tags.append("Weapon.Ranged")
    if details.get('is_explosive'):
        tags.append("Weapon.Area")
    if details.get('is_melee'):
        tags.append("Weapon.Melee")
    
    return tags
