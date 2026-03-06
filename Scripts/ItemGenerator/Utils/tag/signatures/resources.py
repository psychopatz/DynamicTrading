"""
Resource property-based signatures.
Detects raw materials and resources through crafting and salvage properties.
"""
from .helpers import get_stat, has_property, id_matches_pattern, count_recipes, PropertyAnalyzer


RESOURCE_ID_PATTERNS = [
    'Resource', 'Material', 'Scrap', 'Wood', 'Metal', 'Ore',
    'Fabric', 'Leather', 'Paper', 'Glass', 'Stone', 'Clay',
    'Fuel', 'Oil', 'Gas', 'Gasoline', 'Propane', 'Electricity',
    'Component', 'Part', 'Wire', 'Cable', 'Rope', 'Sheet'
]

FUEL_PATTERNS = ['Fuel', 'Oil', 'Gas', 'Gasoline', 'Propane', 'Diesel', 'Petrol']
METAL_PATTERNS = ['Metal', 'Steel', 'Iron', 'Copper', 'Aluminum', 'Scrap']
WOOD_PATTERNS = ['Wood', 'Plank', 'Log', 'Lumber', 'Timber']
FABRIC_PATTERNS = ['Fabric', 'Cloth', 'Leather', 'Linen', 'Wool']


def matches_resource_signature(item_id, props):
    """
    Check if item matches resource signature.
    
    Resources have:
    - UseDelta (are consumable/drainable)
    - Crafting recipes (provide materials)
    - Resource-related ID patterns
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    
    # Check if matches any resource indicator
    is_resource_id = id_matches_pattern(item_id, RESOURCE_ID_PATTERNS)
    is_drainable = analyzer.get_stat('UseDelta') > 0
    has_recipes = count_recipes(props) > 0
    
    if not (is_resource_id or is_drainable or has_recipes):
        return False, 0.0, {}
    
    # Collect evidence
    evidence = []
    details = {
        'resource_type': 'General',
        'is_fuel': False,
        'is_craftable': has_recipes,
        'is_harvestable': False
    }
    
    # Evidence 1: ID matches resource patterns
    if is_resource_id:
        evidence.append(0.25)
    
    # Evidence 2: Is drainable (consumable resource)
    if is_drainable:
        evidence.append(0.2)
        details['use_delta'] = analyzer.get_stat('UseDelta')
    
    # Evidence 3: Has crafting recipes (is a material)
    if has_recipes:
        evidence.append(0.25)
    
    # Evidence 4: Classify by resource type
    if id_matches_pattern(item_id, FUEL_PATTERNS):
        details['resource_type'] = 'Fuel'
        details['is_fuel'] = True
        evidence.append(0.2)
    elif id_matches_pattern(item_id, METAL_PATTERNS):
        details['resource_type'] = 'Metal'
        evidence.append(0.15)
    elif id_matches_pattern(item_id, WOOD_PATTERNS):
        details['resource_type'] = 'Wood'
        evidence.append(0.15)
    elif id_matches_pattern(item_id, FABRIC_PATTERNS):
        details['resource_type'] = 'Fabric'
        evidence.append(0.15)
    else:
        details['resource_type'] = 'General'
        evidence.append(0.05)
    
    # Evidence 5: Check for harvestable properties
    if has_property('HarvestType', props) or has_property('Harvestable', props):
        details['is_harvestable'] = True
        evidence.append(0.15)
    
    # Calculate confidence
    confidence = min(1.0, sum(evidence)) if evidence else 0.0
    
    # Match if confidence > 0.35
    matches = confidence > 0.35
    
    return matches, confidence, details


def get_resource_tags(item_id, props):
    """
    Generate resource tags based on signature match.
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        list: Tag list for this resource
    """
    matches, confidence, details = matches_resource_signature(item_id, props)
    
    if not matches:
        return []
    
    tags = []
    
    # Primary tag
    resource_type = details.get('resource_type', 'General')
    tags.append(f"Resource.{resource_type}")
    
    # Usage classification
    if details.get('is_fuel'):
        tags.append("Resource.Fuel")
    elif details.get('is_craftable'):
        tags.append("Resource.Craftable")
    
    # Harvestability
    if details.get('is_harvestable'):
        tags.append("Resource.Harvestable")
    
    return tags
