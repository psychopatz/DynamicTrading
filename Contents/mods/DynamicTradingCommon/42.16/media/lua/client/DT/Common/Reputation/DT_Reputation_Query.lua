if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

local function resolveFactionSnapshot(factionID)
    if not factionID then
        return nil
    end

    local snapshots = {
        DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions or nil,
        DT_V2_RadarManager and DT_V2_RadarManager.ClientFactions or nil,
        DT_FactionInfoWindow and DT_FactionInfoWindow.cachedFactionData or nil,
        ModData.get("DynamicTrading_Factions") or nil,
    }

    for _, source in ipairs(snapshots) do
        if type(source) == "table" and type(source[factionID]) == "table" then
            return source[factionID]
        end
    end

    return nil
end

local function getDefaultPersonalRep(factionID)
    local faction = resolveFactionSnapshot(factionID)
    if type(faction) ~= "table" then
        return 0
    end

    if tostring(faction.factionType or "") == "bandit"
        or tostring(factionID or "") == "Bandits"
        or faction.hostileToPlayers == true
        or faction.alwaysHostile == true then
        return DT_Reputation.REP_MIN
    end

    return 0
end

function DT_Reputation.GetPersonalRep(traderUUID, factionID)
    if not traderUUID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end

    local stored = DT_Reputation.state.personalRep[traderUUID]
    if stored ~= nil then
        return stored
    end

    return getDefaultPersonalRep(factionID)
end

function DT_Reputation.GetFactionBias(factionID)
    if not factionID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end
    return DT_Reputation.state.factionBias[factionID] or 0
end

function DT_Reputation.GetEffectiveRep(traderUUID, factionID)
    if not DT_Reputation.EnsureLoaded() then return 0 end

    local personal = traderUUID and DT_Reputation.GetPersonalRep(traderUUID, factionID) or 0
    local bias = factionID and (DT_Reputation.state.factionBias[factionID] or 0) or 0

    return DT_Reputation.Clamp(personal + bias)
end

function DT_Reputation.GetFactionRep(factionID, rosterData)
    if not factionID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end

    local useCache = (rosterData == nil)
    if useCache then
        local cached = DT_Reputation.state.factionRepCache[factionID]
        if cached ~= nil then
            return cached
        end
    end

    local roster = rosterData or ModData.get("DynamicTrading_Roster") or {}
    local members = roster.FactionMembers and roster.FactionMembers[factionID]
    if (not members or #members == 0) and roster.Souls then
        members = {}
        for uuid, soul in pairs(roster.Souls) do
            if soul and soul.factionID == factionID then
                table.insert(members, uuid)
            end
        end
    end

    local souls = roster.Souls or {}
    local bias = DT_Reputation.state.factionBias[factionID] or 0

    if not members or #members == 0 then
        local result = DT_Reputation.Clamp(bias)
        if useCache then
            DT_Reputation.state.factionRepCache[factionID] = result
        end
        return result
    end

    local state = DT_Reputation.state
    local total = 0
    local count = 0

    for _, uuid in ipairs(members) do
        if Internal.IsSoulAlive(souls[uuid]) then
            local personal = DT_Reputation.GetPersonalRep(uuid, factionID)
            total = total + DT_Reputation.Clamp(personal + bias)
            count = count + 1
        end
    end

    if count <= 0 then
        local result = DT_Reputation.Clamp(bias)
        if useCache then
            DT_Reputation.state.factionRepCache[factionID] = result
        end
        return result
    end

    local result = DT_Reputation.Clamp(total / count)
    if useCache then
        DT_Reputation.state.factionRepCache[factionID] = result
    end
    return result
end

function DT_Reputation.GetTradeProgress(traderUUID)
    if not traderUUID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end
    return DT_Reputation.state.tradeProgress[traderUUID] or 0
end

function DT_Reputation.GetTotalBought(traderUUID)
    if not traderUUID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end
    return DT_Reputation.state.totalBought[traderUUID] or 0
end

function DT_Reputation.GetTotalSold(traderUUID)
    if not traderUUID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end
    return DT_Reputation.state.totalSold[traderUUID] or 0
end

function DT_Reputation.GetTotalGifted(traderUUID)
    if not traderUUID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end
    return DT_Reputation.state.totalGifted[traderUUID] or 0
end

function DT_Reputation.GetCombinedTradeValue(traderUUID)
    if not traderUUID then return 0 end
    if not DT_Reputation.EnsureLoaded() then return 0 end

    return (DT_Reputation.state.totalBought[traderUUID] or 0)
        + (DT_Reputation.state.totalSold[traderUUID] or 0)
        + (DT_Reputation.state.totalGifted[traderUUID] or 0)
end
