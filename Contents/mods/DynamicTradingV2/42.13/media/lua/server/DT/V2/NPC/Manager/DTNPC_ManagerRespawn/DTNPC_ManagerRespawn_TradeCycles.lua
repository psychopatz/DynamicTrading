-- ==============================================================================
-- DTNPC_ManagerRespawn_TradeCycles.lua
-- Trade mission management and processing logic.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

function DTNPCManager.ProcessTradeCycles()
    if not DynamicTrading_Roster then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end
    
    local popLimitPercent = SandboxVars.DynamicTrading.NPCTradePopPercent or 40
    local currentHours = getGameTime():getWorldAgeHours()
    
    -- Group souls by faction to check population limits
    local factionTradingCounts = {}
    local factionTotalCounts = {}
    
    -- First pass: Count trading/away and total population per faction
    for uuid, registry in pairs(rosterData.Souls) do
        local factionID = registry.factionID or "Independent"
        factionTotalCounts[factionID] = (factionTotalCounts[factionID] or 0) + 1
        
        if registry.status == "Away" or registry.status == "Trading" then
            factionTradingCounts[factionID] = (factionTradingCounts[factionID] or 0) + 1
        end
    end
    
    -- Second pass: Trigger missions based on limits
    for uuid, registry in pairs(rosterData.Souls) do
        if registry.status == "Resting" then
            local factionID = registry.factionID or "Independent"
            local currentTrading = factionTradingCounts[factionID] or 0
            local totalMembers = factionTotalCounts[factionID] or 1
            
            -- [UNIFIED] Apply Event Modifiers
            local limitMult = 1.0
            if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
                local faction = DynamicTrading_Factions.GetFaction(factionID)
                limitMult = DynamicTrading.Events.GetFactionSystemModifier(faction, "traderLimit")
            end
            
            local effectivePopLimit = popLimitPercent * limitMult
            local currentPercent = (currentTrading / totalMembers) * 100
            
            if currentPercent < effectivePopLimit then
                -- Small random chance to trigger (simulating daily chance spread over ticks)
                -- 1 in 2000 chance per check (~1 min real time if check is every 30s)
                if ZombRand(2000) < 10 then 
                    DTNPCManager.StartTradeMission(uuid)
                    -- Update count so we don't over-spawn in the same tick
                    factionTradingCounts[factionID] = currentTrading + 1
                end
            end
        end
    end
end

function DTNPCManager.StartTradeMission(uuid, forceImmediate)
    local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if not soul then 
        DynamicTrading.Log("DTV2", "NPC", "Logic", "ERROR: StartTradeMission failed - Soul not found for " .. tostring(uuid))
        return 
    end
    
    local currentHours = getGameTime():getWorldAgeHours()
    local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 2
    
    if forceImmediate then 
        walkHours = 0.02 -- Force Trade still simulates travel (approx 1.2 mins) but at a priority speed
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Logic", "STARTING TRADE MISSION for: " .. (soul.name or uuid) .. " at " .. currentHours)
    DynamicTrading.Log("DTV2", "NPC", "Logic", "| Travel Time: " .. walkHours .. "h. Status: Away. Target: Trading")
    
    -- Centralized transition
    DTNPCManager.SetNPCStatus(uuid, "Away", currentHours + walkHours, "Trading")
end

DynamicTrading.Log("DTV2", "Init", "NPC", "Loaded successfully")
