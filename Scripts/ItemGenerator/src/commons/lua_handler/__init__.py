"""Lua handler package for item registry read/write operations."""
# pyright: reportMissingImports=false

from .builders import build_lua_file_content, cleanup_empty_lua_files, ensure_lua_file_exists, ensure_lua_files_exist
from .records import create_item_entry
from .operations import (
    process_lua_file,
    get_registered_items,
    collect_unregistered_items,
    add_items_to_file,
    add_new_items,
    cleanup_blacklisted_items,
)
from .liquid_generation import rebuild_liquid_registries

__all__ = [
    'build_lua_file_content',
    'cleanup_empty_lua_files',
    'ensure_lua_file_exists',
    'ensure_lua_files_exist',
    'process_lua_file',
    'get_registered_items',
    'collect_unregistered_items',
    'add_items_to_file',
    'add_new_items',
    'cleanup_blacklisted_items',
    'rebuild_liquid_registries',
    'create_item_entry',
]
