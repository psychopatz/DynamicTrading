-- ==============================================================================
-- DT_V2_RadarManager_Core.lua
-- Shared state and initialization for the radar manager.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

RadarManager.FoundTraders = RadarManager.FoundTraders or {}
RadarManager.ClientRoster = RadarManager.ClientRoster
RadarManager.ClientFactions = RadarManager.ClientFactions

if not RadarManager.Ranges then
    RadarManager.Ranges = {
        ["Base.WalkieTalkie1"] = 750,
        ["Base.WalkieTalkie2"] = 2000,
        ["Base.WalkieTalkie3"] = 4000,
        ["Base.WalkieTalkie4"] = 8000,
        ["Base.WalkieTalkie5"] = 10000,
        ["Base.HamRadio1"] = 12000,
        ["Base.HamRadio2"] = 15000,
        ["Base.ManPackRadio"] = 12000,
        ["Base.WalkieTalkieMakeShift"] = 1000,
        ["Base.HamRadioMakeShift"] = 10000,
        ["Makeshift Ham Radio"] = 10000,
        ["US ARMY COMM. Ham Radio"] = 15000,
        ["Premium Technologies Ham Radio"] = 12000,
    }
end

function RadarManager.Init()
    local data = ModData.getOrCreate("DT_V2_RadarFound")
    RadarManager.FoundTraders = data

    if RadarManager.InitScanState then
        RadarManager.InitScanState()
    end

    if not isClient() then
        RadarManager.ClientRoster = ModData.get("DynamicTrading_Roster")
        RadarManager.ClientFactions = ModData.get("DynamicTrading_Factions")
    end

    DynamicTrading.Log("DTV2", "Radio", "Init", "Manager Initialized. Traders in cache: " .. RadarManager.GetCount())
end

function RadarManager.GetCount()
    local count = 0
    for _ in pairs(RadarManager.FoundTraders) do
        count = count + 1
    end
    return count
end
