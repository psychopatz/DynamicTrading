-- ==============================================================================
-- DT_V2_RadarManager_Scan.lua
-- Trader discovery and scan logic for the radar manager.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

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
            player:Say("Syncing radar frequencies... try again.")
        else
            player:Say("Static... no frequencies found.")
        end
        return
    end

    local foundNew = false
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
                        RadarManager.FoundTraders[uuid] = {
                            name = soul.name or "Unknown Trader",
                            faction = soul.factionID or "Independent",
                            discoveredAt = getGameTime():getWorldAgeHours()
                        }
                        foundNew = true
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
        player:Say("Found something! Frequency locked.")

        if DT_V2_RadarWindow then
            if DT_V2_RadarWindow.instance and DT_V2_RadarWindow.instance:getIsVisible() then
                DT_V2_RadarWindow.instance:refresh()
            else
                DT_V2_RadarWindow.ToggleWindow(device)
            end
        end
    else
        player:Say("Nothing but static...")
    end
end
