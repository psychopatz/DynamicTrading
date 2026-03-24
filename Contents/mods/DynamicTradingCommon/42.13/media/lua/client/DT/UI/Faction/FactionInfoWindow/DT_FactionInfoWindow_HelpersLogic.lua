function DT_FactionInfoWindow.shallowCopy(source)
    local copy = {}
    if type(source) ~= "table" then
        return copy
    end

    for key, value in pairs(source) do
        copy[key] = value
    end

    return copy
end

function DT_FactionInfoWindow.clearFactionSoulCache(rosterData, factionID)
    if type(rosterData) ~= "table" or type(rosterData.Souls) ~= "table" then
        return
    end

    local members = rosterData.FactionMembers and rosterData.FactionMembers[factionID]
    if type(members) ~= "table" then
        return
    end

    for _, uuid in ipairs(members) do
        rosterData.Souls[uuid] = nil
    end
end

function DT_FactionInfoWindow.resolveFactionData()
    local merged = DT_FactionInfoWindow.shallowCopy(DT_FactionInfoWindow.cachedFactionData)
    local factionData = ModData.get("DynamicTrading_Factions")

    if type(factionData) == "table" then
        for key, value in pairs(factionData) do
            merged[key] = value
        end
    end

    return merged
end

function DT_FactionInfoWindow.resolveRosterData()
    local merged = DT_FactionInfoWindow.shallowCopy(DT_FactionInfoWindow.cachedRosterData)
    local rosterData = ModData.get("DynamicTrading_Roster")

    if type(rosterData) == "table" then
        for key, value in pairs(rosterData) do
            merged[key] = value
        end

        if type(DT_FactionInfoWindow.cachedRosterData) == "table" or type(rosterData.Souls) == "table" then
            merged.Souls = DT_FactionInfoWindow.shallowCopy(DT_FactionInfoWindow.cachedRosterData and DT_FactionInfoWindow.cachedRosterData.Souls)
            if type(rosterData.Souls) == "table" then
                for key, value in pairs(rosterData.Souls) do
                    merged.Souls[key] = value
                end
            end
        end

        if type(DT_FactionInfoWindow.cachedRosterData) == "table" or type(rosterData.FactionMembers) == "table" then
            merged.FactionMembers = DT_FactionInfoWindow.shallowCopy(DT_FactionInfoWindow.cachedRosterData and DT_FactionInfoWindow.cachedRosterData.FactionMembers)
            if type(rosterData.FactionMembers) == "table" then
                for key, value in pairs(rosterData.FactionMembers) do
                    merged.FactionMembers[key] = value
                end
            end
        end
    end

    return merged
end

function DT_FactionInfoWindow.GetOwnedFactionID()
    local status = DT_FactionInfoWindow.cachedOwnedFactionStatus
    local faction = status and status.faction or nil
    local factionID = faction and faction.id or nil
    if factionID and tostring(factionID) ~= "" then
        return tostring(factionID)
    end
    return nil
end

-- =============================================================================
-- HELPER: INJECT V1 VIRTUAL FACTION
-- =============================================================================
function DT_FactionInfoWindow.InjectV1VirtualFaction(factionData)
    local isV1 = (DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetData) ~= nil
    if not isV1 then return factionData end

    -- Only inject if there aren't *real* V2 factions taking precedence
    local hasFactions = false
    if type(factionData) == "table" then
        for _ in pairs(factionData) do hasFactions = true break end
    end
    
    local newFactionData = {}
    if type(factionData) == "table" then
        for k,v in pairs(factionData) do newFactionData[k] = v end
    end

    if not hasFactions then
        local wealth = 0
        -- Use the correct V1 wealth accessor (from ModData)
        if ModData.exists("DynamicTrading_Engine") then
            local engine = ModData.get("DynamicTrading_Engine")
            wealth = engine and engine.globalWealth or 0
        end

        local count = 0
        if DynamicTrading.Manager.GetDiscoveredCount then 
            count = DynamicTrading.Manager.GetDiscoveredCount(getSpecificPlayer(0)) 
        end
        
        newFactionData["V1_RADIO"] = {
            id = "V1_RADIO",
            name = "Radio Network",
            state = "Stable",
            memberCount = count,
            wealth = wealth,
            isV1 = true
        }
    end
    return newFactionData
end
