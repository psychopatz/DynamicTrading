"""
Commons subsystem - Reusable utilities and infrastructure
"""
# pyright: reportMissingImports=false

import importlib.util
from pathlib import Path

# Vanilla loader utilities
from .vanilla_loader import (
    load_vanilla_items,
    get_stat,
    get_property_value,
    count_learned_recipes
)

# Tagging
from ..tagging import parse_tags, generate_tags, is_excluded, get_category_from_tags

# Pricing (load legacy pricing.py directly to avoid package name collision)
_utils_dir = Path(__file__).parent.parent
_pricing_spec = importlib.util.spec_from_file_location("_dt_pricing", _utils_dir / "pricing.py")
_pricing_module = importlib.util.module_from_spec(_pricing_spec)
_pricing_spec.loader.exec_module(_pricing_module)
calculate_price = _pricing_module.calculate_price

# Stock
from ..stock import calculate_base_max_stock, apply_category_multiplier, calculate_min_stock

# Lua file handling
from .lua_handler import (
    ensure_lua_files_exist,
    process_lua_file,
    get_registered_items,
    collect_unregistered_items,
    add_new_items,
    create_item_entry
)

# Item data structures and utilities
from .items import (
    ItemData,
    PriceBreakdown,
    calculate_price_breakdown,
    should_include_item,
    filter_items_by_tag,
    calculate_price_tier,
    validate_item_entry
)

# Error handling
from .error_handler import (
    ItemGeneratorError,
    DataLoadError,
    ValidationError,
    PricingError,
    OutputError,
    ErrorHandler,
    safe_int_conversion,
    safe_float_conversion,
    validate_required_field,
    validate_file_exists
)

__all__ = [
    # Vanilla loader
    'load_vanilla_items',
    'get_stat',
    'get_property_value',
    'count_learned_recipes',
    
    # Tagging
    'parse_tags',
    'generate_tags',
    'is_excluded',
    'get_category_from_tags',
    
    # Pricing
    'calculate_price',
    'calculate_base_max_stock',
    'apply_category_multiplier',
    'calculate_min_stock',
    
    # Lua handling
    'ensure_lua_files_exist',
    'process_lua_file',
    'get_registered_items',
    'collect_unregistered_items',
    'add_new_items',
    'create_item_entry',
    
    # Items
    'ItemData',
    'PriceBreakdown',
    'calculate_price_breakdown',
    'should_include_item',
    'filter_items_by_tag',
    'calculate_price_tier',
    'validate_item_entry',
    
    # Error handling
    'ItemGeneratorError',
    'DataLoadError',
    'ValidationError',
    'PricingError',
    'OutputError',
    'ErrorHandler',
    'safe_int_conversion',
    'safe_float_conversion',
    'validate_required_field',
    'validate_file_exists'
]
