-- ==============================================================================
-- DTNPC_Bandits.lua
-- Shared entry point for the split bandits subsystem.
-- Loads client/server leaves based on the current runtime context.
-- ==============================================================================

DTNPCBandits = DTNPCBandits or {}
DTNPCBandits.Internal = DTNPCBandits.Internal or {}

DTNPCBanditClient = DTNPCBanditClient or {}
DTNPCBanditClient.Internal = DTNPCBanditClient.Internal or {}

local function isCurrencyExpandedActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("CurrencyExpanded") or false
end

DTNPCBandits.EntryLoaded = true
DTNPCBandits.IsCurrencyExpandedActive = DTNPCBandits.IsCurrencyExpandedActive or isCurrencyExpandedActive
DTNPCBandits.IsBanditSubsystemActive = DTNPCBandits.IsBanditSubsystemActive or isCurrencyExpandedActive

DTNPCBandits.IsBanditFaction = DTNPCBandits.IsBanditFaction or function()
    return false
end
DTNPCBandits.MakeGroupHostile = DTNPCBandits.MakeGroupHostile or function()
    return false
end
DTNPCBandits.OnBanditDamagedByPlayer = DTNPCBandits.OnBanditDamagedByPlayer or function()
    return false
end
DTNPCBandits.EnsureBanditFaction = DTNPCBandits.EnsureBanditFaction or function()
    return false
end
DTNPCBandits.StartDemand = DTNPCBandits.StartDemand or function() end
DTNPCBandits.PayDemand = DTNPCBandits.PayDemand or function() end
DTNPCBandits.RefuseDemand = DTNPCBandits.RefuseDemand or function() end
DTNPCBandits.SpawnAmbushForPlayer = DTNPCBandits.SpawnAmbushForPlayer or function()
    return false
end

DTNPCBanditClient.ShowRaidForecast = DTNPCBanditClient.ShowRaidForecast or function() end
DTNPCBanditClient.ShowDemand = DTNPCBanditClient.ShowDemand or function() end
DTNPCBanditClient.RequestDemandForUI = DTNPCBanditClient.RequestDemandForUI or function()
    return false
end
DTNPCBanditClient.OpenDemand = DTNPCBanditClient.OpenDemand or function()
    return false
end

local shouldLoadServer = (not isClient()) or isServer()
local shouldLoadClient = (not isServer()) or isClient()
local banditsActive = isCurrencyExpandedActive()

if shouldLoadServer and banditsActive and not DTNPCBandits.ServerEntryLoaded then
    DTNPCBandits.ServerEntryLoaded = true
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Server_Shared"
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Server_Faction"
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Server_Demand"
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Server_Raid"
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Server_Debug"
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Server_Events"
end

if shouldLoadClient and banditsActive and not DTNPCBanditClient.EntryLoaded then
    DTNPCBanditClient.EntryLoaded = true
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Client_State"
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Client_Forecast"
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Client_Demand"
    require "DT/V2/NPC/Bandits/DTNPC_Bandits_Client_Events"
end

return DTNPCBandits
