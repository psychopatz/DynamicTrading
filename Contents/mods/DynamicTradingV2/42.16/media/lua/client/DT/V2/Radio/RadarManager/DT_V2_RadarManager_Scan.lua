-- ==============================================================================
-- DT_V2_RadarManager_Scan.lua
-- Trader discovery and scan logic for the radar manager.
-- ==============================================================================

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_RadioScan"
require "DT/Common/UI/RadioScanner/DT_RadioScannerWindow"

local RadarManager = DT_V2_RadarManager

local function DT_RadioScanResponse(key, ...)
    return DynamicTrading.FlavorText.GetValue("RadioScan", "Responses", key, ...)
end

local function getRandomRadioScanText(kind)
    return DynamicTrading.FlavorText.GetRandom("RadioScan", kind)
end

function RadarManager.Scan(player, device)
    if not player or not device then return end

    local canScan, remainingMinutes, scanStatus = true, 0, nil
    if RadarManager.CanScan then
        canScan, remainingMinutes, scanStatus = RadarManager.CanScan(player, device)
    end

    if canScan ~= true then
        local waitMinutes = math.max(1, math.ceil(remainingMinutes or 0))
        player:Say("The receiver is still cooling down. " .. tostring(waitMinutes) .. "m remaining.")

        if DT_RadioScannerWindow and DT_RadioScannerWindow.instance and DT_RadioScannerWindow.instance.signalDisplayPanel then
            DT_RadioScannerWindow.instance.signalDisplayPanel:pulseStatic(350)
            DT_RadioScannerWindow.instance:refresh()
        end
        return false
    end

    -- Ensure syncing starts on client
    if isClient() and DTNPCClient and DTNPCClient.SendNearbySyncRequest then
        DTNPCClient.SendNearbySyncRequest(player, "radar-scan")
    end

    -- Always ensure the radar window is open or at least stays open
    if DT_RadioScannerWindow then
        local inst = DT_RadioScannerWindow.instance
        if not (inst and inst:getIsVisible()) then
            DT_RadioScannerWindow.ToggleWindow(device)
        end

        inst = DT_RadioScannerWindow.instance
        if inst and inst.signalDisplayPanel then
            inst.signalDisplayPanel:pulseStatic(300)
            inst.signalDisplayPanel:setSignalState("search")
        end
    end

    local profile = RadarManager.GetDeviceProfile and RadarManager.GetDeviceProfile(device) or nil
    local deviceName = profile and profile.name or select(1, RadarManager.GetDeviceInfo(device))
    local range = profile and profile.range or select(2, RadarManager.GetDeviceInfo(device))
    local capacity = scanStatus and scanStatus.capacity or (profile and profile.capacity) or 1
    local currentCount = scanStatus and scanStatus.foundCount or RadarManager.GetCount()
    local unlockedCount = scanStatus and scanStatus.unlockedCount or math.max(0, currentCount - (RadarManager.GetLockedCount and RadarManager.GetLockedCount() or 0))
    local scanLimit = math.max(0, (capacity - currentCount) + unlockedCount)
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
    local username = player.getUsername and player:getUsername() or "Unknown"
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

    if scanLimit <= 0 then
        player:Say("All signal channels are occupied. Unlock or clear a signal before rescanning.")
        if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddRadioLog then
            DynamicTrading.NetworkLogs.AddRadioLog("Signal Memory Full: all locked channels occupied", "bad")
        end
        if DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
            DT_RadioScannerWindow.instance:refresh()
        end
        return false
    end

    -- Scan Loop
    for uuid, soul in pairs(rosterData.Souls) do
        if discoveredCount >= scanLimit then
            break
        end

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
                local powerBonus = profile and tonumber(profile.power) or 1.0
                local chance = (20 + (elecLevel * 5)) * globalChanceMult * factionChanceMult * powerBonus

                if ZombRand(100) < chance and not RadarManager.FoundTraders[uuid] then
                    while RadarManager.GetCount() >= capacity do
                        local recycleName = "Unknown"
                        local recycleCandidate = RadarManager.GetOldestUnlockedSignal and RadarManager.GetOldestUnlockedSignal() or nil
                        if recycleCandidate and recycleCandidate.entry and recycleCandidate.entry.name then
                            recycleName = recycleCandidate.entry.name
                        end
                        local releasedUUID, releasedEntry = RadarManager.ReleaseOldestUnlockedSignal(
                            "Signal Released: " .. tostring(recycleName) .. " (channel reallocated)",
                            "event"
                        )
                        if not releasedUUID then
                            break
                        end
                    end

                    if RadarManager.GetCount() >= capacity then
                        break
                    end

                    local name = soul.name or DT_RadioScanResponse("UnknownTrader")
                    local factionName = soul.factionID or "Independent"
                    local faction = RadarManager.GetFaction and RadarManager.GetFaction(soul.factionID) or nil
                    if faction and faction.name then
                        factionName = faction.name
                    end

                    RadarManager.FoundTraders[uuid] = {
                        name = name,
                        faction = soul.factionID or "Independent",
                        discoveredAt = currentHours,
                        locked = false,
                    }
                    foundNew = true
                    discoveredCount = discoveredCount + 1
                    firstName = firstName or name
                    RadarManager.CacheMetadata(uuid, soul)
                    if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddRadioLog then
                        DynamicTrading.NetworkLogs.AddRadioLog(
                            "Signal Acquired by " .. tostring(username) .. ": " .. tostring(name) .. " (" .. tostring(factionName) .. ")",
                            "good"
                        )
                    end
                    DynamicTrading.Log("DTV2", "Radio", "Scan", "Discovered: " .. name .. " (" .. uuid .. ")")
                end
            end
        end
    end

    RadarManager.Cleanup()

    -- Final Refresh
    if DT_RadioScannerWindow and DT_RadioScannerWindow.instance and DT_RadioScannerWindow.instance:getIsVisible() then
        DT_RadioScannerWindow.instance:refresh()
    end

    -- Feedback
    if foundNew then
        if RadarManager.SetScanTimestamp then
            RadarManager.SetScanTimestamp(player, device)
        end
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

    return foundNew
end
