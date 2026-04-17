-- ==============================================================================
-- DT_V1_Simulation.lua
-- Server-side simulation of trader availability for V1 (Version Parity).
-- Handles Resting -> Away -> Trading cycles for Roster Souls.
-- ==============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.V1Sim = {}

require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic_TradeScheduler"

-- GUARD: Prevent Remote MP Clients from running this
if isClient() and not isServer() then return end

local function findRequester(username, onlineID)
    if onlineID ~= nil and getPlayerByOnlineID then
        local byID = getPlayerByOnlineID(onlineID)
        if byID then
            return byID
        end
    end

    local target = tostring(username or "")
    if target == "" then
        return nil
    end

    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getUsername and tostring(player:getUsername() or "") == target then
                return player
            end
        end
    end

    return nil
end

local function notifyContactArrival(uuid, registry)
    if tostring(registry.contactVisitBackend or "") ~= "V1" then
        return
    end

    local requester = findRequester(registry.contactVisitRequestedBy, registry.contactVisitRequestedByID)
    if not requester then
        DynamicTrading.Log(
            "DTV1",
            "Sim",
            "Warn",
            "Contact arrival requester missing for " .. tostring(registry.name or uuid)
                .. " requester=" .. tostring(registry.contactVisitRequestedBy)
        )
        return
    end

    DynamicTrading.Log(
        "DTV1",
        "Sim",
        "Contact",
        "Notifying contact arrival for " .. tostring(registry.name or uuid)
            .. " requester=" .. tostring(requester.getUsername and requester:getUsername() or "unknown")
    )

    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.SendResponse then
        DynamicTrading.ServerHelpers.SendResponse(requester, "DynamicTrading", "ScanResult", {
            status = "SUCCESS",
            targetUser = requester.getUsername and requester:getUsername() or nil,
            id = uuid,
            name = registry.name or "Unknown Trader",
            source = "ContactVisitV1",
            traderStatus = registry.status,
            traderState = registry.state,
            returnTime = registry.returnTime,
            returnStatus = registry.returnStatus,
            contactVisitActive = registry.contactVisitActive,
            contactVisitMode = registry.contactVisitMode,
            contactVisitBackend = registry.contactVisitBackend,
        })
    end
end

local function clearContactVisitState(uuid)
    local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid) or nil
    if not soul then
        return
    end

    soul.contactVisitActive = false
    soul.contactVisitMode = nil
    soul.contactVisitBackend = nil
    soul.contactVisitRequestedBy = nil
    soul.contactVisitRequestedByID = nil
    soul.contactVisitTargetX = nil
    soul.contactVisitTargetY = nil
    soul.contactVisitTargetZ = nil
    soul.contactVisitStartedAt = nil
    soul.contactVisitReturnStatus = nil
    DynamicTrading_Roster.SaveSoul(uuid, soul)
end

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
    local minTradeHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMin) or 6
    local maxTradeHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderStayHoursMax) or 24
    if minTradeHours > maxTradeHours then
        minTradeHours = maxTradeHours
    end

    DynamicTrading_TradeScheduler.NormalizeRosterState(rosterData, currentHours)

    -- 1. Process Transitions (Away -> Trading, Trading -> Away, Away -> Resting)
    for uuid, registry in pairs(rosterData.Souls) do
        if (registry.status == "Away" or registry.status == "Trading") and registry.returnTime then
            if currentHours >= registry.returnTime then
                local nextStatus = registry.returnStatus or "Resting"
                local newReturnTime = 0
                local newReturnStatus = nil
                local shouldNotifyArrival = false

                if nextStatus == "Trading" then
                    -- V1 simplified: Just stay in Trading for X hours
                    local stayHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingStayHours) or 4.0
                    newReturnTime = currentHours + stayHours
                    newReturnStatus = "Away"
                    if registry.contactVisitActive == true and tostring(registry.contactVisitBackend or "") == "V1" then
                        registry.contactVisitMode = "Trading"
                        shouldNotifyArrival = true
                    end
                elseif nextStatus == "Away" then
                    -- Transition back to Resting
                    local walkHours = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours) or 1.0
                    newReturnTime = currentHours + walkHours
                    newReturnStatus = "Resting"
                    if registry.contactVisitActive == true and tostring(registry.contactVisitBackend or "") == "V1" then
                        registry.contactVisitMode = "Departure"
                    end
                end

                DynamicTrading.Log("DTV1", "Sim", "Transition", (registry.name or uuid) .. " transitioning to " .. nextStatus)
                DynamicTrading_Roster.UpdateSoulStatus(uuid, nextStatus, newReturnTime, newReturnStatus)
                local updatedRegistry = DynamicTrading_Roster.GetSoulRegistry and DynamicTrading_Roster.GetSoulRegistry(uuid) or registry
                if updatedRegistry and registry.contactVisitActive == true and tostring(registry.contactVisitBackend or "") == "V1" then
                    updatedRegistry.contactVisitActive = true
                    updatedRegistry.contactVisitMode = registry.contactVisitMode
                    updatedRegistry.contactVisitBackend = registry.contactVisitBackend
                    updatedRegistry.contactVisitRequestedBy = registry.contactVisitRequestedBy
                    updatedRegistry.contactVisitRequestedByID = registry.contactVisitRequestedByID
                    updatedRegistry.contactVisitTargetX = registry.contactVisitTargetX
                    updatedRegistry.contactVisitTargetY = registry.contactVisitTargetY
                    updatedRegistry.contactVisitTargetZ = registry.contactVisitTargetZ
                    updatedRegistry.contactVisitStartedAt = registry.contactVisitStartedAt
                    updatedRegistry.contactVisitReturnStatus = registry.contactVisitReturnStatus
                    ModData.transmit("DynamicTrading_Roster")
                end
                if shouldNotifyArrival and updatedRegistry then
                    notifyContactArrival(uuid, updatedRegistry)
                elseif nextStatus == "Resting" and registry.contactVisitActive == true then
                    clearContactVisitState(uuid)
                    ModData.transmit("DynamicTrading_Roster")
                end
            end
        end
    end

    -- 2. Process New Trade Missions (Resting -> Away) from seeded faction plans
    local plans = DynamicTrading_TradeScheduler.BuildAllFactionPlans(rosterData, currentHours)

    for factionID, plan in pairs(plans) do
        local dispatchable = DynamicTrading_TradeScheduler.GetDispatchCandidates(factionID, rosterData, currentHours, plan.faction)
        for _, uuid in ipairs(dispatchable) do
            local registry = rosterData.Souls[uuid]
            if registry and registry.status == "Resting" then
                if plan.faction and plan.faction.playerOwned then
                    local duration = ZombRand(minTradeHours, maxTradeHours + 1)
                    DynamicTrading.Log("DTV1", "Sim", "Mission", (registry.name or uuid) .. " entering seeded regency trade window.")
                    DynamicTrading_Roster.UpdateSoulStatus(uuid, "Trading", currentHours + duration, "Away")
                else
                    local walkHours = DynamicTrading_TradeScheduler.GetSettings().walkHours
                    DynamicTrading.Log("DTV1", "Sim", "Mission", (registry.name or uuid) .. " starting seeded trade mission.")
                    DynamicTrading_Roster.UpdateSoulStatus(uuid, "Away", currentHours + walkHours, "Trading")
                end
            end
        end
    end
end

-- Hook into hourly tick for efficiency
Events.EveryHours.Add(ProcessSimulation)

DynamicTrading.Log("DTV1", "Sim", "Init", "V1 Simulation Module Loaded (Parity Mode).")
