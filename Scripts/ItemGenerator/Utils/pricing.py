"""
Pricing calculation system
Category-specific pricing logic based on vanilla stats and tags
"""
import math
from .vanilla_loader import get_stat, has_property, count_learned_recipes


def calculate_food_price(item_id, props, tags_dict):
    """Food pricing: basePrice = math.floor(Hunger * 2.5), Opened penalty: 30%"""
    hunger = abs(get_stat(props, "HungerChange", 0))
    
    if hunger == 0:
        return 1  # Cooking ingredients
    
    base_price = math.floor(hunger * 2.5)
    
    # Opened penalty
    if has_property(props, "Opened") or "_Open" in item_id:
        base_price = math.floor(base_price * 0.7)
    
    return max(1, base_price)


def calculate_drainable_price(item_id, props, tags_dict):
    """Drainable pricing based on Total Uses = 1 / UseDelta"""
    use_delta = get_stat(props, "UseDelta", 0.1)
    if use_delta == 0:
        use_delta = 0.1
    
    total_uses = 1.0 / use_delta
    weight = get_stat(props, "Weight", 0.1)
    utility = total_uses / max(weight, 0.1)
    base_price = math.floor(utility * 0.5)
    
    # Fuel premium
    primary = tags_dict.get('primary', '') or ''
    if 'Fuel' in primary:
        base_price = math.floor(base_price * 1.5)
    
    return max(1, base_price)


def calculate_literature_price(item_id, props, tags_dict):
    """Literature pricing with knowledge premium by rarity"""
    rarity = tags_dict.get('rarity', 'Common')
    recipes = count_learned_recipes(props)
    
    rarity_prices = {'Common': 40, 'Uncommon': 45, 'Rare': 50, 'Legendary': 60}
    base_price = rarity_prices.get(rarity, 40)
    
    if recipes > 0:
        base_price += recipes * 10
    
    if 'Magazine' in item_id or 'Comic' in item_id:
        base_price = max(8, math.floor(base_price * 0.3))
    
    return base_price


def calculate_medical_price(item_id, props, tags_dict):
    """Medical pricing based on sterility and rarity"""
    quality = tags_dict.get('quality', '')
    rarity = tags_dict.get('rarity', 'Common')
    base_price = 10
    
    if quality == 'Sterile':
        base_price = math.floor(base_price * 2.0)
    
    rarity_multipliers = {'Common': 1.0, 'Uncommon': 1.5, 'Rare': 2.0, 'Legendary': 3.0}
    base_price = math.floor(base_price * rarity_multipliers.get(rarity, 1.0))
    
    return max(5, base_price)


def calculate_weapon_price(item_id, props, tags_dict):
    """Weapon pricing based on damage and type"""
    max_damage = get_stat(props, "MaxDamage", 1.0)
    condition = get_stat(props, "ConditionMax", 10)
    weight = get_stat(props, "Weight", 1.0)
    worth = (max_damage * condition) / max(weight, 0.1)
    
    primary = tags_dict.get('primary', '') or ''
    if any(x in item_id for x in ['Aerosol', 'Grenade', 'Explosive', 'Bomb']):
        return max(100, math.floor(worth * 10))  # Explosives
    elif 'Firearm' in primary or 'Gun' in item_id:
        return max(50, math.floor(worth * 5))
    else:
        return max(5, math.floor(worth * 2))


def calculate_container_price(item_id, props, tags_dict):
    """Container pricing based on capacity and weight reduction"""
    capacity = get_stat(props, "Capacity", 0)
    weight = get_stat(props, "Weight", 0.1)
    weight_reduction = get_stat(props, "WeightReduction", 0)
    
    if capacity == 0:
        return 15
    
    utility = 1.0 + (weight_reduction / 100.0)
    base_price = (capacity * utility) / max(weight, 0.1) * 2.5
    
    return math.floor(max(10, base_price))


def calculate_clothing_price(item_id, props, tags_dict):
    """Clothing pricing based on protection stats"""
    bite = get_stat(props, "BiteDefense", 0)
    scratch = get_stat(props, "ScratchDefense", 0)
    bullet = get_stat(props, "BluntDefense", 0)
    insulation = get_stat(props, "Insulation", 0)
    wind_resist = get_stat(props, "WindResist", 0)
    
    if bullet > 70:
        return math.floor(1000 + (bullet * 10))
    elif bite > 50 or scratch > 50:
        return math.floor(500 + (max(bite, scratch) * 5))
    elif insulation > 0.5 or wind_resist > 0.5:
        return math.floor(250 + (max(insulation, wind_resist) * 100))
    
    total_protection = bite + scratch + bullet
    if total_protection > 20:
        return math.floor(100 + (total_protection * 2))
    
    quality = tags_dict.get('quality', '')
    if quality == 'Luxury':
        return 50
    elif quality == 'Waste':
        return 5
    
    return 15


def calculate_tool_price(item_id, props, tags_dict):
    """Tool pricing based on utility and durability"""
    condition = get_stat(props, "ConditionMax", 10)
    weight = get_stat(props, "Weight", 0.5)
    utility = condition / max(weight, 0.1)
    
    quality = tags_dict.get('quality', '')
    if quality == 'Luxury':
        utility *= 2.0
    elif quality == 'Waste':
        utility *= 0.5
    
    return max(5, math.floor(utility * 2))


def calculate_electronics_price(item_id, props, tags_dict):
    """Electronics pricing based on rarity"""
    rarity = tags_dict.get('rarity', 'Common')
    rarity_prices = {'Common': 20, 'Uncommon': 40, 'Rare': 80, 'Legendary': 150}
    return rarity_prices.get(rarity, 20)


def calculate_resource_price(item_id, props, tags_dict):
    """Resource pricing based on type"""
    primary = tags_dict.get('primary', '') or ''
    if 'Fuel' in primary:
        return calculate_drainable_price(item_id, props, tags_dict)
    
    weight = get_stat(props, "Weight", 0.1)
    value = 50.0 / max(weight, 0.1)
    return math.floor(max(1, value))


def calculate_price(item_id, props, tags_dict):
    """Master pricing function using tag-based routing"""
    if not props:
        return 10
    
    category, subcategories = get_category_from_tags(tags_dict)
    category = category[0] if category else 'Misc'
    
    # Route to category-specific pricing
    pricing_map = {
        'Food': calculate_food_price,
        'Literature': calculate_literature_price,
        'Medical': calculate_medical_price,
        'Weapon': calculate_weapon_price,
        'Container': calculate_container_price,
        'Clothing': calculate_clothing_price,
        'Tool': calculate_tool_price,
        'Electronics': calculate_electronics_price,
        'Resource': calculate_resource_price,
    }
    
    if category in pricing_map:
        return pricing_map[category](item_id, props, tags_dict)
    
    # Generic pricing
    weight = get_stat(props, "Weight", 0.5)
    return max(5, math.floor(20.0 / max(weight, 0.1)))


def get_category_from_tags(tags_dict):
    """Extract category hierarchy from primary tag"""
    if not tags_dict['primary']:
        return ['Misc'], []
    
    parts = tags_dict['primary'].split('.')
    return parts[0:1], parts[1:] if len(parts) > 1 else []
