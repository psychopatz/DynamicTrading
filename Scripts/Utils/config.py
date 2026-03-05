import os

# Default Paths
VANILLA_DIR = "/home/psychopatz/.steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/"
if not os.path.exists(VANILLA_DIR):
    VANILLA_DIR = "/home/psychopatz/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid/media/scripts/"

MOD_ITEMS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common/Items/")
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../Output/")
