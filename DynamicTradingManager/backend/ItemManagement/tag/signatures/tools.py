"""
Tools property-based signatures.
Detects tools through usage delta, condition, and ID patterns.
"""
from .helpers import (
    extract_tags_from_props,
    get_display_category,
    id_matches_pattern,
    PropertyAnalyzer,
)


TOOL_ID_PATTERNS = [
    'Tool', 'Hammer', 'Saw', 'Drill', 'Wrench', 'Screwdriver',
    'Shovel', 'Rake', 'Hoe', 'Trowel', 'Pickaxe',
    'Flashlight', 'Rope', 'Lock', 'Key', 'Crowbar'
]

CRAFTING_TOOL_PATTERNS = [
    'Hammer', 'Saw', 'Drill', 'Wrench', 'Screwdriver', 'Welder'
]

FARMING_TOOL_PATTERNS = [
    'Shovel', 'Rake', 'Hoe', 'Trowel', 'Pickaxe', 'Scythe'
]

MEDICAL_TOOL_PATTERNS = [
    'Tweezers', 'Forceps', 'Suture', 'Scalpel',
    'Stethoscope', 'TongueDepressor', 'Medical',
]
SURGICAL_TOOL_PATTERNS = ['Scalpel', 'Suture', 'Forceps']
MEDICAL_TOOL_TAGS = {'base:removeglass', 'base:removebullet', 'base:tweezers'}

MIN_TOOL_CONDITION = 3.0


def matches_tool_signature(item_id, props):
    """
    Check if item matches tool signature.

    Tools have:
    - UseDelta or durability
    - Tool-related ID patterns
    - A dedicated medical-tool branch for clinical and surgical instruments

    Args:
        item_id: Item identifier
        props: Properties string

    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    use_delta = analyzer.get_stat('UseDelta')
    condition_max = analyzer.get_stat('ConditionMax')
    display_category = (get_display_category(props) or '').lower()
    script_tags = {tag.lower() for tag in extract_tags_from_props(props)}
    min_damage = analyzer.get_stat('MinDamage')
    max_damage = analyzer.get_stat('MaxDamage')

    is_medical_display = display_category in {'firstaid', 'firstaidweapon'}
    is_medical_flag = analyzer.has_property('Medical', 'true') or analyzer.has_property('Medical')
    has_medical_tool_tags = bool(script_tags.intersection(MEDICAL_TOOL_TAGS))
    is_medical_tool_id = id_matches_pattern(item_id, MEDICAL_TOOL_PATTERNS)
    is_surgical_tool = (
        display_category == 'firstaidweapon' or
        id_matches_pattern(item_id, SURGICAL_TOOL_PATTERNS)
    )

    medical_tool_context = (
        display_category == 'firstaidweapon' or
        has_medical_tool_tags or
        is_medical_tool_id or
        ((is_medical_display or is_medical_flag) and (condition_max >= 1 or min_damage > 0 or max_damage > 0))
    )

    if medical_tool_context:
        evidence = []
        details = {
            'is_drainable': use_delta > 0,
            'condition_max': condition_max,
            'tool_type': 'Medical.Surgical' if is_surgical_tool else 'Medical',
            'display_category': display_category or None,
            'total_uses': 0,
        }

        if is_medical_display:
            evidence.append(0.45 if display_category == 'firstaidweapon' else 0.35)
        if is_medical_flag:
            evidence.append(0.3)
        if has_medical_tool_tags:
            evidence.append(0.35)
        if is_medical_tool_id:
            evidence.append(0.2)
        if condition_max >= 1:
            evidence.append(0.1)
        if min_damage > 0 or max_damage > 0:
            evidence.append(0.2)
            details['min_damage'] = min_damage
            details['max_damage'] = max_damage
        if is_surgical_tool:
            evidence.append(0.3)

        if use_delta > 0:
            total_uses = int(1.0 / use_delta) if use_delta > 0 else 1
            details['total_uses'] = total_uses
            details['use_delta'] = use_delta

        confidence = min(1.0, sum(evidence)) if evidence else 0.0
        matches = confidence >= 0.45
        return matches, confidence, details

    if use_delta == 0 and condition_max < MIN_TOOL_CONDITION:
        return False, 0.0, {}

    evidence = []
    details = {
        'is_drainable': use_delta > 0,
        'condition_max': condition_max,
        'tool_type': 'General',
        'total_uses': 0,
    }

    if use_delta > 0:
        evidence.append(0.25)
        total_uses = int(1.0 / use_delta) if use_delta > 0 else 1
        details['total_uses'] = total_uses
        details['use_delta'] = use_delta

    if condition_max > MIN_TOOL_CONDITION:
        evidence.append(0.25)

    if analyzer.has_property('Type', 'Normal'):
        evidence.append(0.15)

    if id_matches_pattern(item_id, TOOL_ID_PATTERNS):
        evidence.append(0.2)

    if id_matches_pattern(item_id, CRAFTING_TOOL_PATTERNS):
        details['tool_type'] = 'Crafting'
        evidence.append(0.15)
    elif id_matches_pattern(item_id, FARMING_TOOL_PATTERNS):
        details['tool_type'] = 'Farming'
        evidence.append(0.15)
    elif id_matches_pattern(item_id, ['Crowbar', 'Lock', 'Key']):
        details['tool_type'] = 'Utility'
        evidence.append(0.1)
    elif id_matches_pattern(item_id, ['Flashlight', 'Lens', 'Light']):
        details['tool_type'] = 'Light'
        evidence.append(0.1)

    confidence = min(1.0, sum(evidence)) if evidence else 0.0
    matches = confidence > 0.35

    return matches, confidence, details


def get_tool_tags(item_id, props):
    """
    Generate tool tags based on signature match.

    Args:
        item_id: Item identifier
        props: Properties string

    Returns:
        list: Tag list for this tool
    """
    matches, confidence, details = matches_tool_signature(item_id, props)

    if not matches:
        return []

    tool_type = details.get('tool_type', 'General')
    primary_tag = f"Tool.{tool_type}"
    tags = [primary_tag]

    parts = primary_tag.split('.')
    for index in range(2, len(parts)):
        parent = '.'.join(parts[:index])
        if parent not in tags:
            tags.append(parent)

    condition = details.get('condition_max', 0)
    if condition > 50:
        tags.append("Tool.Durable")
    elif 0 < condition < 15:
        tags.append("Tool.Fragile")

    total_uses = details.get('total_uses', 0)
    if total_uses > 100:
        tags.append("Tool.HighUse")
    elif total_uses > 30:
        tags.append("Tool.MediumUse")
    elif total_uses > 0:
        tags.append("Tool.LimitedUse")

    return tags
