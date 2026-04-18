-- ==============================================================================
-- DTNPC_ManagerRespawn_TradeCycles.lua
-- Trade mission management and processing logic.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic_TradeScheduler"

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

function DTNPCManager.ProcessTradeCycles()
    if not DynamicTrading_Roster then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end
    
    local currentHours = getGameTime():getWorldAgeHours()

    DynamicTrading_TradeScheduler.NormalizeRosterState(rosterData, currentHours)

    local plans = DynamicTrading_TradeScheduler.BuildAllFactionPlans(rosterData, currentHours)
    for factionID, plan in pairs(plans) do
        local dispatchable = DynamicTrading_TradeScheduler.GetDispatchCandidates(factionID, rosterData, currentHours, plan.faction)
        for _, uuid in ipairs(dispatchable) do
            DTNPCManager.StartTradeMission(uuid)
        end
    end
end

function DTNPCManager.StartTradeMission(uuid, forceImmediate, allowOutOfSchedule)
    local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if not soul then 
        DynamicTrading.Log("DTV2", "NPC", "Logic", "ERROR: StartTradeMission failed - Soul not found for " .. tostring(uuid))
        return 
    end

    if forceImmediate ~= true and allowOutOfSchedule ~= true then
        local factionID = soul.factionID or "Independent"
        local currentHours = getGameTime():getWorldAgeHours()
        local allowed, plan = DynamicTrading_TradeScheduler.IsSoulScheduledToDispatch(uuid, factionID, nil, currentHours)
        if not allowed then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Logic",
                "Skipped out-of-schedule trade start for " .. tostring(soul.name or uuid)
                    .. " faction=" .. tostring(factionID)
                    .. " windowActive=" .. tostring(plan and plan.isWindowActive or false)
            )
            return
        end
    end
    
    local currentHours = getGameTime():getWorldAgeHours()
    local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 2
    
    if forceImmediate then 
        walkHours = 0.02 -- Force Trade still simulates travel (approx 1.2 mins) but at a priority speed
    end

    if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayEvents and DynamicTrading.GameplayLogs.AddFactionEvent then
        local factionID = soul.factionID and tostring(soul.factionID) or nil
        local traderName = tostring(soul.name or uuid)
        if factionID and factionID ~= "" then
            DynamicTrading.Log("DTLogs", "Gameplay", "Lifecycle", "Trade lifecycle hook fired | UUID: " .. tostring(uuid) .. " | Trader: " .. traderName .. " | Faction: " .. factionID .. " | Context: " .. (isServer() and "Server" or (isClient() and "Client" or "SinglePlayer")))
            DynamicTrading.GameplayLogs.AddFactionEvent(factionID, DynamicTrading.GameplayEvents.TRADE_STARTED, {traderName})
        else
            DynamicTrading.Log("DTLogs", "Gameplay", "Lifecycle", "Trade lifecycle hook skipped - missing factionID for UUID: " .. tostring(uuid) .. " | Trader: " .. traderName)
        end
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Logic", "STARTING TRADE MISSION for: " .. (soul.name or uuid) .. " at " .. currentHours)
    DynamicTrading.Log("DTV2", "NPC", "Logic", "| Travel Time: " .. walkHours .. "h. Status: Away. Target: Trading")

    local targetX = nil
    local targetY = nil
    local targetZ = nil
    if DTNPCManager.PlanTradingDestination then
        targetX, targetY, targetZ = DTNPCManager.PlanTradingDestination(uuid, soul)
    end

    if targetX and targetY and DTNPCManager.TryStartLiveDeparture
        and DTNPCManager.TryStartLiveDeparture(uuid, "Trading", walkHours, targetX, targetY, targetZ or 0) then
        return
    end
    
    -- Centralized transition
    DTNPCManager.SetNPCStatus(uuid, "Away", currentHours + walkHours, "Trading")
end

DynamicTrading.Log("DTV2", "Init", "NPC", "Loaded successfully")
