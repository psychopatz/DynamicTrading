"""
Container property-based signatures.
Detects storage items through capacity and weight reduction.
"""
from .helpers import get_stat, id_matches_pattern, PropertyAnalyzer


CONTAINER_ID_PATTERNS = [
    'Bag', 'Backpack', 'Pack', 'Rucksack', 'Container', 'Box',
    'Chest', 'Locker', 'Bin', 'Pouch', 'Holster', 'Belt',
    'Satchel', 'Purse', 'Knapsack', 'Crate', 'Barrel'
]

BACKPACK_PATTERNS = ['Backpack', 'Pack', 'Rucksack', 'Knapsack']
POUCH_PATTERNS = ['Pouch', 'Holster', 'Belt', 'Sling']
STORAGE_PATTERNS = ['Chest', 'Locker', 'Box', 'Bin', 'Crate', 'Barrel']

# Thresholds
MIN_CAPACITY = 5
MEDIUM_CAPACITY = 40
LARGE_CAPACITY = 80


def matches_container_signature(item_id, props):
    """
    Check if item matches container signature.
    
    Containers have:
    - Capacity property (storage space)
    - WeightReduction (weight bonus)
    - Container-related ID patterns
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    
    # Hard requirement: has capacity
    capacity = analyzer.get_stat('Capacity')
    
    if capacity < MIN_CAPACITY:
        return False, 0.0, {}
    
    # Collect evidence
    evidence = []
    details = {
        'capacity': capacity,
        'weight_reduction': analyzer.get_stat('WeightReduction'),
        'container_type': 'General',
        'size': 'Small'
    }
    
    # Evidence 1: Has Capacity
    evidence.append(0.35)  # Strong indicator
    
    # Evidence 2: ID matches container patterns
    if id_matches_pattern(item_id, CONTAINER_ID_PATTERNS):
        evidence.append(0.25)
    
    # Evidence 3: Has WeightReduction (quality indicator)
    weight_reduction = analyzer.get_stat('WeightReduction')
    if weight_reduction > 0:
        evidence.append(0.15)
    
    # Evidence 4: Classify by size
    if capacity > LARGE_CAPACITY:
        details['size'] = 'Large'
        evidence.append(0.1)
    elif capacity > MEDIUM_CAPACITY:
        details['size'] = 'Medium'
        evidence.append(0.1)
    else:
        details['size'] = 'Small'
        evidence.append(0.05)
    
    # Evidence 5: Classify by container type
    if id_matches_pattern(item_id, BACKPACK_PATTERNS):
        details['container_type'] = 'Backpack'
        evidence.append(0.1)
    elif id_matches_pattern(item_id, POUCH_PATTERNS):
        details['container_type'] = 'Pouch'
        evidence.append(0.1)
    elif id_matches_pattern(item_id, STORAGE_PATTERNS):
        details['container_type'] = 'Storage'
        evidence.append(0.1)
    else:
        details['container_type'] = 'General'
        evidence.append(0.05)
    
    # Calculate confidence
    confidence = min(1.0, sum(evidence)) if evidence else 0.0
    
    # Match if confidence > 0.35
    matches = confidence > 0.35
    
    return matches, confidence, details


def get_container_tags(item_id, props):
    """
    Generate container tags based on signature match.
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        list: Tag list for this container
    """
    matches, confidence, details = matches_container_signature(item_id, props)
    
    if not matches:
        return []
    
    tags = []
    
    # Primary tag (type + size)
    container_type = details.get('container_type', 'General')
    size = details.get('size', 'Small')
    tags.append(f"Container.{container_type}.{size}")
    
    # Capacity classification
    capacity = details.get('capacity', 0)
    if capacity > LARGE_CAPACITY:
        tags.append("Container.HighCapacity")
    elif capacity > MEDIUM_CAPACITY:
        tags.append("Container.MediumCapacity")
    else:
        tags.append("Container.LowCapacity")
    
    # Weight efficiency
    weight_reduction = details.get('weight_reduction', 0)
    if weight_reduction > 0.4:
        tags.append("Container.WeightEfficient")
    elif weight_reduction > 0:
        tags.append("Container.WeightReduction")
    
    return tags
