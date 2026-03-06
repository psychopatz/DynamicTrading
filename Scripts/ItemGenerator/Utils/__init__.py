"""
Utils package for ItemGenerator
Modular components for item processing and generation
"""

from .config import *
from .commons.vanilla_loader import load_vanilla_items, get_stat, has_property
from .commons.helpers import sanitize_path
from .commons.parse import get_opening_maps, get_vanilla_data
from .tag.tagging import generate_tags, parse_tags, categorize_item, get_category_from_tags
from .pricing.pricing import calculate_price
from .pricing.stock import calculate_base_max_stock, apply_category_multiplier, calculate_min_stock
from .pricing.economy import calculate_worth
from .output import write_mod_duplicates, write_hierarchical_files
from .commons.lua_handler import process_lua_file, add_items_to_file, get_registered_items, collect_unregistered_items, add_new_items
from .analyze.property_analyzer import (
    find_items_with_property,
    dump_items_by_property,
    list_all_properties,
    analyze_all_properties,
    find_items_by_multiple_properties
)
from .analyze.spawn_analyzer import (
    load_spawn_data,
    get_spawn_weight,
    get_spawn_locations,
    calculate_rarity_from_spawn,
    calculate_rarity_score,
    get_rarity_statistics,
    get_items_by_rarity,
    calculate_enhanced_rarity_score
)
