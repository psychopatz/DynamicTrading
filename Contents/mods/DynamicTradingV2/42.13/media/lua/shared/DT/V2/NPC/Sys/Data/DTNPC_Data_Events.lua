-- ==============================================================================
-- DTNPC_Data_Events.lua
-- Shared event bootstrap for the NPC data system.
-- ==============================================================================

Events.OnGameStart.Add(function()
    DynamicTrading.Log("DTV2", "Init", "NPC", "NPC Data System Loaded")
end)
