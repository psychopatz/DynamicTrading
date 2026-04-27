-- ==============================================================================
-- DT_V2_RadarManager_Accessors.lua
-- Shared data access helpers for the radar manager.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

function RadarManager.GetRosterData()
    local rosterData = RadarManager.ClientRoster
    if not isClient() and not rosterData then
        rosterData = ModData.get("DynamicTrading_Roster")
    end
    return rosterData
end

function RadarManager.GetSoul(uuid)
    if isClient() and RadarManager.ClientRoster and RadarManager.ClientRoster.Souls then
        return RadarManager.ClientRoster.Souls[uuid]
    end

    local data = ModData.get("DynamicTrading_Roster")
    if data and data.Souls then
        return data.Souls[uuid]
    end

    return nil
end

function RadarManager.GetFaction(factionID)
    if isClient() and RadarManager.ClientFactions then
        return RadarManager.ClientFactions[factionID]
    end

    local data = ModData.get("DynamicTrading_Factions")
    if data then
        return data[factionID]
    end

    return nil
end

function RadarManager.IsBanditFactionID(factionID)
    if DTNPCBandits and DTNPCBandits.IsBanditFaction then
        local ok, result = pcall(DTNPCBandits.IsBanditFaction, factionID)
        if ok and result == true then
            return true
        end
    end

    return tostring(factionID or "") == "Bandits"
end

function RadarManager.IsRadioDiscoverableSoul(soul)
    if type(soul) ~= "table" then
        return false
    end

    if RadarManager.IsBanditFactionID and RadarManager.IsBanditFactionID(soul.factionID) then
        return false
    end

    if soul.isBandit == true then
        return false
    end

    local archetypeID = tostring(soul.archetypeID or soul.archetype or soul.occupation or "")
    if archetypeID == "Bandit" then
        return false
    end

    return true
end
