-- ==============================================================================
-- DT_V2_RadarManager_Scan.lua
-- Trader discovery and scan logic for the radar manager.
-- ==============================================================================

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_RadioScan"
require "DT/Common/UI/RadioScanner/DT_RadioScannerWindow"

local RadarManager = DT_V2_RadarManager

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function DT_RadioScanResponse(key, ...)
    return DynamicTrading.FlavorText.GetValue("RadioScan", "Responses", key, ...)
end

local function getRandomRadioScanText(kind)
    return DynamicTrading.FlavorText.GetRandom("RadioScan", kind)
end

local function getLocalIdentity(player)
    local username = player and player.getUsername and player:getUsername() or nil
    local onlineID = player and player.getOnlineID and player:getOnlineID() or nil
    return username, onlineID
end

local function isPriorityContactVisitForPlayer(soul, player)
    if not soul or soul.contactVisitActive ~= true then
        return false
    end

    local username, onlineID = getLocalIdentity(player)
    if onlineID ~= nil and soul.contactVisitRequestedByID ~= nil and tonumber(soul.contactVisitRequestedByID) == tonumber(onlineID) then
        return true
    end

    if username and tostring(soul.contactVisitRequestedBy or "") == tostring(username) then
        return true
    end

    return false
end

local function chooseRandomEntry(list)
    if not list or #list == 0 then
        return nil
    end
    return list[ZombRand(#list) + 1]
end

local function clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

local function getElectricityScanFloorChance(level)
    local maxLevel = 10
    local normalizedLevel = clamp(level, 0, maxLevel)
    return (normalizedLevel / maxLevel) * 100
end

local function getRadarScanElectricityXP()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    return math.max(0, tonumber(sandbox and sandbox.RadarScanElectricityXP) or 0.05)
end

local function awardElectricityXP(player, amount)
    local xp = tonumber(amount) or 0
    if not player or xp <= 0 then
        return
    end

    local xpSystem = player.getXp and player:getXp() or nil
    if xpSystem and xpSystem.AddXP then
        xpSystem:AddXP(Perks.Electricity, xp)
    end
end

local function getGlobalScanModifiers()
    local globalRangeMult = 1.0
    local globalChanceMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
        globalRangeMult = DynamicTrading.Events.GetFactionSystemModifier(nil, "signalRange")
        globalChanceMult = DynamicTrading.Events.GetFactionSystemModifier(nil, "scanChance")
    end
    return globalRangeMult, globalChanceMult
end

local function collectEligibleSignals(rosterData, px, py, currentHours, effectiveRange, player)
    local eligibleSignals = {}
    local prioritySignals = {}

    if not rosterData or not rosterData.Souls then
        return eligibleSignals, prioritySignals
    end

    for uuid, soul in pairs(rosterData.Souls) do
        local isExpired = soul.returnTime and soul.returnTime <= currentHours
        local isActiveTrading = soul.status == "Trading" and not isExpired and soul.state ~= "Departure"
        local isDiscoverable = RadarManager.IsRadioDiscoverableSoul == nil or RadarManager.IsRadioDiscoverableSoul(soul)
        if isActiveTrading and isDiscoverable and soul.lastX and soul.lastY and not RadarManager.FoundTraders[uuid] then
            local dist = IsoUtils.DistanceTo(px, py, soul.lastX, soul.lastY)
            if dist <= effectiveRange then
                local entry = {
                    uuid = uuid,
                    soul = soul,
                    dist = dist,
                }
                eligibleSignals[#eligibleSignals + 1] = entry
                if isPriorityContactVisitForPlayer(soul, player) then
                    prioritySignals[#prioritySignals + 1] = entry
                end
            end
        end
    end

    table.sort(prioritySignals, function(a, b)
        local startedA = tonumber(a.soul and a.soul.contactVisitStartedAt) or math.huge
        local startedB = tonumber(b.soul and b.soul.contactVisitStartedAt) or math.huge
        if startedA == startedB then
            return tostring(a.uuid) < tostring(b.uuid)
        end
        return startedA < startedB
    end)

    table.sort(eligibleSignals, function(a, b)
        local distA = tonumber(a.dist) or math.huge
        local distB = tonumber(b.dist) or math.huge
        if distA == distB then
            return tostring(a.uuid) < tostring(b.uuid)
        end
        return distA < distB
    end)

    return eligibleSignals, prioritySignals
end

local function buildScanPreview(player, device, scanStatus)
    if not player or not device then
        return nil
    end

    local rosterData = RadarManager.GetRosterData and RadarManager.GetRosterData() or nil
    local profile = RadarManager.GetDeviceProfile and RadarManager.GetDeviceProfile(device) or nil
    local deviceName = profile and profile.name or select(1, RadarManager.GetDeviceInfo(device))
    local range = profile and profile.range or select(2, RadarManager.GetDeviceInfo(device))
    local currentCount = scanStatus and scanStatus.foundCount or (RadarManager.GetCount and RadarManager.GetCount() or 0)
    local lockedCount = RadarManager.GetLockedCount and RadarManager.GetLockedCount() or 0
    local unlockedCount = scanStatus and scanStatus.unlockedCount or math.max(0, currentCount - lockedCount)
    local capacity = scanStatus and scanStatus.capacity or (profile and profile.capacity) or 1
    local scanLimit = math.max(0, (capacity - currentCount) + unlockedCount)
    local currentHours = getGameTime():getWorldAgeHours()
    local px, py = player:getX(), player:getY()
    local globalRangeMult, globalChanceMult = getGlobalScanModifiers()
    local effectiveRange = range * globalRangeMult
    local eligibleSignals, prioritySignals = collectEligibleSignals(rosterData, px, py, currentHours, effectiveRange, player)
    local targetEntry = prioritySignals[1] or eligibleSignals[1]
    local targetSoul = targetEntry and targetEntry.soul or nil
    local electricityLevel = player:getPerkLevel(Perks.Electricity)
    local baseChance = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.ScanBaseChance) or 30
    local powerBonus = profile and tonumber(profile.power) or 1.0
    local skillBonus = 1.0 + (electricityLevel * 0.05)
    local electricityFloorChance = getElectricityScanFloorChance(electricityLevel)
    local factionChanceMult = 1.0

    if targetSoul and DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
        local targetFaction = RadarManager.GetFaction and RadarManager.GetFaction(targetSoul.factionID) or nil
        factionChanceMult = DynamicTrading.Events.GetFactionSystemModifier(targetFaction, "scanChance")
    end

    local finalChance = clamp(math.max(baseChance * powerBonus * skillBonus * globalChanceMult * factionChanceMult, electricityFloorChance), 1, 100)

    return {
        deviceName = deviceName,
        range = range,
        effectiveRange = effectiveRange,
        baseChance = baseChance,
        powerBonus = powerBonus,
        skillBonus = skillBonus,
        electricityLevel = electricityLevel,
        electricityFloorChance = electricityFloorChance,
        globalChanceMult = globalChanceMult,
        factionChanceMult = factionChanceMult,
        finalChance = finalChance,
        candidateCount = #eligibleSignals,
        priorityCount = #prioritySignals,
        currentCount = currentCount,
        capacity = capacity,
        scanLimit = scanLimit,
        hasEligibleTarget = targetEntry ~= nil and scanLimit > 0,
        targetUUID = targetEntry and targetEntry.uuid or nil,
        targetDistance = targetEntry and targetEntry.dist or nil,
        targetName = targetSoul and targetSoul.name or nil,
        targetFaction = targetSoul and targetSoul.factionID or nil,
    }
end

function RadarManager.GetScanPreview(device, player)
    if not player or not device then
        return nil
    end

    local scanStatus = RadarManager.GetScanStatus and RadarManager.GetScanStatus(device, player) or nil
    return buildScanPreview(player, device, scanStatus)
end

function RadarManager.Scan(player, device)
    if not player or not device then return end

    if RadarManager.Cleanup then
        RadarManager.Cleanup(player)
    end

    if DynamicObjectives and DynamicObjectives.UI and DynamicObjectives.UI.RequestScannerQuestRefresh then
        DynamicObjectives.UI.RequestScannerQuestRefresh(player)
    end

    local currentHour = getGameTime():getTimeOfDay()
    local gateDisabled = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.DisableNightScanGate == true
    if not gateDisabled and (currentHour >= 22.0 or currentHour < 5.0) then
        player:Say(T("DTNPC_UI_RadarNothingButStatic", nil, "There is nothing but static. Broadcasters must be resting till morning."))
        if HaloTextHelper then
            HaloTextHelper.addTextWithArrow(player, "Traders Offline (10PM - 5AM)", true, HaloTextHelper.getColorRed())
        end
        
        if DT_RadioScannerWindow then
            local inst = DT_RadioScannerWindow.instance
            if not (inst and inst:getIsVisible()) then
                DT_RadioScannerWindow.ToggleWindow(device)
            end
            if DT_RadioScannerWindow.instance and DT_RadioScannerWindow.instance.signalDisplayPanel then
                DT_RadioScannerWindow.instance.signalDisplayPanel:pulseStatic(350)
                DT_RadioScannerWindow.instance:refresh()
            end
        end
        return false
    end

    local canScan, remainingMinutes, scanStatus = true, 0, nil
    if RadarManager.CanScan then
        canScan, remainingMinutes, scanStatus = RadarManager.CanScan(player, device)
    end

    if canScan ~= true then
        local waitMinutes = math.max(1, math.ceil(remainingMinutes or 0))
        player:Say(T("DTNPC_UI_ReceiverCoolingDown", { time = waitMinutes }, "The receiver is still cooling down. " .. tostring(waitMinutes) .. "m remaining."))

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
    local firstUUID = nil
    local firstPreviewData = nil
    local username = player.getUsername and player:getUsername() or "Unknown"
    local px, py = player:getX(), player:getY()
    local currentHours = getGameTime():getWorldAgeHours()

    local globalRangeMult, globalChanceMult = getGlobalScanModifiers()
    local effectiveRange = range * globalRangeMult

    if scanLimit <= 0 then
        player:Say(T("DTNPC_UI_SignalChannelsOccupied", nil, "All signal channels are occupied. Unlock or clear a signal before rescanning."))
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddPlayerRadioEvent then
            DynamicTrading.GameplayLogs.AddPlayerRadioEvent(player, DynamicTrading.GameplayEvents.SIGNAL_MEMORY_FULL, {})
        end
        if DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
            DT_RadioScannerWindow.instance:refresh()
        end
        return false
    end

    local eligibleSignals, prioritySignals = collectEligibleSignals(rosterData, px, py, currentHours, effectiveRange, player)

    if #eligibleSignals == 0 then
        local failSay = getRandomRadioScanText("FailLines")
        local failHalo = getRandomRadioScanText("FailStates")
        local staticMsg = DT_RadioScanResponse("RadarNothingButStatic")

        player:Say(failSay ~= "" and failSay or staticMsg)
        if HaloTextHelper then
            HaloTextHelper.addTextWithArrow(player, failHalo ~= "" and failHalo or staticMsg, true, HaloTextHelper.getColorRed())
        end

        if DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
            DT_RadioScannerWindow.instance:refresh()
        end
        return false
    end

    local targetEntry = prioritySignals[1] or chooseRandomEntry(eligibleSignals)
    local targetSoul = targetEntry and targetEntry.soul or nil
    local usedPriorityContact = prioritySignals[1] ~= nil and targetEntry == prioritySignals[1]
    local elecLevel = player:getPerkLevel(Perks.Electricity)
    local baseChance = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.ScanBaseChance) or 30
    local powerBonus = profile and tonumber(profile.power) or 1.0
    local skillBonus = 1.0 + (elecLevel * 0.05)
    local electricityFloorChance = getElectricityScanFloorChance(elecLevel)
    local factionChanceMult = 1.0

    if targetSoul and DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
        local targetFaction = RadarManager.GetFaction(targetSoul.factionID)
        factionChanceMult = DynamicTrading.Events.GetFactionSystemModifier(targetFaction, "scanChance")
    end

    local finalChance = baseChance * powerBonus * skillBonus * globalChanceMult * factionChanceMult
    finalChance = math.max(finalChance, electricityFloorChance)
    finalChance = clamp(finalChance, 1, 100)

    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Base Chance: " .. tostring(baseChance))
    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Power Bonus: " .. string.format("%.2f", powerBonus))
    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Skill Bonus: " .. string.format("%.2f", skillBonus))
    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Electricity Floor: " .. string.format("%.2f", electricityFloorChance) .. "%")
    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Capacity Ratio: " .. tostring(currentCount) .. "/" .. tostring(capacity))
    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Penalty Factor: removed (discovered trader count no longer reduces scan chance)")
    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Candidate Pool: " .. tostring(#eligibleSignals) .. " | Priority Pool: " .. tostring(#prioritySignals))
    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Final Chance: " .. string.format("%.2f", finalChance) .. "%")
    local scanRoll = ZombRand(100)
    DynamicTrading.Log("DTV2", "Radio", "Scan", "  - Roll: " .. tostring(scanRoll) .. " / 100")

    if targetEntry and scanRoll < finalChance then
        while RadarManager.GetCount() >= capacity do
            local recycleName = "Unknown"
            local recycleCandidate = RadarManager.GetOldestUnlockedSignal and RadarManager.GetOldestUnlockedSignal() or nil
            if recycleCandidate and recycleCandidate.entry and recycleCandidate.entry.name then
                recycleName = recycleCandidate.entry.name
            end

            local releasedUUID = RadarManager.ReleaseOldestUnlockedSignal(recycleName)
            if not releasedUUID then
                break
            end
        end

        if RadarManager.GetCount() < capacity then
            local uuid = targetEntry.uuid
            local soul = targetEntry.soul
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
            discoveredCount = 1
            firstName = name
            firstUUID = firstUUID or uuid
            firstPreviewData = firstPreviewData or {
                uuid = uuid,
                name = name,
                faction = soul.factionID or "Independent",
                factionName = factionName,
                archetype = soul.archetypeID or soul.archetype or soul.occupation or "General",
                gender = soul.isFemale == true and "Female" or "Male",
                identitySeed = tonumber(soul.identitySeed) or 1,
                x = soul.lastX,
                y = soul.lastY,
                z = soul.lastZ or 0,
                isLive = true,
            }
            RadarManager.CacheMetadata(uuid, soul)
            if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddPlayerRadioEvent then
                DynamicTrading.GameplayLogs.AddPlayerRadioEvent(player, DynamicTrading.GameplayEvents.SIGNAL_ACQUIRED, {tostring(username), tostring(name), tostring(factionName)})
            end
            awardElectricityXP(player, getRadarScanElectricityXP())
            DynamicTrading.Log("DTV2", "Radio", "Scan", "Discovered: " .. name .. " (" .. uuid .. ")")
        end
    else
        DynamicTrading.Log("DTV2", "Radio", "Scan", "Scan roll failed to lock a new signal")
    end

    RadarManager.Cleanup(player)

    -- Final Refresh
    if DT_RadioScannerWindow and DT_RadioScannerWindow.instance and DT_RadioScannerWindow.instance:getIsVisible() then
        DT_RadioScannerWindow.instance:refresh()
        if foundNew
            and firstUUID
            and DT_RadioScannerWindow.instance.showDiscoveryConversationForSignal
        then
            DT_RadioScannerWindow.instance:showDiscoveryConversationForSignal(firstUUID, firstPreviewData, true)
        end
    end

    -- Feedback
    if foundNew then
        if RadarManager.SetScanTimestamp and not usedPriorityContact then
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
