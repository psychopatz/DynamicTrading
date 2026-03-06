"""
Utils package for ItemGenerator
Modular components for item processing and generation
"""

from .config import *
from .vanilla_loader import load_vanilla_items, get_stat, has_property
from .tagging import generate_tags, parse_tags, categorize_item, get_category_from_tags
from .pricing import calculate_price
from .stock import calculate_base_max_stock, apply_category_multiplier, calculate_min_stock
from .lua_handler import process_lua_file, add_items_to_file, get_registered_items, collect_unregistered_items, add_new_items
from .property_analyzer import (
    find_items_with_property,
    dump_items_by_property,
    list_all_properties,
    analyze_all_properties,
    find_items_by_multiple_properties
)
from .spawn_analyzer import (
    load_spawn_data,
    get_spawn_weight,
    get_spawn_locations,
    calculate_rarity_from_spawn,
    calculate_rarity_score,
    get_rarity_statistics,
    get_items_by_rarity,
    calculate_enhanced_rarity_score
)
