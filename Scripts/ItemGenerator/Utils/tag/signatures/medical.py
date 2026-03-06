"""
Medical property-based signatures.
Detects medical items through healing, cure, and sanitation properties.
"""
from .helpers import has_property, id_matches_pattern, PropertyAnalyzer


MEDICAL_ID_PATTERNS = [
    'Bandage', 'Pills', 'Medicine', 'Syringe', 'Medic', 'Medical',
    'Ointment', 'Suture', 'Antibiotics', 'Painkiller', 'Antacid',
    'Alcohol', 'Disinfectant', 'Gauze', 'Cream', 'Salve'
]

STERILE_PATTERNS = ['Sterile', 'Surgical', 'Clean', 'Sealed']
SURGICAL_PATTERNS = ['Needle', 'Syringe', 'Suture', 'Surgical']


def matches_medical_signature(item_id, props):
    """
    Check if item matches medical signature.
    
    Medical items have:
    - Type = Medical field
    - Healing/curing properties (properties that affect health)
    - Sterile/sanitation keywords
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    
    # Check for medical indicators
    is_type_medical = analyzer.has_property('Type', 'Medical')
    is_medical_id = id_matches_pattern(item_id, MEDICAL_ID_PATTERNS)
    is_sterile = analyzer.has_property('Sterile') or id_matches_pattern(item_id, STERILE_PATTERNS)
    
    if not (is_type_medical or is_medical_id or is_sterile):
        return False, 0.0, {}
    
    # Collect evidence
    evidence = []
    details = {
        'medical_type': 'General',
        'is_sterile': is_sterile,
        'is_surgical': False,
        'is_consumable': False
    }
    
    # Evidence 1: Type field says Medical
    if is_type_medical:
        evidence.append(0.35)
    
    # Evidence 2: ID pattern matches medical
    if is_medical_id:
        evidence.append(0.25)
    
    # Evidence 3: Is sterile (sanitary)
    if is_sterile:
        evidence.append(0.15)
        details['is_sterile'] = True
    
    # Evidence 4: Classify by medical type
    if id_matches_pattern(item_id, ['Bandage', 'Gauze', 'Wrap']):
        details['medical_type'] = 'Bandage'
        evidence.append(0.1)
    elif id_matches_pattern(item_id, SURGICAL_PATTERNS):
        details['medical_type'] = 'Surgical'
        details['is_surgical'] = True
        evidence.append(0.15)
    elif id_matches_pattern(item_id, ['Pills', 'Medicine', 'Tablet', 'Capsule']):
        details['medical_type'] = 'Medicine'
        details['is_consumable'] = True
        evidence.append(0.1)
    elif id_matches_pattern(item_id, ['Cream', 'Ointment', 'Salve']):
        details['medical_type'] = 'Topical'
        evidence.append(0.1)
    else:
        details['medical_type'] = 'General'
        evidence.append(0.05)
    
    # Calculate confidence
    confidence = min(1.0, sum(evidence)) if evidence else 0.0
    
    # Match if confidence > 0.35
    matches = confidence > 0.35
    
    return matches, confidence, details


def get_medical_tags(item_id, props):
    """
    Generate medical tags based on signature match.
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        list: Tag list for this medical item
    """
    matches, confidence, details = matches_medical_signature(item_id, props)
    
    if not matches:
        return []
    
    tags = []
    
    # Primary tag
    med_type = details.get('medical_type', 'General')
    tags.append(f"Medical.{med_type}")
    
    # Sanitation
    if details.get('is_sterile'):
        tags.append("Medical.Sterile")
    else:
        tags.append("Medical.NonSterile")
    
    # Specialization
    if details.get('is_surgical'):
        tags.append("Medical.Surgical")
    if details.get('is_consumable'):
        tags.append("Medical.Consumable")
    
    return tags
