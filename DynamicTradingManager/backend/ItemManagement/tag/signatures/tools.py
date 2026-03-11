"""
Tools property-based signatures.
Detects tools through usage delta, condition, and ID patterns.
"""
from .helpers import get_stat, has_property, id_matches_pattern, PropertyAnalyzer


TOOL_ID_PATTERNS = [
    'Tool', 'Hammer', 'Saw', 'Drill', 'Wrench', 'Screwdriver',
    'Shovel', 'Rake', 'Hoe', 'Trowel', 'Pickaxe', 'Axe',
    'Flashlight', 'Rope', 'Lock', 'Key', 'Crowbar'
]

CRAFTING_TOOL_PATTERNS = [
    'Hammer', 'Saw', 'Drill', 'Wrench', 'Screwdriver', 'Welder'
]

FARMING_TOOL_PATTERNS = [
    'Shovel', 'Rake', 'Hoe', 'Trowel', 'Pickaxe', 'Scythe'
]

# Thresholds
MIN_TOOL_CONDITION = 3.0


def matches_tool_signature(item_id, props):
    """
    Check if item matches tool signature.
    
    Tools have:
    - UseDelta (are consumable/drainable)
    - ConditionMax (have durability)
    - Tool-related ID patterns
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    
    # Hard requirement: is drainable (has UseDelta)
    use_delta = analyzer.get_stat('UseDelta')
    condition_max = analyzer.get_stat('ConditionMax')
    
    if use_delta == 0 and condition_max < MIN_TOOL_CONDITION:
        return False, 0.0, {}
    
    # Collect evidence
    evidence = []
    details = {
        'is_drainable': use_delta > 0,
        'condition_max': condition_max,
        'tool_type': 'General',
        'total_uses': 0
    }
    
    # Evidence 1: Has UseDelta (is drainable)
    if use_delta > 0:
        evidence.append(0.25)
        total_uses = int(1.0 / use_delta) if use_delta > 0 else 1
        details['total_uses'] = total_uses
        details['use_delta'] = use_delta
    
    # Evidence 2: Has ConditionMax (durable)
    if condition_max > MIN_TOOL_CONDITION:
        evidence.append(0.25)
    
    # Evidence 3: Type field indicates Normal (generic tool)
    if analyzer.has_property('Type', 'Normal'):
        evidence.append(0.15)
    
    # Evidence 4: ID pattern matches tool
    if id_matches_pattern(item_id, TOOL_ID_PATTERNS):
        evidence.append(0.2)
    
    # Evidence 5: Classify by specialization
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
    else:
        details['tool_type'] = 'General'
    
    # Calculate confidence
    confidence = min(1.0, sum(evidence)) if evidence else 0.0
    
    # Match if confidence > 0.35
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
    
    tags = []
    
    # Primary tag
    tool_type = details.get('tool_type', 'General')
    tags.append(f"Tool.{tool_type}")
    
    # Durability classification
    condition = details.get('condition_max', 0)
    if condition > 50:
        tags.append("Tool.Durable")
    elif condition < 15:
        tags.append("Tool.Fragile")
    
    # Usage classification
    total_uses = details.get('total_uses', 0)
    if total_uses > 100:
        tags.append("Tool.HighUse")
    elif total_uses > 30:
        tags.append("Tool.MediumUse")
    elif total_uses > 0:
        tags.append("Tool.LimitedUse")
    
    return tags
