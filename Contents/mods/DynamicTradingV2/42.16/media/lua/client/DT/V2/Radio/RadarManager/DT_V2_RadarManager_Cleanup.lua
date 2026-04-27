-- ==============================================================================
-- DT_V2_RadarManager_Cleanup.lua
-- Cleanup routines for inactive or expired radar entries.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

local function normalizeText(value)
    local text = tostring(value or "")
    if text == "" then
        return nil
    end
    return string.lower(text)
end

local function isCallableTradeActiveForPlayer(soul, player)
    if not soul or soul.contactVisitActive ~= true or not player then
        return false
    end

    local playerID = player.getOnlineID and player:getOnlineID() or nil
    local requestedByID = soul.contactVisitRequestedByID
    local username = normalizeText(player.getUsername and player:getUsername() or nil)
    local requestedByName = normalizeText(soul.contactVisitRequestedBy)
    local isRequestedByPlayer = false

    if playerID ~= nil and requestedByID ~= nil and tonumber(requestedByID) == tonumber(playerID) then
        isRequestedByPlayer = true
    elseif username and requestedByName == username then
        isRequestedByPlayer = true
    end

    if not isRequestedByPlayer then
        return false
    end

    local status = tostring(soul.status or "")
    local state = tostring(soul.state or "")
    local returnStatus = tostring(soul.returnStatus or "")
    local visitMode = tostring(soul.contactVisitMode or "")

    return (status == "Away" and returnStatus == "Trading")
        or status == "Trading"
        or state == "Departure"
        or state == "Trading"
        or state == "Follow"
        or visitMode == "Departure"
        or visitMode == "Trading"
        or visitMode == "Follow"
end

function RadarManager.Cleanup(player)
    local rosterData = RadarManager.GetRosterData()
    if not rosterData or not rosterData.Souls then
        return
    end

    local currentHours = getGameTime():getWorldAgeHours()
    local toRemove = {}
    local playerObj = player or getSpecificPlayer(0)

    for uuid, _ in pairs(RadarManager.FoundTraders) do
        local soul = rosterData.Souls[uuid]
        local isExpiredTrading = soul and soul.status == "Trading" and soul.returnTime and soul.returnTime <= currentHours
        local isDeparting = soul and soul.state == "Departure"
        local isCallableForPlayer = isCallableTradeActiveForPlayer(soul, playerObj)
        local isDiscoverable = soul and (RadarManager.IsRadioDiscoverableSoul == nil or RadarManager.IsRadioDiscoverableSoul(soul)) or false
        if not soul or not isDiscoverable or soul.status ~= "Trading" or isExpiredTrading or isDeparting or isCallableForPlayer then
            table.insert(toRemove, {
                uuid = uuid,
                isCallableForPlayer = isCallableForPlayer,
            })
        end
    end

    for _, removal in ipairs(toRemove) do
        local uuid = removal.uuid
        local soul = rosterData.Souls[uuid]
        local traderName = (soul and soul.name) or (RadarManager.FoundTraders[uuid] and RadarManager.FoundTraders[uuid].name) or uuid

        DynamicTrading.Log("DTV2", "Radio", "Cleanup", "Removing expired/inactive trader from radar: " .. uuid)
        if removal.isCallableForPlayer then
            RadarManager.FoundTraders[uuid] = nil
        elseif RadarManager.RemoveSignal then
            RadarManager.RemoveSignal(uuid, "Signal Lost: " .. tostring(traderName), "bad")
        else
            RadarManager.FoundTraders[uuid] = nil
        end
    end
end
