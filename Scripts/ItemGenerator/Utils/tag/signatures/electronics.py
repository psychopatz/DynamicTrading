"""
Electronics property-based signatures.
Detects electronic items through battery, power requirements, and ID patterns.
"""
from .helpers import has_property, id_matches_pattern, PropertyAnalyzer


ELECTRONICS_ID_PATTERNS = [
    'Radio', 'Walkie', 'Walkie Talkie', 'Generator', 'Battery', 'Electronic',
    'TV', 'Television', 'Computer', 'PC', 'Phone', 'Telephone', 'Camera',
    'Flashlight', 'Torch', 'Light', 'Lamp', 'Alarm', 'Clock'
]

BATTERY_PATTERNS = ['Battery', 'Cell']
GENERATOR_PATTERNS = ['Generator', 'Solar']
COMMUNICATION_PATTERNS = ['Radio', 'Walkie', 'Phone', 'CB']


def matches_electronics_signature(item_id, props):
    """
    Check if item matches electronics signature.
    
    Electronics have:
    - Battery-related properties or IDs
    - Power/signal-related functionality
    - Electronic device ID patterns
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    
    # Check if matches any electronics pattern
    is_electronics_id = id_matches_pattern(item_id, ELECTRONICS_ID_PATTERNS)
    
    if not is_electronics_id:
        return False, 0.0, {}
    
    # Collect evidence
    evidence = []
    details = {
        'electronics_type': 'Generic',
        'is_battery': False,
        'is_generator': False,
        'is_communication': False
    }
    
    # Evidence 1: ID matches electronics patterns
    evidence.append(0.4)  # Strong base evidence
    
    # Evidence 2: Classify by electronics type
    if id_matches_pattern(item_id, BATTERY_PATTERNS):
        details['is_battery'] = True
        details['electronics_type'] = 'Battery'
        evidence.append(0.2)
    elif id_matches_pattern(item_id, GENERATOR_PATTERNS):
        details['is_generator'] = True
        details['electronics_type'] = 'Generator'
        evidence.append(0.2)
    elif id_matches_pattern(item_id, COMMUNICATION_PATTERNS):
        details['is_communication'] = True
        details['electronics_type'] = 'Communication'
        evidence.append(0.2)
    elif id_matches_pattern(item_id, ['Flashlight', 'Torch', 'Light', 'Lamp']):
        details['electronics_type'] = 'Light'
        evidence.append(0.15)
    else:
        details['electronics_type'] = 'Generic'
        evidence.append(0.1)
    
    # Evidence 3: Check for power/battery properties
    if has_property('BatteryMod', props) or has_property('RequiresElectricity', props):
        evidence.append(0.15)
        details['requires_power'] = True
    
    # Evidence 4: Check for signal-related properties
    if has_property('SignalStrength', props) or has_property('Transmitter', props):
        evidence.append(0.1)
        details['has_signal'] = True
    
    # Calculate confidence
    confidence = min(1.0, sum(evidence)) if evidence else 0.0
    
    # Match if confidence > 0.4
    matches = confidence > 0.4
    
    return matches, confidence, details


def get_electronics_tags(item_id, props):
    """
    Generate electronics tags based on signature match.
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        list: Tag list for this electronic item
    """
    matches, confidence, details = matches_electronics_signature(item_id, props)
    
    if not matches:
        return []
    
    tags = []
    
    # Primary tag
    elec_type = details.get('electronics_type', 'Generic')
    tags.append(f"Electronics.{elec_type}")
    
    # Functional tags
    if details.get('is_battery'):
        tags.append("Electronics.PowerSource")
    if details.get('is_generator'):
        tags.append("Electronics.PowerGenerator")
    if details.get('is_communication'):
        tags.append("Electronics.Communicator")
    if details.get('requires_power'):
        tags.append("Electronics.RequiresPower")
    if details.get('has_signal'):
        tags.append("Electronics.Transmitter")
    
    return tags
