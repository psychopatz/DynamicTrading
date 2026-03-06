import os
from pathlib import Path

# Default Paths - use absolute parent path
SCRIPT_DIR = Path(__file__).parent.parent.parent.parent  # DynamicTrading root
VANILLA_DIR = "/home/psychopatz/.steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/"
if not os.path.exists(VANILLA_DIR):
    VANILLA_DIR = "/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/"

VANILLA_SCRIPTS_DIR = os.path.join(VANILLA_DIR, "generated/items/")

# Distribution files for spawn rate analysis
_DISTRIB_BASE = VANILLA_DIR.replace("/media/scripts/", "/media/lua/server/")
DISTRIBUTIONS_DIR = os.path.join(_DISTRIB_BASE, "Items/")

MOD_ITEMS_DIR = str(SCRIPT_DIR / "Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items")
OUTPUT_DIR = str(SCRIPT_DIR / "Scripts/Output")

# Exclusion patterns for item registration
EXCLUDED_PATTERNS = [
    r'^Corpse',           # Zombie corpses
    r'^CraftedElectronic', # Crafted items
    r'^Crafted',
    r'^Radio',            # Radio transmissions
    r'^Move_',            # Moveable furniture
    r'^farming',          # Farming-specific
    r'^Hydrocraft',       # Mod items
]

# Category to file mapping
CATEGORY_FILE_MAP = {
    'Food': {
        'Meat': 'Food/DT_Meat.lua',
        'Fruit': 'Food/DT_Perishable.lua',
        'Vegetable': 'Food/DT_Perishable.lua',
        'Drink': 'Food/DT_Drink.lua',
        'Cooking': 'Food/DT_Cooking.lua',
        'Perishable': 'Food/DT_Perishable.lua',
        'NonPerishable': 'Food/DT_NonPerishable.lua',
    },
    'Literature': {
        'SkillBook': 'Literature/DT_SkillBook.lua',
        'Recipe': 'Literature/DT_Recipe.lua',
        'Media': 'Literature/DT_Media.lua',
        'Book': 'Literature/DT_Book.lua',
    },
    'Weapon': {
        'Explosive': 'Weapon/DT_Melee.lua',
        'Firearm': 'Weapon/DT_Ranged.lua',
        'Ranged': 'Weapon/DT_Ranged.lua',
        'Melee': 'Weapon/DT_Melee.lua',
        'Part': 'Weapon/DT_Part.lua',
    },
    'Clothing': {
        'Armor': 'Clothing/DT_Armor.lua',
        'Head': 'Clothing/DT_Head.lua',
        'Hands': 'Clothing/DT_Hands.lua',
        'Feet': 'Clothing/DT_Armor.lua',
        'General': 'Clothing/DT_Armor.lua',
    },
    'Medical': {
        'Surgical': 'Medical/DT_Surgical.lua',
        'General': 'Medical/DT_General.lua',
    },
    'Container': {
        'Backpack': 'Container/DT_Backpack.lua',
        'Accessory': 'Container/DT_Backpack.lua',
        'General': 'Container/DT_Organizer.lua',
    },
    'Tool': {
        'Crafting': 'Tool/DT_Crafting.lua',
        'Farming': 'Tool/DT_Farming.lua',
        'General': 'Tool/DT_General.lua',
    },
    'Resource': {
        'Fuel': 'Resource/DT_Fuel.lua',
        'Material': 'Resource/DT_Material.lua',
    },
    'Electronics': {
        'Battery': 'Electronics/DT_Battery.lua',
        'Gadget': 'Electronics/DT_Gadget.lua',
    },
    'Misc': {
        'General': 'Misc/DT_General.lua',
    },
}
