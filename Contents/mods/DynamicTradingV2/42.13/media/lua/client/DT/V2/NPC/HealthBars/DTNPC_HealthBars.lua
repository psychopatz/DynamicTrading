-- ==============================================================================
-- DTNPC_HealthBars.lua
-- Entry point for Dynamic Trading NPC health bars.
-- Loads health bar modules in explicit dependency order.
-- ==============================================================================

require "ISUI/ISUIElement"
require "DT/Common/Reputation/DT_Reputation"

DTNPCClient = DTNPCClient or {}
DTNPC_HealthBars = DTNPC_HealthBars or {}

local HealthBars = DTNPC_HealthBars

if HealthBars.EntryLoaded then
    return
end

HealthBars.EntryLoaded = true
HealthBars.Modules = HealthBars.Modules or {}
HealthBars.Constants = HealthBars.Constants or {}
HealthBars.Helpers = HealthBars.Helpers or {}
HealthBars.State = HealthBars.State or {}

require "DT/V2/NPC/HealthBars/DTNPC_HealthBars_Core"
require "DT/V2/NPC/HealthBars/DTNPC_HealthBars_Tracking"
require "DT/V2/NPC/HealthBars/DTNPC_HealthBars_Manager"
require "DT/V2/NPC/HealthBars/DTNPC_HealthBars_Render"
require "DT/V2/NPC/HealthBars/DTNPC_HealthBars_Update"
require "DT/V2/NPC/HealthBars/DTNPC_HealthBars_Events"
