"""
Clothing property-based signatures.
Detects clothing through defense, coverage, and body parts.
"""
from .helpers import get_stat, has_property, id_matches_pattern, count_body_parts, PropertyAnalyzer


CLOTHING_ID_PATTERNS = [
    'Shirt', 'Pants', 'Hat', 'Helmet', 'Mask', 'Glove', 'Shoe', 'Boot',
    'Jacket', 'Coat', 'Sweater', 'Dress', 'Skirt', 'Underwear', 'Socks',
    'Armor', 'Vest', 'Suit', 'Uniform', 'Tactical', 'Police', 'Military'
]

# Defense thresholds
LIGHT_ARMOR_THRESHOLD = 10
MEDIUM_ARMOR_THRESHOLD = 30
HEAVY_ARMOR_THRESHOLD = 70


def matches_clothing_signature(item_id, props):
    """
    Check if item matches clothing signature.
    
    Clothing items have:
    - BodyLocation (defines where worn)
    - Defense properties (Bite, Scratch, Bullet)
    - Insulation/WindResistance (environmental)
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    
    # Hard requirement: can be equipped (has BodyLocation)
    body_location = analyzer.has_property('BodyLocation')
    type_field = analyzer.has_property('Type', 'Clothing')
    can_equip = body_location or type_field
    
    if not can_equip:
        return False, 0.0, {}
    
    # Collect evidence
    evidence = []
    details = {
        'body_location': body_location,
        'type_clothing': type_field,
        'armor_level': 'Light',
        'coverage': 'General'
    }
    
    # Evidence 1: Type field says Clothing
    if type_field:
        evidence.append(0.35)
    
    # Evidence 2: Has BodyLocation
    if body_location:
        evidence.append(0.25)
        body_parts = count_body_parts(props)
        details['body_parts'] = body_parts
    
    # Evidence 3: ID pattern matches clothing
    if id_matches_pattern(item_id, CLOTHING_ID_PATTERNS):
        evidence.append(0.15)
    
    # Evidence 4: Has defense stats
    bite_defense = analyzer.get_stat('BiteDefense')
    scratch_defense = analyzer.get_stat('ScratchDefense')
    bullet_defense = analyzer.get_stat('BulletDefense')
    blunt_defense = analyzer.get_stat('BluntDefense')
    
    max_defense = max(bite_defense, scratch_defense, bullet_defense, blunt_defense)
    if max_defense > 0:
        evidence.append(0.2)
        details['bite_defense'] = bite_defense
        details['scratch_defense'] = scratch_defense
        details['bullet_defense'] = bullet_defense
        details['blunt_defense'] = blunt_defense
    
    # Classify armor level
    if max_defense > HEAVY_ARMOR_THRESHOLD:
        details['armor_level'] = 'Heavy'
        evidence.append(0.1)  # Bonus for heavy armor
    elif max_defense > MEDIUM_ARMOR_THRESHOLD:
        details['armor_level'] = 'Medium'
        evidence.append(0.05)
    elif max_defense > LIGHT_ARMOR_THRESHOLD:
        details['armor_level'] = 'Light'
    
    # Evidence 5: Environmental resistance
    insulation = analyzer.get_stat('Insulation')
    wind_resistance = analyzer.get_stat('WindResistance')
    if insulation > 0 or wind_resistance > 0:
        evidence.append(0.1)
        details['insulation'] = insulation
        details['wind_resistance'] = wind_resistance
    
    # Evidence 6: Classify by coverage
    if id_matches_pattern(item_id, ['Hat', 'Helmet', 'Mask', 'Cap']):
        details['coverage'] = 'Head'
        evidence.append(0.1)
    elif id_matches_pattern(item_id, ['Glove', 'Mitt', 'Gauntlet']):
        details['coverage'] = 'Hands'
        evidence.append(0.1)
    elif id_matches_pattern(item_id, ['Shoe', 'Boot', 'Sneaker']):
        details['coverage'] = 'Feet'
        evidence.append(0.1)
    elif id_matches_pattern(item_id, ['Shirt', 'Jacket', 'Coat', 'Sweater', 'Vest']):
        details['coverage'] = 'Torso'
        evidence.append(0.1)
    elif id_matches_pattern(item_id, ['Pants', 'Skirt']):
        details['coverage'] = 'Legs'
        evidence.append(0.1)
    
    # Calculate confidence
    confidence = min(1.0, sum(evidence)) if evidence else 0.0
    
    # Match if confidence > 0.5
    matches = confidence > 0.5
    
    return matches, confidence, details


def get_clothing_tags(item_id, props):
    """
    Generate clothing tags based on signature match.
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        list: Tag list for this clothing item
    """
    matches, confidence, details = matches_clothing_signature(item_id, props)
    
    if not matches:
        return []
    
    tags = []
    
    # Primary tag (armor level + coverage)
    coverage = details.get('coverage', 'General')
    armor = details.get('armor_level', 'Light')
    
    if armor != 'Light':
        tags.append(f"Clothing.Armor.{armor}")
    else:
        tags.append(f"Clothing.{coverage}")
    
    # Protection specialization
    bite = details.get('bite_defense', 0)
    scratch = details.get('scratch_defense', 0)
    bullet = details.get('bullet_defense', 0)
    blunt = details.get('blunt_defense', 0)
    
    if bite > 20:
        tags.append("Clothing.BiteResistant")
    if scratch > 20:
        tags.append("Clothing.ScratchResistant")
    if bullet > 20:
        tags.append("Clothing.BulletResistant")
    if blunt > 20:
        tags.append("Clothing.BluntResistant")
    
    # Environmental protection
    insulation = details.get('insulation', 0)
    wind = details.get('wind_resistance', 0)
    
    if insulation > 0.5:
        tags.append("Clothing.Insulated")
    if wind > 0.5:
        tags.append("Clothing.WindResistant")
    
    # Specialization
    if id_matches_pattern(item_id, ['Police', 'Sheriff']):
        tags.append("Clothing.Authority")
    elif id_matches_pattern(item_id, ['Military', 'Tactical', 'Army']):
        tags.append("Clothing.Tactical")
    elif id_matches_pattern(item_id, ['Medical', 'Doctor', 'Hospital']):
        tags.append("Clothing.Medical")
    
    return tags
