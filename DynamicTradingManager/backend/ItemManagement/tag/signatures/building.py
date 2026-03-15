"""
Building & Construction property-based signatures.
Detects moveable furniture/building objects (Mov_*), raw construction materials,
structural fasteners, and building-support tools.

Tag taxonomy produced:
  Building.Moveable     – moveable world objects (Mov_* prefix in vanilla/mods)
  Building.Material     – raw construction materials (timber, metal, nails, screws …)
  Building.Furniture    – static/decorative furniture not prefixed Mov_
  Building.Fixture      – plumbing, wiring, fixtures (pipes, valves, doorknobs …)
  Building.Vehicle      – vehicle maintenance parts (engine parts, windows …)
  Building.Garden       – gardening supplies, planting pots, compost, tools
  Building.Garden.Seed  – seeds, bulbs, saplings, and cuttings (plantable items)
"""
import re

from .helpers import get_stat, has_property, id_matches_pattern, get_display_category, extract_tags_from_props, PropertyAnalyzer


# --------------------------------------------------------------------------
# ID token lists
# --------------------------------------------------------------------------
MOV_PREFIX = ['Mov_']          # moveable world-objects in vanilla & most mods

MATERIAL_ID = [
    'Plank', 'Lumber', 'Timber', 'Log', 'Beam',
    'Nail', 'Nails', 'Screw', 'Screws', 'Bolt', 'Nut', 'Rivet',
    'Wire', 'BarbedWire', 'WireStack',
    'Sheet', 'MetalSheet', 'SteelSheet',
    'Rebar', 'Rod', 'Bar',
    'Concrete', 'Cement', 'Brick', 'Cinder',
    'Grout', 'Tile', 'Drywall', 'Sheetrock',
    'Aluminum', 'AluminumScrap', 'AluminumFragments',
    'Hematite', 'Malachite',
    'LargePlank', 'LargeStone', 'SmallStone',
    'GlassPanel', 'GlassShard',
    'Insulation', 'Caulk',
    'PaintRoll', 'PaintBrush', 'PaintBucket',
    'Varnish', 'Lacquer', 'Stain',
    'Adhesive', 'DuctTape', 'GlueStick',
    'DrawPlate', 'MetalPipe',
]

FIXTURE_ID = [
    'Valve', 'Pipe', 'PipeWrench', 'PlumbingPipe',
    'Doorknob', 'DoorHinge', 'Hinge', 'Hasp', 'Padlock',
    'Drawer', 'CabinetHandle',
    'LightBulb', 'LightBulbBox', 'LightSwitch',
    'ElectricWire', 'ElectricBox', 'PowerBoxPart',
    'HomeAlarm',
]

FURNITURE_ID = [
    'Mattress', 'Rug', 'Curtain', 'Blind',
    'Candle', 'Lamp', 'Lantern',
    'Shelf', 'Rack', 'Cabinet',
    'Frame', 'PictureFrame',
]

VEHICLE_PART_ID = [
    'EngineDoor', 'EngineParts', 'FrontWindow',
    'LugWrench', 'Jack', 'HoodOrnament',
    'TirePatch', 'TireRepair',
    'BrakeFluid', 'PowerSteering', 'CoolantBottle', 'TransFluid',
]

SEED_ID = [
    'Seed', 'BagSeed', 'SeedPacket', 'SeedPouch',
    'BulbSack', 'Bulb',
    'Sapling', 'Sprout', 'Cutting',
]

GARDEN_ID = [
    'Fertilizer', 'Compost', 'PeatMoss',
    'Planter', 'Trough', 'Herb', 'CropRow',
]

# DisplayCategory values from vanilla that map cleanly to Building
MATERIAL_DISPLAY_CATS = {
    'material', 'reciperesource', 'materialweapon',
}
FURNITURE_DISPLAY_CATS = {
    'furniture',
}
VEHICLE_DISPLAY_CATS = {
    'vehiclemaintenance',
}
GARDEN_DISPLAY_CATS = {
    'gardening',
}
FIXTURE_DISPLAY_CATS = {
    'household',
}

# Script Tags (PZ Tags = field) that are reliable building indicators
BUILDING_SCRIPT_TAGS = {
    'base:hasmetal',
    'base:smeltablesteelsmall', 'base:smeltablessteellarge',
    'base:smeltableironsmall',  'base:smeltableironmedium',
    'base:smeltableironlarge',
    'base:steelmaterial',
    'base:heavyitem',
    'base:toolhead',
    'base:glass',
}


# --------------------------------------------------------------------------
# Helper: get normalised DisplayCategory
# --------------------------------------------------------------------------
def _display_cat(props):
    """Return lowercase DisplayCategory value from raw props string."""
    val = get_display_category(props)
    return val.lower() if val else ''


def _script_tags(props):
    """Return set of lowercase script-tag tokens from the Tags= field."""
    return {t.lower() for t in extract_tags_from_props(props)}


# --------------------------------------------------------------------------
# Signature
# --------------------------------------------------------------------------

def matches_building_signature(item_id, props):
    """
    Detect building-related items.

    Evaluation order (stops at first positive sub-type):
      1. Mov_* prefix           → Building.Moveable
      2. DisplayCategory        → direct map
      3. ID token lists         → material / fixture / vehicle / garden / furniture
      4. Script-tag overlap     → general building material

    Returns:
        tuple: (matches: bool, confidence: float, details: dict)
    """
    item_id_lower = item_id.lower()
    disp_cat = _display_cat(props)
    script_tags = _script_tags(props)

    details = {
        'building_type': None,
        'is_moveable': False,
        'display_cat': disp_cat,
    }

    # ── 0. Hard exclusion guards (other categories take precedence) ───────
    # Weapons: anything with real damage stats or explicitly typed as Weapon
    if get_stat('MinDamage', props) >= 0.5 or get_stat('MaxDamage', props) >= 0.5:
        return False, 0.0, details
    if has_property('Type', props, 'Weapon'):
        return False, 0.0, details
    # Clothing
    if has_property('BodyLocation', props):
        return False, 0.0, details
    # Food / drink
    if has_property('HungerChange', props) or has_property('ThirstChange', props):
        return False, 0.0, details
    # Active / consumable light sources should be routed by non-building
    # signatures instead of furniture/fixture heuristics.
    if disp_cat in {'lightsource', 'firesource'}:
        return False, 0.0, details
    # Pure electronics display categories belong to the electronics pipeline.
    if disp_cat == 'electronics':
        return False, 0.0, details
    # Battery-branded items should be handled by electronics even when they are
    # used in vehicle maintenance.
    if id_matches_pattern(item_id, ['Battery']):
        return False, 0.0, details
    # Ammunition
    if has_property('AmmoType', props) or has_property('ProjectileCount', props):
        return False, 0.0, details
    # Recipe books / magazines / schematics (literature-like media)
    if re.search(r"(LearnedRecipes|TeachedRecipes|SkillTrained|LvlSkillTrained|NumLevelsTrained|NumberOfPages|LiteratureOnRead)\s*=", props, re.IGNORECASE):
        if re.search(r"(skillbook|book\d*$|mag\d*$|magazine|comic|schematic|manual|guide|journal|recipeclipping)", item_id, re.IGNORECASE):
            return False, 0.0, details

    # ── 1. Mov_* prefix: always a moveable building object ───────────────
    if item_id.startswith('Mov_') or id_matches_pattern(item_id, MOV_PREFIX):
        details['building_type'] = 'Moveable'
        details['is_moveable'] = True
        return True, 0.95, details

    # ── 2. DisplayCategory direct map ────────────────────────────────────
    if disp_cat in MATERIAL_DISPLAY_CATS:
        details['building_type'] = 'Material'
        return True, 0.90, details

    if disp_cat in FURNITURE_DISPLAY_CATS:
        details['building_type'] = 'Furniture'
        return True, 0.85, details

    if disp_cat in VEHICLE_DISPLAY_CATS:
        details['building_type'] = 'Vehicle'
        return True, 0.85, details

    if disp_cat in GARDEN_DISPLAY_CATS:
        if id_matches_pattern(item_id, SEED_ID):
            details['building_type'] = 'Garden.Seed'
            return True, 0.88, details
        details['building_type'] = 'Garden'
        return True, 0.85, details

    # Fixture/household electronics (distinguishable from true gadgets by
    # absence of AmmoType / BatteryMod and no DrainableUses)
    if disp_cat in FIXTURE_DISPLAY_CATS:
        has_battery = has_property('BatteryMod', props) or has_property('RequiresElectricity', props)
        has_ammo = has_property('AmmoType', props)
        is_drainable = get_stat('UseDelta', props) > 0
        if not has_battery and not has_ammo and not is_drainable:
            details['building_type'] = 'Fixture'
            return True, 0.80, details

    # ── 3. ID token matching ──────────────────────────────────────────────
    if id_matches_pattern(item_id, MATERIAL_ID):
        details['building_type'] = 'Material'
        return True, 0.80, details

    if id_matches_pattern(item_id, FIXTURE_ID):
        details['building_type'] = 'Fixture'
        return True, 0.78, details

    if id_matches_pattern(item_id, VEHICLE_PART_ID):
        details['building_type'] = 'Vehicle'
        return True, 0.78, details

    if id_matches_pattern(item_id, SEED_ID):
        details['building_type'] = 'Garden.Seed'
        return True, 0.78, details

    if id_matches_pattern(item_id, GARDEN_ID):
        details['building_type'] = 'Garden'
        return True, 0.75, details

    if id_matches_pattern(item_id, FURNITURE_ID):
        details['building_type'] = 'Furniture'
        return True, 0.72, details

    # ── 4. Script-tag overlap ─────────────────────────────────────────────
    # Only use script-tag evidence when the display category isn't clearly
    # non-building (mementos, junk, jewellery, etc.).
    NON_BUILDING_DISPLAY_CATS = {'memento', 'junk', 'jewelry', 'ammo', 'camping',
                                  'fishing', 'cartography', 'firstaid', 'sports',
                                  'animalpart', 'cooking', 'literature', 'skillbook'}
    if disp_cat not in NON_BUILDING_DISPLAY_CATS:
        overlap = script_tags & BUILDING_SCRIPT_TAGS
        if len(overlap) >= 1:
            details['building_type'] = 'Material'
            details['script_tag_evidence'] = list(overlap)
            return True, 0.70, details

    return False, 0.0, details


# --------------------------------------------------------------------------
# Tag generator
# --------------------------------------------------------------------------

def get_building_tags(item_id, props):
    """
    Generate Building.* tags from the signature match.

    Primary tag hierarchy:
      Building.Moveable   | Building.Material   | Building.Furniture
      Building.Fixture    | Building.Vehicle    | Building.Garden

    Additional quality descriptors:
      Quality.Waste   when item name contains "broken"/"scrap"/"damaged"
    """
    matches, confidence, details = matches_building_signature(item_id, props)

    if not matches:
        return []

    building_type = details.get('building_type', 'Material')
    tags = [f"Building.{building_type}"]

    # Quality descriptor
    lower_id = item_id.lower()
    if any(t in lower_id for t in ('broken', 'scrap', 'damaged', 'dirty', 'old', 'rusted')):
        tags.append('Quality.Waste')

    return tags
