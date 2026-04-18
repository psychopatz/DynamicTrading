-- ==============================================================================
-- Simulation/Simulation_FlashEvents_logic.lua
-- Logic: Processes active flash events and calculates target casualties/attrition.
-- ==============================================================================

local FlashEventsLogic = {}

function FlashEventsLogic.Process(faction, id, data, currentHour)
    local factionActive = faction ~= nil
    if not factionActive then return nil, false end

    faction.ActiveFlashEvents = faction.ActiveFlashEvents or {}

    for _, afe in ipairs(faction.ActiveFlashEvents) do
        if factionActive and afe and afe.id then
            if afe.targetCasualties and afe.targetCasualties > 0 then
                local hoursLeft = (afe.expires or currentHour) - currentHour
                local daysLeft = math.ceil(hoursLeft / 24)
                if daysLeft < 1 then
                    daysLeft = 1
                end

                local killToday = math.ceil(afe.targetCasualties / daysLeft)
                if killToday > 1 and ZombRand(100) < 30 then
                    killToday = killToday - 1
                end
                if killToday > afe.targetCasualties then
                    killToday = afe.targetCasualties
                end

                if killToday > 0 then
                    if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
                        killToday = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, killToday, "Faction event casualties")
                        faction = data[id]
                        factionActive = faction ~= nil
                    else
                        faction.memberCount = math.max(0, faction.memberCount - killToday)
                        DynamicTrading_Roster.RemoveSoul(id, killToday)
                    end

                    if factionActive then
                        afe.targetCasualties = afe.targetCasualties - killToday
                        DynamicTrading.Log("DTCommons", "Faction", "Sim", "Event casualty hit for faction [" .. faction.name .. "] [" .. tostring(afe.id) .. "] | Killed: " .. killToday .. " | Remaining Targets: " .. tostring(afe.targetCasualties))
                        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                            local eventName = (DynamicTrading.Events and DynamicTrading.Events.Registry and DynamicTrading.Events.Registry[afe.id] and DynamicTrading.Events.Registry[afe.id].name) or afe.id
                            DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.FLASH_CASUALTIES, {killToday, tostring(eventName)})
                        end
                    end
                end
            end

            if factionActive then
                local def = DynamicTrading.Events and DynamicTrading.Events.Registry and DynamicTrading.Events.Registry[afe.id]
                if def and def.attrition then
                    local attr = def.attrition
                    local resource = attr.resource or "meds"
                    local affectedPct = attr.pct or attr.sickPct or 0
                    local costPerHead = attr.cost or attr.medsPerSick or 1.0

                    local affectedCount = math.floor(faction.memberCount * affectedPct)
                    if affectedCount > 0 then
                        local totalNeeded = affectedCount * costPerHead
                        local stockpile = (faction.stockpile[resource] or 0)

                        if stockpile >= totalNeeded then
                            faction.stockpile[resource] = stockpile - totalNeeded
                            DynamicTrading.Log("DTCommons", "Faction", "Sim", "Faction [" .. faction.name .. "] met " .. resource .. " requirements for " .. affectedCount .. " souls.")
                        else
                            local casualties = math.ceil(affectedCount * 0.2)
                            if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
                                casualties = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, casualties, "Faction attrition")
                                faction = data[id]
                                factionActive = faction ~= nil
                            else
                                faction.memberCount = math.max(0, faction.memberCount - casualties)
                                DynamicTrading_Roster.RemoveSoul(id, casualties)
                            end

                            if factionActive then
                                DynamicTrading.Log("DTCommons", "Faction", "Sim", "Faction [" .. faction.name .. "] " .. resource:upper() .. " SHORTAGE! Lost " .. casualties .. " souls.")
                                faction.state = "Starving"
                                if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                                    DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.SHORTAGE_CASUALTIES, {casualties, resource})
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if factionActive then
        local firstFlash = faction.ActiveFlashEvents[1]
        faction.ActiveFlashEvent = {
            id = firstFlash and firstFlash.id or nil,
            expires = firstFlash and (firstFlash.expires or 0) or 0,
            targetCasualties = firstFlash and (firstFlash.targetCasualties or 0) or 0
        }
    end

    return faction, factionActive
end

return FlashEventsLogic
