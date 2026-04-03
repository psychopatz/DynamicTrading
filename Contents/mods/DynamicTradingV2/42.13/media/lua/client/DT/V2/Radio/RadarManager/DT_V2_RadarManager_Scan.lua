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
    if not player or not device then
        return
    end

    local deviceName, range = RadarManager.GetDeviceInfo(device)

    DynamicTrading.Log("DTV2", "Radio", "Scan", "Starting scan with " .. tostring(deviceName) .. " (Range: " .. tostring(range) .. ")")

    if DT_V2_RadarLocationHandler then
        DT_V2_RadarLocationHandler.PrintDebug(player)
    end

    local rosterData = RadarManager.GetRosterData()
    if not rosterData or not rosterData.Souls then
        if isClient() then
            RadarManager.RequestRoster()
            player:Say(DT_RadioScanResponse("RadarSyncing"))
        else
            player:Say(DT_RadioScanResponse("RadarNoFrequencies"))
        end
        return
    end

    local foundNew = false
    local discoveredCount = 0
    local firstDiscoveredName = nil
    local px, py = player:getX(), player:getY()
    local currentHours = getGameTime():getWorldAgeHours()

    local globalRangeMult = 1.0
    local globalChanceMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
        globalRangeMult = DynamicTrading.Events.GetFactionSystemModifier(nil, "signalRange")
        globalChanceMult = DynamicTrading.Events.GetFactionSystemModifier(nil, "scanChance")
    end

    local effectiveRange = range * globalRangeMult

    for uuid, soul in pairs(rosterData.Souls) do
        local isExpiredTrading = soul.returnTime and soul.returnTime <= currentHours
        if soul.status == "Trading" and not isExpiredTrading then
            local tx, ty = soul.lastX, soul.lastY
            if tx and ty then
                local dx = tx - px
                local dy = ty - py
                local dist = math.sqrt(dx * dx + dy * dy)

                if dist <= effectiveRange then
                    local factionChanceMult = 1.0
                    if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
                        local faction = RadarManager.GetFaction(soul.factionID)
                        factionChanceMult = DynamicTrading.Events.GetFactionSystemModifier(faction, "scanChance")
                    end

                    local elecLevel = player:getPerkLevel(Perks.Electricity)
                    local chance = (20 + (elecLevel * 5)) * globalChanceMult * factionChanceMult

                    if ZombRand(100) < chance and not RadarManager.FoundTraders[uuid] then
                        local traderName = soul.name or DT_RadioScanResponse("UnknownTrader")
                        RadarManager.FoundTraders[uuid] = {
                            name = traderName,
                            faction = soul.factionID or "Independent",
                            discoveredAt = getGameTime():getWorldAgeHours()
                        }
                        foundNew = true
                        discoveredCount = discoveredCount + 1
                        firstDiscoveredName = firstDiscoveredName or traderName
                        DynamicTrading.Log("DTV2", "Radio", "Scan", "Discovered trader: " .. tostring(soul.name) .. " (UUID: " .. uuid .. ")")
                        RadarManager.CacheMetadata(uuid, {
                            name = soul.name,
                            factionID = soul.factionID,
                            archetypeID = soul.archetypeID,
                            isFemale = soul.isFemale,
                            identitySeed = soul.identitySeed,
                            status = soul.status,
                            state = soul.state,
                            returnTime = soul.returnTime,
                            lastX = tx,
                            lastY = ty,
                            lastZ = soul.lastZ or 0
                        })
                    end
                end
            end
        end
    end

    RadarManager.Cleanup()

    if foundNew then
        if discoveredCount == 1 and firstDiscoveredName then
            player:Say(DT_RadioScanResponse("Connected", firstDiscoveredName))
        else
            player:Say(DT_RadioScanResponse("RadarLockAcquired"))
        end

        if HaloTextHelper then
            local haloText = DT_RadioScanResponse("RadarLockAcquired")
            if discoveredCount == 1 and firstDiscoveredName then
                haloText = DT_RadioScanResponse("SignalAcquired", firstDiscoveredName)
            end
            HaloTextHelper.addTextWithArrow(player, haloText, true, HaloTextHelper.getColorGreen())
        end

        if DT_V2_RadarWindow then
            if DT_V2_RadarWindow.instance and DT_V2_RadarWindow.instance:getIsVisible() then
                DT_V2_RadarWindow.instance:refresh()
            else
                DT_V2_RadarWindow.ToggleWindow(device)
            end
        end
    else
        local textSay = getRandomRadioScanText("FailLines")
        local textHalo = getRandomRadioScanText("FailStates")

        player:Say(textSay ~= "" and textSay or DT_RadioScanResponse("RadarNothingButStatic"))

        if HaloTextHelper then
            HaloTextHelper.addTextWithArrow(
                player,
                textHalo ~= "" and textHalo or DT_RadioScanResponse("RadarNothingButStatic"),
                true,
                HaloTextHelper.getColorRed()
            )
        end
    end
end
