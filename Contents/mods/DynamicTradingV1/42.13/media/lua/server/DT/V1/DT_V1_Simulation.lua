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
        factionTotalCounts[factionID] = (factionTotalCounts[factionID] or 0) + 1
        if registry.status == "Away" or registry.status == "Trading" then
            factionTradingCounts[factionID] = (factionTradingCounts[factionID] or 0) + 1
        end
    end

    for uuid, registry in pairs(rosterData.Souls) do
        if registry.status == "Resting" then
            local factionID = registry.factionID or "Independent"
            local currentTrading = factionTradingCounts[factionID] or 0
            local totalMembers = factionTotalCounts[factionID] or 1
            
            local currentPercent = (currentTrading / totalMembers) * 100
            if currentPercent < popLimitPercent then
                -- Approx 10% chance per hour to start a mission
                if ZombRand(100) < 10 then
                    local walkHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours) or 2.0
                    DynamicTrading.Log("DTV1", "Sim", "Mission", (registry.name or uuid) .. " starting trade mission.")
                    DynamicTrading_Roster.UpdateSoulStatus(uuid, "Away", currentHours + walkHours, "Trading")
                    factionTradingCounts[factionID] = currentTrading + 1
                end
            end
        end
    end
end

-- Hook into hourly tick for efficiency
Events.EveryHours.Add(ProcessSimulation)

DynamicTrading.Log("DTV1", "Sim", "Init", "V1 Simulation Module Loaded (Parity Mode).")
