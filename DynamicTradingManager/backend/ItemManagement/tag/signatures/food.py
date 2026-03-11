"""
Food property-based signatures.
Detects food items through hunger, calories, and freshness.
"""
from .helpers import get_stat, has_property, id_matches_pattern, PropertyAnalyzer


FOOD_ID_PATTERNS = [
    'Food', 'Meat', 'Fish', 'Fruit', 'Vegetable', 'Bread', 'Meal',
    'Drink', 'Beverage', 'Alcohol', 'Beer', 'Wine', 'Juice',
    'Spice', 'Condiment', 'Seasoning', 'Dessert', 'Candy'
]

# Thresholds
MIN_FOOD_HUNGER = 5  # Minimum hunger change
MIN_DRINK_THIRST = 3  # Minimum thirst change
PERISHABLE_FRESH_DAYS = 30  # Days before considered perishable


def matches_food_signature(item_id, props):
    """
    Check if item matches food signature.
    
    Food has:
    - HungerChange or ThirstChange (provides sustenance)
    - Calories (nutritional value)
    - DaysFresh/DaysTotallyRotten (freshness tracking)
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    analyzer = PropertyAnalyzer(props)
    
    # Hard requirement: affects hunger or thirst
    hunger_change = analyzer.get_stat('HungerChange')
    thirst_change = analyzer.get_stat('ThirstChange')
    calories = analyzer.get_stat('Calories')
    
    is_food = hunger_change != 0
    is_drink = thirst_change != 0 and hunger_change == 0
    
    if not (is_food or is_drink):
        return False, 0.0, {}
    
    # Collect evidence
    evidence = []
    details = {
        'is_food': is_food,
        'is_drink': is_drink,
        'is_perishable': False,
        'food_type': 'General'
    }
    
    # Evidence 1: Type field says Food
    if analyzer.has_property('Type', 'Food'):
        evidence.append(0.3)
    
    # Evidence 2: ID pattern matches food
    if id_matches_pattern(item_id, FOOD_ID_PATTERNS):
        evidence.append(0.2)
    
    # Evidence 3: Has hunger change (for food)
    if is_food and abs(hunger_change) >= MIN_FOOD_HUNGER:
        evidence.append(0.25)
        details['hunger_change'] = hunger_change
    
    # Evidence 4: Has thirst change (for drinks)
    if is_drink and abs(thirst_change) >= MIN_DRINK_THIRST:
        evidence.append(0.25)
        details['thirst_change'] = thirst_change
    
    # Evidence 5: Has calories
    if calories > 0:
        evidence.append(0.15)
        details['calories'] = calories
    
    # Evidence 6: Is perishable
    days_fresh = analyzer.get_stat('DaysFresh')
    days_rotten = analyzer.get_stat('DaysTotallyRotten')
    
    if days_fresh > 0 and days_fresh < PERISHABLE_FRESH_DAYS:
        details['is_perishable'] = True
        details['days_fresh'] = days_fresh
        details['days_rotten'] = days_rotten
        evidence.append(0.1)
    elif days_fresh == 0 or (days_fresh > PERISHABLE_FRESH_DAYS and days_rotten == 0):
        details['is_perishable'] = False
        evidence.append(0.1)
    
    # Evidence 7: Classification by ID
    if is_food:
        if id_matches_pattern(item_id, ['Meat', 'Fish', 'Chicken', 'Pork', 'Beef']):
            details['food_type'] = 'Meat'
            evidence.append(0.1)
        elif id_matches_pattern(item_id, ['Fruit', 'Apple', 'Banana', 'Orange', 'Berry']):
            details['food_type'] = 'Fruit'
            evidence.append(0.1)
        elif id_matches_pattern(item_id, ['Vegetable', 'Carrot', 'Potato', 'Lettuce', 'Tomato']):
            details['food_type'] = 'Vegetable'
            evidence.append(0.1)
        elif id_matches_pattern(item_id, ['Bread', 'Grain', 'Cereal']):
            details['food_type'] = 'Grain'
            evidence.append(0.1)
        elif id_matches_pattern(item_id, ['Spice', 'Condiment', 'Seasoning', 'Salt']):
            details['food_type'] = 'Condiment'
            evidence.append(0.1)
    elif is_drink:
        if id_matches_pattern(item_id, ['Alcohol', 'Beer', 'Wine', 'Vodka', 'Whiskey']):
            details['food_type'] = 'Alcohol'
            evidence.append(0.15)
        else:
            details['food_type'] = 'Beverage'
            evidence.append(0.1)
    
    # Calculate confidence
    confidence = min(1.0, sum(evidence)) if evidence else 0.0
    
    # Match if confidence > 0.4
    matches = confidence > 0.4
    
    return matches, confidence, details


def get_food_tags(item_id, props):
    """
    Generate food tags based on signature match.
    
    Args:
        item_id: Item identifier
        props: Properties string
    
    Returns:
        list: Tag list for this food item
    """
    matches, confidence, details = matches_food_signature(item_id, props)
    
    if not matches:
        return []
    
    tags = []
    
    # Primary tag
    food_type = details.get('food_type', 'General')
    if details.get('is_drink'):
        tags.append(f"Food.Drink.{food_type}")
    else:
        tags.append(f"Food.{food_type}")
    
    # Freshness classification
    if details.get('is_perishable'):
        tags.append("Food.Perishable")
    else:
        tags.append("Food.NonPerishable")
    
    # Nutritional value
    calories = details.get('calories', 0)
    hunger = abs(details.get('hunger_change', 0))
    
    if hunger > 50 or calories > 1000:
        tags.append("Food.HighNutrition")
    elif hunger > 20 or calories > 400:
        tags.append("Food.MediumNutrition")
    else:
        tags.append("Food.LowNutrition")
    
    # Quality
    unhappy = analyzer.get_stat('UnhappyChange') if (analyzer := PropertyAnalyzer(props)) else 0
    if unhappy > 0:
        tags.append("Food.LowQuality")
    elif details.get('is_perishable') and details.get('days_fresh', 0) > 60:
        tags.append("Food.HighQuality")
    
    # Specialization
    if id_matches_pattern(item_id, ['Alcohol', 'Beer', 'Wine']):
        tags.append("Food.Intoxicating")
    
    return tags
