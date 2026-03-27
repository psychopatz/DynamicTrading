"""
Pricing calculation system - Comprehensive implementation based on ItemID_Verify logic
Category-specific pricing logic with enhanced accuracy
"""
import math
import re
from ..commons.vanilla_loader import get_stat, has_property, count_learned_recipes


def calculate_price(item_id, props, tags_dict):
    """
    Master pricing function incorporating ItemID_Verify's comprehensive logic
    Calculates realistic prices based on item properties and category
    """
    if not props or len(props.strip()) < 10:
        return 10
    
    p_lower = props.lower()
    weight = get_stat(props, "Weight", 0.1)
    
    # Extract properties
    capacity = get_stat(props, "Capacity", 0.0)
    weight_reduction = get_stat(props, "WeightReduction", 0.0)
    metal_value = get_stat(props, "MetalValue", 0.0)
    fuel_value = get_stat(props, "FuelValue", 0.0)
    fire_fuel_ratio = get_stat(props, "FireFuelRatio", 0.0)
    
    # Calculate total uses from UseDelta
    use_delta = get_stat(props, "UseDelta", 0.0)
    total_uses = int(round(1.0 / use_delta)) if use_delta > 0 else 1
    
    # Count learned recipes
    recipes = count_learned_recipes(props)
    
    # Backward/defensive compatibility: some call sites may pass generated tag lists.
    if isinstance(tags_dict, list):
        primary_from_list = next(
            (t for t in tags_dict if isinstance(t, str) and not t.startswith(('Rarity.', 'Quality.', 'Origin.', 'Theme.'))),
            'Misc.General'
        )
        tags_dict = {'primary': primary_from_list}
    elif not isinstance(tags_dict, dict):
        tags_dict = {'primary': 'Misc.General'}

    worth = 1.0
    primary = tags_dict.get('primary', '') or 'Misc.General'
    category = primary.split('.')[0] if '.' in primary else primary
    
    # Containers/Storage Items - High value per capacity
    if capacity > 0 and category != 'Fluid':
        utility = 1.0 + (weight_reduction / 100.0)
        worth = (capacity * utility) / max(weight, 0.1) * 2.5
    
    # Food Category
    elif 'Food' in category or 'Food' in primary:
        hunger = abs(get_stat(props, "HungerChange", 0))
        thirst = abs(get_stat(props, "ThirstChange", 0))
        calories = get_stat(props, "Calories", 0) / 100.0
        
        # Penalties: positive Unhappy/Boredom/Stress reduce value
        penalties = (
            max(0, get_stat(props, "UnhappyChange", 0)) +
            max(0, get_stat(props, "BoredomChange", 0)) +
            max(0, get_stat(props, "StressChange", 0))
        ) * 2
        
        # Shelf-life factor (capped to prevent inflation)
        fresh = get_stat(props, "DaysFresh", 0)
        rotten = get_stat(props, "DaysTotallyRotten", 0)
        shelf_life = min(50, (fresh + rotten) / 5.0)
        
        # Stability bonus for preserved food
        stability = 0
        if "cannedfood = true" in p_lower:
            stability += 50
        elif "packaged = true" in p_lower:
            stability += 10
        
        worth = (hunger + (thirst / 2) + calories - penalties + stability + shelf_life) / (weight * 1.5 + 0.1)
    
    # Weapon Category
    elif 'Weapon' in category and ('Type = Weapon' in props or has_property(props, "MinDamage")):
        min_dmg = get_stat(props, "MinDamage", 0)
        max_dmg = get_stat(props, "MaxDamage", 1.0)
        avg_dmg = (min_dmg + max_dmg) / 2
        max_range = get_stat(props, "MaxRange", 1.0)
        max_hit = get_stat(props, "MaxHitcount", 1.0)
        condition = get_stat(props, "ConditionMax", 5)
        reliability = get_stat(props, "ConditionLowerChanceOneIn", 5)
        swing_time = get_stat(props, "MinimumSwingtime", 1.0)
        
        # Explosive weapons get premium pricing
        if any(x in item_id for x in ['Aerosol', 'Grenade', 'Explosive', 'Bomb', 'Molotov']):
            worth = ((avg_dmg * max_range * max_hit) + (condition * reliability / 5)) / (weight * 2 + swing_time * 10 + 0.1)
            worth *= 5.0  # Explosive premium
        else:
            worth = ((avg_dmg * max_range * max_hit) + (condition * reliability / 5)) / (weight * 2 + swing_time * 10 + 0.1)
    
    # Clothing & Protective Gear
    elif 'Clothing' in category or 'Type = Clothing' in props or has_property(props, "BodyLocation"):
        bite = get_stat(props, "BiteDefense", 0)
        scratch = get_stat(props, "ScratchDefense", 0)
        bullet = get_stat(props, "BulletDefense", 0) or get_stat(props, "BluntDefense", 0)
        insulation = get_stat(props, "Insulation", 0)
        wind_res = get_stat(props, "WindResistance", 0)
        run_mod = get_stat(props, "RunSpeedModifier", 1.0)
        combat_mod = get_stat(props, "CombatSpeedModifier", 1.0)
        
        # Penalty for movement/combat slowness
        penalty = (1.0 - run_mod) * 100 + (1.0 - combat_mod) * 50
        
        worth = ((bite * 3) + scratch + (bullet * 2) + (insulation * 20) + (wind_res * 10)) / (weight * 3 + penalty + 1)
    
    # Literature & Knowledge
    elif 'Literature' in category or recipes > 0 or 'Book' in primary or 'Magazine' in primary or 'SkillBook' in item_id:
        worth = (recipes * 25 + 5) / max(weight, 0.1)
    
    # Medical & Consumables
    elif 'Medical' in category or any(x in item_id for x in ['Bandage', 'Pills', 'Medicine', 'Syringe']):
        # Medical items value based on sterility and type
        base_value = 10
        if has_property(props, "Sterile"):
            base_value *= 2.0
        worth = base_value / max(weight, 0.1)

    # Fluids
    elif 'Fluid' in category:
        capacity = max(get_stat(props, "Capacity", 0.0), 0.1)
        if 'Fluid.Fuel' in primary:
            per_liter = 18.0
        elif 'Fluid.Water.Tainted' in primary:
            per_liter = 3.0
        elif 'Fluid.Water' in primary:
            per_liter = 6.0
        elif 'Fluid.Medical' in primary:
            per_liter = 20.0
        elif 'Fluid.Cleaning' in primary:
            per_liter = 14.0
        elif 'Fluid.Appearance' in primary:
            per_liter = 24.0
        elif 'Fluid.Drink.Alcohol' in primary:
            per_liter = 16.0
        elif 'Fluid.Drink.NonAlcoholic' in primary:
            per_liter = 10.0
        else:
            per_liter = 8.0

        worth = (capacity * per_liter) / max(weight, 0.15)

    # Fuel & Drainable Resources
    elif fire_fuel_ratio > 0 or ('Resource' in category and has_property(props, "UseDelta")):
        worth = (fire_fuel_ratio * 15 if fire_fuel_ratio > 0 else get_stat(props, "UseDelta", 0.1) * 10) / max(weight, 0.1)
    
    # Tools & Equipment
    elif 'Tool' in category or any(x in item_id.lower() for x in ['hammer', 'saw', 'drill', 'wrench', 'screwdriver', 'shovel']):
        condition = get_stat(props, "ConditionMax", 10)
        utility = condition / max(weight, 0.1)
        worth = utility * 2.0
    
    # Electronics & Gadgets
    elif 'Electronics' in category or any(x in item_id for x in ['Radio', 'Walkie', 'Generator', 'Battery', 'Electronic']):
        worth = 5.0 / max(weight, 0.1)  # Base value for electronics
    
    # Resources & Materials
    elif 'Resource' in category:
        res_val = metal_value + fuel_value
        worth = (res_val / 10.0 + 1.0) / max(weight, 0.1)
    
    # Default fallback pricing
    else:
        res_val = metal_value + fuel_value
        worth = (res_val / 10.0 + 1.0) / max(weight, 0.1)
    
    # Scaling adjustments
    
    # Scale worth by total uses for drainables
    if total_uses > 1:
        worth *= (total_uses * 0.8)  # Slight diminishing returns per use
    
    # Opened/used item penalty (30% discount)
    id_lower = item_id.lower()
    is_opened = (
        "opened = true" in p_lower or
        "open = true" in p_lower or
        "_open" in id_lower or
        "_opened" in id_lower
    )
    if is_opened:
        worth *= 0.7
    
    # Rarity multiplier (enhance rare items)
    rarity = tags_dict.get('rarity', 'Common')
    rarity_mults = {
        'Common': 1.0,
        'Uncommon': 1.3,
        'Rare': 1.7,
        'Legendary': 3.0,
        'UltraRare': 5.0
    }
    worth *= rarity_mults.get(rarity, 1.0)
    
    # Final price conversion
    price = max(1, int(round(worth)))
    
    return price


def get_category_from_tags(tags_dict):
    """Extract category hierarchy from primary tag"""
    if not tags_dict.get('primary'):
        return ['Misc'], []
    
    parts = tags_dict['primary'].split('.')
    return parts[0:1], parts[1:] if len(parts) > 1 else []
