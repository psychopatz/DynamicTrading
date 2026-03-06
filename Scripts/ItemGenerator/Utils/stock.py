"""
Stock range calculation logic
Determines min/max stock levels based on weight and category
"""
import math


def calculate_base_max_stock(weight):
    """
    Step A: Determine Base Max Stock (BMS) from Weight
    Weight-based stock table
    """
    if weight <= 0.05:
        return 50
    elif weight <= 0.2:
        return 25
    elif weight <= 0.5:
        return 15
    elif weight <= 1.5:
        return 10
    elif weight <= 5.0:
        return 5
    else:
        return 2


def apply_category_multiplier(base_max, tags_dict, subcategories):
    """
    Step B: Apply Category Multipliers based on nested tags
    - Perishable/Fresh Food: 0.5x
    - Staples (Ammo, Material, Currency): 2.0x
    - Rare/Luxury: 0.4x
    - Quest Items: 1 (manual override)
    """
    primary = tags_dict.get('primary', '') or ''
    rarity = tags_dict.get('rarity', 'Common')
    quality = tags_dict.get('quality', '') or ''
    
    # Perishable/Fresh Food
    if 'Perishable' in primary or 'Fresh' in primary:
        return max(1, math.floor(base_max * 0.5))
    
    # Staples (Ammo, Material)
    if any(x in primary for x in ['Ammo', 'Material', 'Currency']):
        return math.floor(base_max * 2.0)
    
    # Rare/Luxury
    if rarity == 'Rare' or rarity == 'Legendary' or quality == 'Luxury':
        return max(1, math.floor(base_max * 0.4))
    
    return base_max


def calculate_min_stock(max_stock, tags_dict, subcategories):
    """
    Step C: Determine Min Stock based on category and demand
    - Default: Floor(Max * 0.2)
    - High Demand (Material, Ammo): Floor(Max * 0.4)
    - Currency: Floor(Max * 0.8)
    - Rare/Fresh: 0
    """
    primary = tags_dict.get('primary', '') or ''
    rarity = tags_dict.get('rarity', 'Common')
    
    # Fresh/Rare
    if 'Fresh' in primary or rarity in ['Rare', 'Legendary']:
        return 0
    
    # Currency
    if 'Currency' in primary:
        return math.floor(max_stock * 0.8)
    
    # High Demand (Material, Ammo)
    if any(x in primary for x in ['Ammo', 'Material', 'Resource']):
        return math.floor(max_stock * 0.4)
    
    # Default
    return math.floor(max_stock * 0.2)
