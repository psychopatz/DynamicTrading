-- ==============================================================================
-- DT_V1_Simulation.lua
-- Server-side simulation of trader availability for V1 (Version Parity).
-- Handles Resting -> Away -> Trading cycles for Roster Souls.
-- ==============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.V1Sim = {}

-- GUARD: Prevent Remote MP Clients from running this
if isClient() and not isServer() then return end

local function ProcessSimulation()
    -- GUARD: If V2 Manager is active, let it handle the souls to avoid double-processing
    if DTNPCManager and DTNPCManager.ProcessAwayTransitions then
        -- print("[DynamicTrading] V1 Simulation: V2 Manager detected, skipping V1-specific simulation.")
        return 
    end

    if not DynamicTrading_Roster then return end
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end

    local currentHours = getGameTime():getWorldAgeHours()
    local popLimitPercent = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradePopPercent) or 40
    local minTradeHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMin) or 6
    local maxTradeHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMax) or 24
    if minTradeHours > maxTradeHours then
        minTradeHours = maxTradeHours
    end

    -- 1. Process Transitions (Away -> Trading, Trading -> Away, Away -> Resting)
    for uuid, registry in pairs(rosterData.Souls) do
        if (registry.status == "Away" or registry.status == "Trading") and registry.returnTime then
            if currentHours >= registry.returnTime then
                local nextStatus = registry.returnStatus or "Resting"
                local newReturnTime = 0
                local newReturnStatus = nil

                if nextStatus == "Trading" then
                    -- V1 simplified: Just stay in Trading for X hours
                    local stayHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingStayHours) or 4.0
                    newReturnTime = currentHours + stayHours
                    newReturnStatus = "Away"
                elseif nextStatus == "Away" then
                    -- Transition back to Resting
                    local walkHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours) or 1.0
                    newReturnTime = currentHours + walkHours
                    newReturnStatus = "Resting"
                end

                DynamicTrading.Log("DTV1", "Sim", "Transition", (registry.name or uuid) .. " transitioning to " .. nextStatus)
                DynamicTrading_Roster.UpdateSoulStatus(uuid, nextStatus, newReturnTime, newReturnStatus)
            end
        end
    end

    -- 2. Process New Trade Missions (Resting -> Away)
    local factionTradingCounts = {}
    local factionTotalCounts = {}

    for uuid, registry in pairs(rosterData.Souls) do
        local factionID = registry.factionID or "Independent"
        local faction = DynamicTrading_Factions and DynamicTrading_Factions.GetFaction and DynamicTrading_Factions.GetFaction(factionID) or nil
        local includeSoul = true

        if faction and faction.playerOwned and faction.leadershipState ~= "Regency" then
            includeSoul = false
        end

        if includeSoul and faction and faction.playerOwned then
            local workerID = registry.linkedWorkerID
            if not workerID or not faction.tradeEligibleWorkerIDs or faction.tradeEligibleWorkerIDs[workerID] ~= true then
                includeSoul = false
            end
        end

        if includeSoul then
            factionTotalCounts[factionID] = (factionTotalCounts[factionID] or 0) + 1
            if registry.status == "Away" or registry.status == "Trading" then
                factionTradingCounts[factionID] = (factionTradingCounts[factionID] or 0) + 1
            end
        end
    end

    for uuid, registry in pairs(rosterData.Souls) do
        if registry.status == "Resting" then
            local factionID = registry.factionID or "Independent"
            local faction = DynamicTrading_Factions and DynamicTrading_Factions.GetFaction and DynamicTrading_Factions.GetFaction(factionID) or nil
            local canDispatch = true

            if faction and faction.playerOwned then
                if faction.leadershipState ~= "Regency" then
                    canDispatch = false
                end

                if canDispatch then
                    local workerID = registry.linkedWorkerID
                    if not workerID or not faction.tradeEligibleWorkerIDs or faction.tradeEligibleWorkerIDs[workerID] ~= true then
                        canDispatch = false
                    end
                end
            end

            if canDispatch then
                local currentTrading = factionTradingCounts[factionID] or 0
                local totalMembers = factionTotalCounts[factionID] or 1

                local currentPercent = (currentTrading / totalMembers) * 100
                if currentPercent < popLimitPercent then
                    if ZombRand(100) < 10 then
                        if faction and faction.playerOwned then
                            local duration = ZombRand(minTradeHours, maxTradeHours + 1)
                            DynamicTrading.Log("DTV1", "Sim", "Mission", (registry.name or uuid) .. " entering regency trade rotation.")
                            DynamicTrading_Roster.UpdateSoulStatus(uuid, "Trading", currentHours + duration, "Away")
                        else
                            local walkHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours) or 2.0
                            DynamicTrading.Log("DTV1", "Sim", "Mission", (registry.name or uuid) .. " starting trade mission.")
                            DynamicTrading_Roster.UpdateSoulStatus(uuid, "Away", currentHours + walkHours, "Trading")
                        end
                        factionTradingCounts[factionID] = currentTrading + 1
                    end
                end
            end
        end
    end
end

-- Hook into hourly tick for efficiency
Events.EveryHours.Add(ProcessSimulation)

DynamicTrading.Log("DTV1", "Sim", "Init", "V1 Simulation Module Loaded (Parity Mode).")
