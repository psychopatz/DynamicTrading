"""Item record creation and tag normalization helpers."""
# pyright: reportMissingImports=false

import re

from ...tag.tagging import parse_tags, get_category_from_tags
from ...pricing.stock import calculate_base_max_stock, apply_category_multiplier, calculate_min_stock
from ...pricing.pricing import calculate_price
from ..vanilla_loader import get_stat
from ...parse.overrides import load_overrides, apply_override
from .parsing import format_item_record


def tags_list_to_dict(tags_list):
    """Convert generated tag list into dict schema used by pricing/stock logic."""
    tag_dict = {
        'primary': 'Misc.General',
        'rarity': 'Common',
        'quality': None,
        'origin': None,
        'theme': [],
    }

    for tag in tags_list or []:
        if not isinstance(tag, str):
            continue
        if tag.startswith('Rarity.'):
            tag_dict['rarity'] = tag.split('.', 1)[1] if '.' in tag else 'Common'
        elif tag.startswith('Quality.'):
            tag_dict['quality'] = tag.split('.', 1)[1] if '.' in tag else None
        elif tag.startswith('Origin.'):
            tag_dict['origin'] = tag.split('.', 1)[1] if '.' in tag else None
        elif tag.startswith('Theme.'):
            tag_dict['theme'].append(tag.split('.', 1)[1] if '.' in tag else 'General')
        elif tag_dict['primary'] == 'Misc.General':
            tag_dict['primary'] = tag

    return tag_dict


def tags_list_to_lua(tags_list):
    """Serialize Python tag list into Lua array literal body: \"a\", \"b\"."""
    return ', '.join(f'"{tag}"' for tag in (tags_list or []) if isinstance(tag, str))


def parse_lua_tags(tags_str):
    """Convert Lua tags string body into parsed tags dict."""
    tags_body = ', '.join(f'"{tag}"' for tag in re.findall(r'"([^"]+)"', tags_str))
    tags_dict = parse_tags('{' + tags_body + '}')
    return tags_body, tags_dict


def create_item_record(item_data, vanilla_items, forced_tags=None, base_price_override=None):
    """Create a structured record for an item row."""
    item_id = item_data['item_id']
    props = item_data['props']
    tags = forced_tags or item_data['tags']

    tags_dict = {
        'primary': tags[0],
        'rarity': 'Common',
        'quality': None,
        'origin': None,
        'theme': [],
    }

    for tag in tags:
        if tag.startswith('Rarity.'):
            tags_dict['rarity'] = tag.split('.')[1]
        elif tag.startswith('Quality.'):
            tags_dict['quality'] = tag.split('.')[1]
        elif tag.startswith('Origin.'):
            tags_dict['origin'] = tag.split('.')[1]
        elif tag.startswith('Theme.'):
            tags_dict['theme'].append(tag)

    price = base_price_override if base_price_override is not None else calculate_price(item_id, props, tags_dict)

    weight = get_stat(props, 'Weight', 0.5) if props else 0.5
    _, subcategories = get_category_from_tags(tags_dict)
    base_max = calculate_base_max_stock(weight)
    final_max = apply_category_multiplier(base_max, tags_dict, subcategories)
    final_min = calculate_min_stock(final_max, tags_dict, subcategories)

    overrides = load_overrides()
    final_price, final_tags, final_min_override, final_max_override, was_overridden = apply_override(
        item_id,
        price,
        tags,
        final_min,
        final_max,
        overrides,
    )

    if was_overridden:
        print(f'  🔧 Applied override to: {item_id}')

    return {
        'item_id': item_id,
        'base_price': int(final_price),
        'tags': final_tags,
        'stock_min': int(final_min_override),
        'stock_max': int(final_max_override),
    }


def create_item_entry(item_data, vanilla_items, forced_tags=None, base_price_override=None):
    """Create a Lua entry for an item."""
    record = create_item_record(
        item_data,
        vanilla_items,
        forced_tags=forced_tags,
        base_price_override=base_price_override,
    )
    return format_item_record(record)
