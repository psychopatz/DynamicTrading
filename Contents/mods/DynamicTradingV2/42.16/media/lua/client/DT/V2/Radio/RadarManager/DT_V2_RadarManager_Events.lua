-- ==============================================================================
-- DT_V2_RadarManager_Events.lua
-- Event registration for the radar manager.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

Events.OnServerCommand.Add(RadarManager.HandleServerCommand)
Events.OnGameStart.Add(RadarManager.Init)
