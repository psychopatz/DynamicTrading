-- ==============================================================================
-- DT_V2_RadarManager_Scan.lua
-- Trader discovery and scan logic for the radar manager.
-- ==============================================================================

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_RadioScan"

local RadarManager = DT_V2_RadarManager

local function DT_RadioScanResponse(key, ...)
    return DynamicTrading.FlavorText.GetValue("RadioScan", "Responses", key, ...)
end

local function getRandomRadioScanText(kind)
    return DynamicTrading.FlavorText.GetRandom("RadioScan", kind)
end

function RadarManager.Scan(player, device)
    if not player or not device then return end

    -- Ensure syncing starts on client
    if isClient() and DTNPCClient and DTNPCClient.SendNearbySyncRequest then
        DTNPCClient.SendNearbySyncRequest(player, "radar-scan")
    end

    -- Always ensure the radar window is open or at least stays open
    if DT_V2_RadarWindow then
        local inst = DT_V2_RadarWindow.instance
        if not (inst and inst:getIsVisible()) then
            DT_V2_RadarWindow.ToggleWindow(device)
        end
    end

    local deviceName, range = RadarManager.GetDeviceInfo(device)
    DynamicTrading.Log("DTV2", "Radio", "Scan", "Starting scan with " .. tostring(deviceName) .. " (Range: " .. tostring(range) .. ")")

    local rosterData = RadarManager.GetRosterData()
    if not rosterData or not rosterData.Souls then
        player:Say(isClient() and DT_RadioScanResponse("RadarSyncing") or DT_RadioScanResponse("RadarNoFrequencies"))
        if isClient() then RadarManager.RequestRoster() end
        return
    end

    local foundNew = false
    local discoveredCount = 0
    local firstName = nil
    local px, py = player:getX(), player:getY()
    local currentHours = getGameTime():getWorldAgeHours()

    -- Global modifiers
    local globalRangeMult = 1.0
    local globalChanceMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
        globalRangeMult = DynamicTrading.Events.GetFactionSystemModifier(nil, "signalRange")
        globalChanceMult = DynamicTrading.Events.GetFactionSystemModifier(nil, "scanChance")
    end

    local effectiveRange = range * globalRangeMult

    -- Scan Loop
    for uuid, soul in pairs(rosterData.Souls) do
        local isExpired = soul.returnTime and soul.returnTime <= currentHours
        if soul.status == "Trading" and not isExpired and soul.lastX and soul.lastY then
            local dist = IsoUtils.DistanceTo(px, py, soul.lastX, soul.lastY)
            if dist <= effectiveRange then
                local factionChanceMult = 1.0
                if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
                    local faction = RadarManager.GetFaction(soul.factionID)
                    factionChanceMult = DynamicTrading.Events.GetFactionSystemModifier(faction, "scanChance")
                end

                local elecLevel = player:getPerkLevel(Perks.Electricity)
                local chance = (20 + (elecLevel * 5)) * globalChanceMult * factionChanceMult

                if ZombRand(100) < chance and not RadarManager.FoundTraders[uuid] then
                    local name = soul.name or DT_RadioScanResponse("UnknownTrader")
                    RadarManager.FoundTraders[uuid] = {
                        name = name,
                        faction = soul.factionID or "Independent",
                        discoveredAt = currentHours
                    }
                    foundNew = true
                    discoveredCount = discoveredCount + 1
                    firstName = firstName or name
                    RadarManager.CacheMetadata(uuid, soul)
                    DynamicTrading.Log("DTV2", "Radio", "Scan", "Discovered: " .. name .. " (" .. uuid .. ")")
                end
            end
        end
    end

    RadarManager.Cleanup()

    -- Final Refresh
    if DT_V2_RadarWindow and DT_V2_RadarWindow.instance and DT_V2_RadarWindow.instance:getIsVisible() then
        DT_V2_RadarWindow.instance:refresh()
    end

    -- Feedback
    if foundNew then
        local isOne = (discoveredCount == 1 and firstName)
        local sayTxt = isOne and DT_RadioScanResponse("Connected", firstName) or DT_RadioScanResponse("RadarLockAcquired")
        player:Say(sayTxt)
        if HaloTextHelper then
            local haloTxt = isOne and DT_RadioScanResponse("SignalAcquired", firstName) or DT_RadioScanResponse("RadarLockAcquired")
            HaloTextHelper.addTextWithArrow(player, haloTxt, true, HaloTextHelper.getColorGreen())
        end
    else
        local failSay = getRandomRadioScanText("FailLines")
        local failHalo = getRandomRadioScanText("FailStates")
        local staticMsg = DT_RadioScanResponse("RadarNothingButStatic")
        
        player:Say(failSay ~= "" and failSay or staticMsg)
        if HaloTextHelper then
            HaloTextHelper.addTextWithArrow(player, failHalo ~= "" and failHalo or staticMsg, true, HaloTextHelper.getColorRed())
        end
    end
end
