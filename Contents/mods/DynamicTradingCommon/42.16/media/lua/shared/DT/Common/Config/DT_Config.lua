DynamicTrading = DynamicTrading or {}
require "DT/Common/DT_Logger"
DynamicTrading.Config = DynamicTrading.Config or {}

require "DT/Common/Config/DT_Config_ItemRegistry"
require "DT/Common/Config/DT_Config_ArchetypeRegistry"
require "DT/Common/Config/DT_Config_ArchetypeSkillRegistry"
require "DT/Common/Config/ConfigArchetypeEquipment/DT_Config_ArchetypeEquipment"
require "DT/Common/Config/DT_Config_DialogueRegistry"
require "DT/Common/Config/DT_Config_DynamicLoader"
require "DT/Common/Config/DT_Config_GameplayHelpers"

-- =============================================================================
-- 6. EVENT SYSTEM
-- =============================================================================
require "DT/Common/Events/DT_EventManager"
require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs"
require "DT/Common/Logging/DT_GameplayLogRegistry"
require "DT/Common/Config/DT_Config_FactionSystem"
require "DT/Common/Logging/DT_GameplayEvents"

if DynamicTrading.LoadGameplayLogRegistry then
	DynamicTrading.LoadGameplayLogRegistry()
end

DynamicTrading.Log("DTCommons", "Core", "Init", "Config & Registry Core Loaded.")
 
-- Trigger the loading process LATER to avoid recursive require loops
Events.OnGameBoot.Add(DynamicTrading.LoadArchetypes)
