-- ==============================================================================
-- DT_V2_RadarManager_Cleanup.lua
-- Cleanup routines for inactive or expired radar entries.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

function RadarManager.Cleanup()
    local rosterData = RadarManager.GetRosterData()
    if not rosterData or not rosterData.Souls then
        return
    end

    local currentHours = getGameTime():getWorldAgeHours()
    local toRemove = {}

    for uuid, _ in pairs(RadarManager.FoundTraders) do
        local soul = rosterData.Souls[uuid]
        local isExpiredTrading = soul and soul.status == "Trading" and soul.returnTime and soul.returnTime <= currentHours
        local isDeparting = soul and soul.state == "Departure"
        if not soul or soul.status ~= "Trading" or isExpiredTrading or isDeparting then
            table.insert(toRemove, uuid)
        end
    end

    for _, uuid in ipairs(toRemove) do
        local soul = rosterData.Souls[uuid]
        local traderName = (soul and soul.name) or (RadarManager.FoundTraders[uuid] and RadarManager.FoundTraders[uuid].name) or uuid

        DynamicTrading.Log("DTV2", "Radio", "Cleanup", "Removing expired/inactive trader from radar: " .. uuid)
        if RadarManager.RemoveSignal then
            RadarManager.RemoveSignal(uuid, "Signal Lost: " .. tostring(traderName), "bad")
        else
            RadarManager.FoundTraders[uuid] = nil
        end
    end
end
